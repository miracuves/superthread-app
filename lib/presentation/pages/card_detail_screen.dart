import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/cards/card_bloc.dart';
import '../bloc/cards/card_event.dart';
import '../bloc/cards/card_state.dart';
import '../widgets/custom_button.dart';
import '../../core/constants/api_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/api/api_service.dart';
import '../../core/services/api/api_models.dart';
import '../../core/services/storage/storage_service.dart';
import '../../core/services/websocket/websocket_service.dart';
import '../../data/models/card.dart' as card_model;
import '../../data/models/requests/create_comment_request.dart';
import '../../data/models/requests/update_comment_request.dart';
import '../../data/models/requests/comment_reaction_request.dart';
import '../../core/utils/string_utils.dart';

class CardDetailScreen extends StatefulWidget {
  final String? cardId;
  final String? boardId;

  const CardDetailScreen({
    super.key,
    this.cardId,
    this.boardId,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late CardBloc _cardBloc;
  late WebSocketService _webSocketService;
  StreamSubscription<RealtimeEvent>? _commentEventsSubscription;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commentController = TextEditingController();
  String _selectedPriority = 'Medium';
  String _selectedStatus = 'To Do';
  List<String> _tags = [];
  List<card_model.Comment> _comments = [];
  List<card_model.Attachment> _attachments = [];
  Set<String> _selectedAttachmentIds = {};
  double _uploadProgress = 0;
  bool _isUploading = false;
  String? _replyingToCommentId;
  static const int _maxCommentLength = 500;
  String _attachmentFilter = 'all'; // 'all', 'images', 'documents', 'other'
  static const List<String> _reactionEmojis = ['👍', '❤️', '🎉', '😄', '🙏'];
  bool _isLoading = false;
  
  // Mentions support
  List<MapEntry<String, String>> _matchingUsers = [];
  bool _showMentionSuggestions = false;
  int _mentionTriggerIndex = -1;
  String _mentionQuery = '';
  
  // Collapsed replies tracking
  Set<String> _collapsedComments = {};

  @override
  void initState() {
    super.initState();
    _cardBloc = CardBloc(
      getService<ApiService>(),
      getService<StorageService>(),
    );
    _webSocketService = getService<WebSocketService>();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    // Load card data if editing
    if (widget.cardId != null) {
      _loadCardData();
      _setupWebSocketListener();
    }

    // Add listener for mentions
    _commentController.addListener(_onCommentChanged);
  }

  void _onCommentChanged() {
    final text = _commentController.text;
    final selection = _commentController.selection;
    
    if (selection.start != selection.end || selection.start < 0) {
      if (_showMentionSuggestions) {
        setState(() => _showMentionSuggestions = false);
      }
      return;
    }

    final cursorPosition = selection.start;
    final textBeforeCursor = text.substring(0, cursorPosition);
    
    // Find the last '@' before the cursor
    final lastAtPos = textBeforeCursor.lastIndexOf('@');
    
    if (lastAtPos != -1) {
      // Check if there's a space or it's the start of the string before '@'
      final isTrigger = lastAtPos == 0 || textBeforeCursor[lastAtPos - 1] == ' ' || textBeforeCursor[lastAtPos - 1] == '\n';
      
      if (isTrigger) {
        final query = textBeforeCursor.substring(lastAtPos + 1);
        
        // Query shouldn't contain spaces
        if (!query.contains(' ') && !query.contains('\n')) {
          _updateMentionSuggestions(query, lastAtPos);
          return;
        }
      }
    }
    
    if (_showMentionSuggestions) {
      setState(() => _showMentionSuggestions = false);
    }
  }

  void _updateMentionSuggestions(String query, int triggerIndex) {
    final users = _cardBloc.userCache;
    if (users.isEmpty) {
      if (_showMentionSuggestions) {
        setState(() => _showMentionSuggestions = false);
      }
      return;
    }

    final matches = users.entries.where((entry) {
      final name = entry.value.toLowerCase();
      final q = query.toLowerCase();
      return name.contains(q);
    }).toList();

    setState(() {
      _matchingUsers = matches;
      _showMentionSuggestions = matches.isNotEmpty;
      _mentionTriggerIndex = triggerIndex;
      _mentionQuery = query;
    });
  }

  void _applyMention(MapEntry<String, String> user) {
    final text = _commentController.text;
    final beforeAt = text.substring(0, _mentionTriggerIndex);
    final afterQuery = text.substring(_mentionTriggerIndex + 1 + _mentionQuery.length);
    
    final newText = '$beforeAt@${user.value}$afterQuery ';
    final newCursorPos = beforeAt.length + user.value.length + 2; // +1 for @, +1 for space
    
    _commentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
    
    setState(() {
      _showMentionSuggestions = false;
    });
  }

  void _setupWebSocketListener() {
    if (widget.cardId == null) return;

    Future.microtask(() async {
      try {
        if (!_webSocketService.isConnected) {
          final token = await getService<StorageService>().getAccessToken();
          if (token != null && token.isNotEmpty) {
            await _webSocketService.connect(
              ApiConstants.websocketUrl,
              token: token,
            );
          } else {
            print('Skipping WebSocket connect: missing token');
          }
        }

        _webSocketService.subscribeToCard(widget.cardId!);

        // Subscribe to comment events for this card
        _commentEventsSubscription = _webSocketService
            .getEventsForCard(widget.cardId!)
            .where((event) =>
                event.type == 'comment_added' ||
                event.type == 'comment_updated' ||
                event.type == 'comment_deleted')
            .listen(
          (event) {
            if (!mounted) return;
            _cardBloc.add(LoadCardComments(cardId: widget.cardId!));
          },
          onError: (error) {
            if (mounted) {
              print('WebSocket error listening to comments: $error');
            }
          },
        );
      } catch (e) {
        print('Failed to setup WebSocket listener: $e');
      }
    });
  }

  void _loadCardData() {
    setState(() => _isLoading = true);
    _cardBloc.add(GetCardDetails(cardId: widget.cardId!));
  }

  void _populateCardData(card_model.Card card) {
    _titleController.text = card.title;
    _descriptionController.text = card.description ?? '';
    // Map API status to dropdown values
    final apiStatus = card.status ?? 'todo';
    _selectedStatus = _mapApiStatusToUI(apiStatus);
    _tags = card.tags ?? [];
    _comments = card.comments ?? [];
    _attachments = card.attachments ?? [];
    // Map priority from card if available
    if (card.metadata != null && card.metadata!['priority'] != null) {
      _selectedPriority = card.metadata!['priority'] as String;
    }
    setState(() => _isLoading = false);
  }
  
  String _mapApiStatusToUI(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'started':
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'done':
      case 'completed':
        return 'Done';
      case 'todo':
      case 'to_do':
      default:
        return 'To Do';
    }
  }
  
  String _mapUIStatusToApi(String uiStatus) {
    switch (uiStatus) {
      case 'In Progress':
        return 'started';
      case 'Review':
        return 'review';
      case 'Done':
        return 'done';
      case 'To Do':
      default:
        return 'todo';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    if (widget.cardId != null) {
      _webSocketService.unsubscribeFromCard(widget.cardId!);
    }
    _commentEventsSubscription?.cancel();
    _cardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardId != null;

    return BlocProvider.value(
      value: _cardBloc,
      child: BlocListener<CardBloc, CardState>(
        listener: (context, state) {
          if (state is CardDetailsLoaded) {
            _populateCardData(state.card);
            if (widget.cardId != null) {
              _cardBloc.add(LoadCardComments(cardId: widget.cardId!));
              _cardBloc.add(LoadCardAttachments(cardId: widget.cardId!));
            }
          } else if (state is CardLoadFailure) {
            setState(() => _isLoading = false);
            _showErrorSnackBar(state.error);
          } else if (state is CardCommentsLoaded) {
            setState(() {
              // Optimize: merge all comments at once instead of one-by-one
              var updatedComments = _comments;
              for (final c in state.comments) {
                updatedComments = _mergeComment(updatedComments, c);
              }
              _comments = updatedComments;
            });
          } else if (state is CardAttachmentsLoaded) {
            setState(() {
              // Always replace with server state as source of truth
              // This handles additions, deletions, and updates correctly
              _attachments = state.attachments;
              _isUploading = false;
              _uploadProgress = 0;
            });
          } else if (state is CardAttachmentUploadProgress) {
            setState(() {
              _isUploading = true;
              _uploadProgress = state.progress;
            });
          } else if (state is CardOperationSuccess) {
            _showSuccessSnackBar(state.message);
            final message = state.message.toLowerCase();
            if (!message.contains('comment') &&
                !message.contains('attachment')) {
              Navigator.pop(context, true);
            }
          } else if (state is CardOperationFailure) {
            final errorMsg = state.error;
            if (errorMsg.toLowerCase().contains('upload')) {
              _showErrorSnackBar('Upload failed: $errorMsg');
            } else if (errorMsg.toLowerCase().contains('comment')) {
              _showErrorSnackBar('Comment operation failed: $errorMsg');
            } else {
              _showErrorSnackBar('Operation failed: $errorMsg');
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              isEditing ? 'Edit Card' : 'Create Card',
              style: AppTextStyles.headline3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  onPressed: () => _showDeleteConfirmation(context),
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfo(context),
                        const SizedBox(height: 24),
                        _buildStatusPriority(context),
                        const SizedBox(height: 24),
                        _buildTagsSection(context),
                        const SizedBox(height: 24),
                        _buildDescriptionSection(context),
                        if (isEditing) ...[
                          const SizedBox(height: 24),
                          _buildAttachmentsSection(context),
                        ],
                        if (isEditing) ...[
                          const SizedBox(height: 24),
                          _buildCommentsSection(context),
                        ],
                        const SizedBox(height: 32),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Card Title',
              hintText: 'Enter card title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.boardId != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.dashboard,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Board ID: ${widget.boardId}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusPriority(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status & Priority',
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                          items: ['To Do', 'In Progress', 'Review', 'Done']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                          items: ['Low', 'Medium', 'High', 'Critical']
                              .map((priority) => DropdownMenuItem(
                                    value: priority,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(priority),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(priority),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddTagDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Tag'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                _tags.remove(tag);
              });
            },
            child: Icon(
              Icons.close,
              size: 14,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Card Description',
              hintText: 'Enter detailed description...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(card_model.Comment parent) {
    final replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to ${parent.authorName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                StringUtils.htmlToPlainText(parent.content),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Write your reply...',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
              maxLength: _maxCommentLength,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = replyController.text.trim();
              if (text.isEmpty || widget.cardId == null) return;

              // Get boardId from card state if missing in widget
              String? boardId = widget.boardId;
              if (boardId == null && _cardBloc.state is CardDetailsLoaded) {
                boardId = (_cardBloc.state as CardDetailsLoaded).card.boardId;
              }

              _cardBloc.add(ReplyToComment(
                cardId: widget.cardId!,
                parentCommentId: parent.id,
                request: CreateCommentRequest(
                  content: text,
                  cardId: widget.cardId!,
                  parentCommentId: parent.id,
                  schema: 1,
                  pageId: boardId,
                  context: 'card_detail_reply',
                ),
              ));
              
              Navigator.pop(context);
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(card_model.Comment comment) {
    final controller = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit comment'),
        content: TextField(
          controller: controller,
          maxLength: _maxCommentLength,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty || widget.cardId == null) return;
              _cardBloc.add(UpdateCardComment(
                cardId: widget.cardId!,
                commentId: comment.id,
                request: UpdateCommentRequest(content: text),
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(card_model.Comment comment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose a reaction'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _reactionEmojis.map((emoji) {
            return Semantics(
              label: 'React with $emoji',
              button: true,
              child: InkWell(
                onTap: () {
                  if (widget.cardId != null) {
                    _cardBloc.add(ToggleCommentReaction(
                      cardId: widget.cardId!,
                      commentId: comment.id,
                      request:
                          CommentReactionRequest(reaction: emoji, toggle: true),
                    ));
                  }
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 32))),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<card_model.Comment> _mergeComment(
      List<card_model.Comment> existing, card_model.Comment incoming) {
    bool found = false;
    final updated = existing.map((comment) {
      if (comment.id == incoming.id) {
        found = true;
        return incoming;
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        final merged = _mergeComment(comment.replies!, incoming);
        if (!identical(merged, comment.replies)) {
          found = true;
          return comment.copyWith(replies: merged);
        }
      }
      return comment;
    }).toList();

    if (!found) {
      if (incoming.parentCommentId != null) {
        final placed = updated.map((comment) {
          if (comment.id == incoming.parentCommentId) {
            final replies = <card_model.Comment>[
              ...(comment.replies ?? <card_model.Comment>[])
            ];
            replies.add(incoming);
            found = true;
            return comment.copyWith(replies: replies);
          }
          if (comment.replies != null && comment.replies!.isNotEmpty) {
            final merged = _mergeComment(comment.replies!, incoming);
            if (!identical(merged, comment.replies)) {
              found = true;
              return comment.copyWith(replies: merged);
            }
          }
          return comment;
        }).toList();
        if (found) return placed;
      }
      return [...updated, incoming];
    }
    return updated;
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    final hasSelection = _selectedAttachmentIds.isNotEmpty;
    final filteredAttachments = _filterAttachments();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attachments',
                style: AppTextStyles.headline4.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (hasSelection)
                    Semantics(
                      label:
                          'Delete ${_selectedAttachmentIds.length} selected attachments',
                      child: TextButton.icon(
                        onPressed: widget.cardId == null
                            ? null
                            : () {
                                _cardBloc.add(DeleteMultipleAttachments(
                                  cardId: widget.cardId!,
                                  attachmentIds:
                                      _selectedAttachmentIds.toList(),
                                ));
                                setState(() => _selectedAttachmentIds.clear());
                              },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete Selected'),
                      ),
                    ),
                  Semantics(
                    label: 'Refresh attachments',
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        if (widget.cardId != null) {
                          _cardBloc
                              .add(LoadCardAttachments(cardId: widget.cardId!));
                        }
                      },
                    ),
                  ),
                  Semantics(
                    label: 'Add attachment',
                    child: IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _pickAndUploadAttachment,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isUploading) ...[
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: _uploadProgress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return LinearProgressIndicator(value: value);
              },
            ),
            const SizedBox(height: 8),
            Text('Uploading ${(100 * _uploadProgress).toStringAsFixed(0)}%'),
          ],
          const SizedBox(height: 16),
          // Filter chips
          if (_attachments.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All', 'all', Icons.grid_view),
                _buildFilterChip('Images', 'images', Icons.image),
                _buildFilterChip('Documents', 'documents', Icons.description),
                _buildFilterChip('Other', 'other', Icons.more_horiz),
              ],
            ),
          const SizedBox(height: 12),
          if (filteredAttachments.isEmpty && _attachments.isNotEmpty)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_off, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'No ${_attachmentFilter} found',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          else if (_attachments.isEmpty)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'No attachments yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: filteredAttachments
                      .map((a) => _buildAttachmentTile(context, a))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _attachmentFilter == value;
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _attachmentFilter = value;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  List<card_model.Attachment> _filterAttachments() {
    if (_attachmentFilter == 'all') return _attachments;

    return _attachments.where((attachment) {
      switch (_attachmentFilter) {
        case 'images':
          return _isImageFile(attachment);
        case 'documents':
          return _isDocumentFile(attachment);
        case 'other':
          return !_isImageFile(attachment) && !_isDocumentFile(attachment);
        default:
          return true;
      }
    }).toList();
  }

  bool _isImageFile(card_model.Attachment attachment) {
    if (attachment.mimeType?.startsWith('image/') == true) return true;
    final ext = attachment.fileName.toLowerCase().split('.').last;
    return ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp', 'svg'].contains(ext);
  }

  bool _isDocumentFile(card_model.Attachment attachment) {
    if (attachment.mimeType != null) {
      final mime = attachment.mimeType!;
      if (mime.contains('pdf') ||
          mime.contains('document') ||
          mime.contains('spreadsheet') ||
          mime.contains('presentation')) {
        return true;
      }
    }
    final ext = attachment.fileName.toLowerCase().split('.').last;
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv']
        .contains(ext);
  }

  Widget _buildAttachmentTile(
      BuildContext context, card_model.Attachment attachment) {
    final isSelected = _selectedAttachmentIds.contains(attachment.id);
    final isImage = _isImageFile(attachment);
    final fileExtension = attachment.fileName.split('.').last.toUpperCase();
    final fileSize = attachment.fileSize != null
        ? _formatFileSize(attachment.fileSize!)
        : null;

    return Semantics(
      label:
          'Attachment: ${attachment.fileName}${fileSize != null ? ", size $fileSize" : ""}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: isSelected ? 'Selected' : 'Not selected',
                child: Checkbox(
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedAttachmentIds.add(attachment.id);
                      } else {
                        _selectedAttachmentIds.remove(attachment.id);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  if (isImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: CachedNetworkImage(
                          imageUrl: attachment.fileUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: Icon(
                              Icons.broken_image,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getFileTypeColor(context, fileExtension),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getFileTypeIcon(fileExtension),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  // File type badge
                  if (!isImage)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          fileExtension,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          title: Text(
            attachment.fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              if (fileSize != null) ...[
                Icon(
                  Icons.storage,
                  size: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  fileSize,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(
                Icons.access_time,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _formatDateTime(attachment.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: Wrap(
            spacing: 0,
            children: [
              Semantics(
                label: 'Open ${attachment.fileName}',
                child: IconButton(
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _openAttachment(attachment.fileUrl),
                ),
              ),
              Semantics(
                label: 'Delete ${attachment.fileName}',
                child: IconButton(
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    if (widget.cardId != null) {
                      _cardBloc.add(DeleteCardAttachment(
                        cardId: widget.cardId!,
                        attachmentId: attachment.id,
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return 'Just now';
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  IconData _getFileTypeIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      case 'csv':
        return Icons.grid_on;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(BuildContext context, String extension) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade600;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade600;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.purple.shade600;
      case 'txt':
        return Colors.grey.shade600;
      default:
        return colorScheme.secondary;
    }
  }

  void _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid attachment URL')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open attachment')),
      );
    }
  }

  Future<void> _pickAndUploadAttachment() async {
    if (widget.cardId == null) return;

    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) {
      _showErrorSnackBar('Selected file has no path. Unable to upload.');
      return;
    }

    // Validate file size (max 50MB)
    final fileSize = await File(file.path!).length();
    const maxFileSize = 50 * 1024 * 1024; // 50MB in bytes
    if (fileSize > maxFileSize) {
      _showErrorSnackBar(
          'File size exceeds 50MB limit. Please select a smaller file.');
      return;
    }

    // Validate file type - block executables and scripts
    final blockedExtensions = [
      'exe',
      'bat',
      'cmd',
      'sh',
      'app',
      'dmg',
      'deb',
      'apk'
    ];
    final fileExtension = file.extension?.toLowerCase() ?? '';
    if (blockedExtensions.contains(fileExtension)) {
      _showErrorSnackBar(
          'File type not allowed. Please upload a different file.');
      return;
    }

    final uploadFile = File(file.path!);

    _cardBloc.add(UploadCardAttachment(
      cardId: widget.cardId!,
      file: uploadFile,
    ));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    final roots = _comments.where((c) => c.parentCommentId == null).toList();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments',
                  style: AppTextStyles.headline4.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    if (widget.cardId != null) {
                      _cardBloc.add(LoadCardComments(cardId: widget.cardId!));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'No comments yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...roots
                .map((c) => _buildCommentTile(context, c, depth: 0))
                .toList(),
          const SizedBox(height: 16),
          if (_showMentionSuggestions) _buildMentionSuggestions(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    maxLength: _maxCommentLength,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isEmpty || widget.cardId == null) return;

                    // Get boardId from card state if missing in widget
                    String? boardId = widget.boardId;
                    if (boardId == null && _cardBloc.state is CardDetailsLoaded) {
                      boardId = (_cardBloc.state as CardDetailsLoaded).card.boardId;
                    }

                    if (text.length > _maxCommentLength) {
                      _showErrorSnackBar(
                          'Comment exceeds $_maxCommentLength characters');
                      return;
                    }
                    if (_replyingToCommentId != null) {
                      _cardBloc.add(ReplyToComment(
                        cardId: widget.cardId!,
                        parentCommentId: _replyingToCommentId!,
                        request: CreateCommentRequest(
                          content: text,
                          cardId: widget.cardId!,
                          parentCommentId: _replyingToCommentId,
                          schema: 1,
                          pageId: boardId,
                          context: 'card_detail_reply',
                        ),
                      ));
                    } else {
                      _cardBloc.add(AddCardComment(
                        cardId: widget.cardId!,
                        request: CreateCommentRequest(
                          content: text,
                          cardId: widget.cardId!,
                          parentCommentId: null,
                          schema: 1,
                          pageId: boardId,
                          context: 'card_detail',
                        ),
                      ));
                    }
                    _commentController.clear();
                    _replyingToCommentId = null;
                    setState(() => _showMentionSuggestions = false);
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentionSuggestions() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _matchingUsers.length,
        itemBuilder: (context, index) {
          final user = _matchingUsers[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 12,
              child: Text(
                user.value[0].toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
            title: Text(
              user.value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'User ID: ${user.key.substring(0, 8)}...',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            onTap: () => _applyMention(user),
          );
        },
      ),
    );
  }

  Widget _buildCommentTile(BuildContext context, card_model.Comment comment,
      {int depth = 0}) {
    final isReplying = _replyingToCommentId == comment.id;
    final hasReplies = comment.replies != null && comment.replies!.isNotEmpty;
    final replyCount = comment.replies?.length ?? 0;
    final isCollapsed = _collapsedComments.contains(comment.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMainComment = depth == 0;

    // Parse mentions in content and style them
    Widget _buildStyledContent() {
      final content = StringUtils.htmlToPlainText(comment.content);
      final mentionRegex = RegExp(r'@[\w-]+');
      final matches = mentionRegex.allMatches(content);
      
      if (matches.isEmpty) {
        return Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
        );
      }

      List<InlineSpan> spans = [];
      int lastIndex = 0;

      for (final match in matches) {
        // Add text before mention
        if (match.start > lastIndex) {
          spans.add(TextSpan(
            text: content.substring(lastIndex, match.start),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            ),
          ));
        }

        // Add styled mention
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.blue.withOpacity(0.2) 
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark 
                    ? Colors.blue.withOpacity(0.4) 
                    : Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              content.substring(match.start, match.end),
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ));

        lastIndex = match.end;
      }

      // Add remaining text
      if (lastIndex < content.length) {
        spans.add(TextSpan(
          text: content.substring(lastIndex),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
        ));
      }

      return RichText(text: TextSpan(children: spans));
    }

    // Main comment (depth 0) - Plain layout without card
    if (isMainComment) {
      return AnimationConfiguration.staggeredList(
        position: depth,
        duration: const Duration(milliseconds: 300),
        child: SlideAnimation(
          verticalOffset: 20.0,
          child: FadeInAnimation(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Avatar + Name + Time + Actions
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isDark 
                            ? Colors.blue.shade700 
                            : Colors.blue.shade100,
                        child: Text(
                          comment.authorName.isNotEmpty 
                              ? comment.authorName[0].toUpperCase() 
                              : 'U',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.authorName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTimestamp(comment.createdAt),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.5) 
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions menu
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditCommentDialog(comment);
                          } else if (value == 'delete') {
                            if (widget.cardId != null) {
                              _cardBloc.add(DeleteCardComment(
                                cardId: widget.cardId!,
                                commentId: comment.id,
                              ));
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20, 
                                  color: isDark ? Colors.white70 : Colors.black87),
                                const SizedBox(width: 12),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 20, 
                                  color: Colors.red.shade400),
                                const SizedBox(width: 12),
                                Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Comment content with styled mentions
                  _buildStyledContent(),
                  const SizedBox(height: 12),
                  // Reply count and reply button
                  Row(
                    children: [
                      if (hasReplies)
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isCollapsed) {
                                _collapsedComments.remove(comment.id);
                              } else {
                                _collapsedComments.add(comment.id);
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                size: 18,
                                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showReplyDialog(comment),
                        icon: Icon(
                          Icons.reply,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        label: Text(
                          'Reply',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ],
                  ),
                  // Replies (if not collapsed)
                  if (hasReplies && !isCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: comment.replies!
                            .map((reply) => _buildCommentTile(context, reply, depth: depth + 1))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Reply comment (depth > 0) - Card layout
    return AnimationConfiguration.staggeredList(
      position: depth,
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        verticalOffset: 20.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF2A2D3A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar + Name + Time + Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isDark 
                                ? Colors.blue.shade700 
                                : Colors.blue.shade100,
                            child: Text(
                              comment.authorName.isNotEmpty 
                                  ? comment.authorName[0].toUpperCase() 
                                  : 'U',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name and time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.authorName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTimestamp(comment.createdAt),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark 
                                        ? Colors.white.withOpacity(0.5) 
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Actions menu
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditCommentDialog(comment);
                              } else if (value == 'delete') {
                                if (widget.cardId != null) {
                                  _cardBloc.add(DeleteCardComment(
                                    cardId: widget.cardId!,
                                    commentId: comment.id,
                                  ));
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 20, 
                                      color: isDark ? Colors.white70 : Colors.black87),
                                    const SizedBox(width: 12),
                                    const Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 20, 
                                      color: Colors.red.shade400),
                                    const SizedBox(width: 12),
                                    Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Comment content with styled mentions
                      _buildStyledContent(),
                    ],
                  ),
                ),

                // Reply button for nested replies
                if (hasReplies || depth > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark 
                              ? Colors.white.withOpacity(0.1) 
                              : Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (hasReplies)
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isCollapsed) {
                                  _collapsedComments.remove(comment.id);
                                } else {
                                  _collapsedComments.add(comment.id);
                                }
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                  size: 18,
                                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _showReplyDialog(comment),
                          icon: Icon(
                            Icons.reply,
                            size: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          label: Text(
                            'Reply',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Nested replies (if not collapsed)
                if (hasReplies && !isCollapsed)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                    child: Column(
                      children: comment.replies!
                          .map((reply) => _buildCommentTile(context, reply, depth: depth + 1))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: widget.cardId != null ? 'Update Card' : 'Create Card',
            onPressed: _saveCard,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return AppColors.success;
      case 'Medium':
        return AppColors.warning;
      case 'High':
        return Colors.orange;
      case 'Critical':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
            hintText: 'Enter tag name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _tags.add(controller.text.trim());
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveCard() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a card title')),
      );
      return;
    }

    // Get teamId from auth state
    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }

    if (widget.cardId != null) {
      // Update existing card
      _cardBloc.add(UpdateCard(
        cardId: widget.cardId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _mapUIStatusToApi(_selectedStatus),
        tags: _tags,
      ));
    } else {
      // Create new card
      _cardBloc.add(CreateCard(
        teamId: teamId,
        boardId: widget.boardId ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _mapUIStatusToApi(_selectedStatus),
        tags: _tags,
      ));
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text(
          'Are you sure you want to delete this card? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (widget.cardId != null) {
                _cardBloc.add(DeleteCard(cardId: widget.cardId!));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
