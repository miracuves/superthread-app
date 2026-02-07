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
import '../widgets/cards/external_link_widget.dart';
import '../widgets/cards/card_hint_widget.dart';
import '../widgets/cards/cover_image_widget.dart';
import '../widgets/cards/estimate_widget.dart';
import '../widgets/comments/threaded_comment_widget.dart';
import '../../core/constants/api_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/api/api_service.dart';
import '../../core/services/api/api_models.dart';
import '../../core/services/storage/storage_service.dart';
import '../../core/services/websocket/websocket_service.dart';
import '../../data/models/card.dart' as card_model;
import '../../data/models/external_link.dart';
import '../../data/models/card_hint.dart';
import '../../data/models/cover_image.dart';
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
  
  // NEW FIELDS
  List<ExternalLink>? _externalLinks;
  List<CardHint>? _hints;
  CoverImage? _coverImage;
  int? _estimate;
  
  Set<String> _selectedAttachmentIds = {};
  double _uploadProgress = 0;
  bool _isUploading = false;
  String? _replyingToCommentId;
  static const int _maxCommentLength = 500;
  String _attachmentFilter = 'all';
  static const List<String> _reactionEmojis = ['👍', '❤️', '🎉', '😄', '🙏'];
  bool _isLoading = false;
  
  List<MapEntry<String, String>> _matchingUsers = [];
  bool _showMentionSuggestions = false;
  int _mentionTriggerIndex = -1;
  String _mentionQuery = '';
  
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

    if (widget.cardId != null) {
      _loadCardData();
      _setupWebSocketListener();
    }

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
    final lastAtPos = textBeforeCursor.lastIndexOf('@');
    
    if (lastAtPos != -1) {
      final isTrigger = lastAtPos == 0 || textBeforeCursor[lastAtPos - 1] == ' ';
      if (isTrigger) {
        final query = textBeforeCursor.substring(lastAtPos + 1);
        if (!query.contains(' ')) {
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

  void _applyMention(MapEntry<String, String> person) {
    final text = _commentController.text;
    final beforeAt = text.substring(0, _mentionTriggerIndex);
    final afterQuery = text.substring(_mentionTriggerIndex + 1 + _mentionQuery.length);
    final newText = '${beforeAt}@${person.value}$afterQuery ';
    final newCursorPos = beforeAt.length + person.value.length + 2;
    
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
            await _webSocketService.connect(ApiConstants.websocketUrl, token: token);
          }
        }
        _webSocketService.subscribeToCard(widget.cardId!);
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
              print('WebSocket error: $error');
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
    
    final apiStatus = card.status ?? 'todo';
    _selectedStatus = _mapApiStatusToUI(apiStatus);
    _tags = card.tags ?? [];
    _comments = card.comments ?? [];
    _attachments = card.attachments ?? [];
    
    // NEW: Populate new fields
    _externalLinks = card.externalLinks;
    _hints = card.hints;
    _coverImage = card.coverImage;
    _estimate = card.estimate;
    
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
              var updatedComments = _comments;
              for (final c in state.comments) {
                updatedComments = _mergeComment(updatedComments, c);
              }
              _comments = updatedComments;
            });
          } else if (state is CardAttachmentsLoaded) {
            setState(() {
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
            if (!message.contains('comment') && !message.contains('attachment')) {
              Navigator.pop(context, true);
            }
          } else if (state is CardOperationFailure) {
            _showErrorSnackBar('Operation failed: ${state.error}');
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
                        // Cover Image
                        if (_coverImage != null) ...[
                          _buildCoverImageSection(context),
                          const SizedBox(height: 16),
                        ],
                        
                        _buildBasicInfo(context),
                        const SizedBox(height: 16),
                        
                        // Estimate
                        if (_estimate != null) _buildEstimateSection(context),
                        if (_estimate != null) const SizedBox(height: 16),
                        
                        _buildStatusPriority(context),
                        const SizedBox(height: 16),
                        
                        // Hints
                        if (_hints != null && _hints!.isNotEmpty) ...[
                          _buildHintsSection(context),
                          const SizedBox(height: 16),
                        ],
                        
                        _buildTagsSection(context),
                        const SizedBox(height: 16),
                        
                        _buildDescriptionSection(context),
                        
                        if (isEditing) ...[
                          const SizedBox(height: 16),
                          // External Links
                          if (_externalLinks != null && _externalLinks!.isNotEmpty) ...[
                            _buildExternalLinksSection(context),
                            const SizedBox(height: 16),
                          ],
                          _buildAttachmentsSection(context),
                        ],
                        if (isEditing) ...[
                          const SizedBox(height: 16),
                          _buildCommentsSection(context),
                        ],
                        const SizedBox(height: 24),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // NEW: Cover Image Section
  Widget _buildCoverImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CoverImageWidget(
        coverImage: _coverImage!,
        height: 200,
      ),
    );
  }

  // NEW: Estimate Section
  Widget _buildEstimateSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            'Story Points:',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          EstimateWidget(estimate: _estimate),
        ],
      ),
    );
  }

  // NEW: External Links Section
  Widget _buildExternalLinksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Icon(Icons.link, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'External Links',
                style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExternalLinksList(
            links: _externalLinks!,
            emptyMessage: 'No external links attached',
          ),
        ],
      ),
    );
  }

  // NEW: Hints Section
  Widget _buildHintsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Suggestions',
                style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._hints!.map((hint) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CardHintWidget(
              hint: hint,
              onApply: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Applied suggestion: ${hint.type}')),
                );
              },
              onDismiss: () {
                setState(() {
                  _hints?.remove(hint);
                });
              },
            ),
          )),
        ],
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.boardId != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.dashboard, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Board ID: ${widget.boardId}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
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
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'To Do', child: Text('To Do')),
                    DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'Review', child: Text('Review')),
                    DropdownMenuItem(value: 'Done', child: Text('Done')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedStatus = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedPriority = value);
                  },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tags',
                style: AppTextStyles.headline4.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAddTagDialog,
                tooltip: 'Add Tag',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_tags.isEmpty)
            Text(
              'No tags added',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) => _buildTagChip(tag)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => setState(() => _tags.remove(tag)),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
    );
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
                setState(() => _tags.add(controller.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
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
            maxLines: null,
            minLines: 5,
            decoration: InputDecoration(
              labelText: 'Card Description',
              hintText: 'Enter detailed description...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    final filteredAttachments = _getFilteredAttachments();

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
                'Attachments (${_attachments.length})',
                style: AppTextStyles.headline4.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterDialog(context),
                    tooltip: 'Filter',
                  ),
                  if (_isUploading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(value: _uploadProgress, strokeWidth: 2),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickFile,
                    tooltip: 'Attach File',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All', 'all', Icons.apps),
              _buildFilterChip('Images', 'images', Icons.image),
              _buildFilterChip('Documents', 'documents', Icons.description),
              _buildFilterChip('Other', 'other', Icons.insert_drive_file),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredAttachments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No attachments',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: List.generate(
                filteredAttachments.length,
                (index) => _buildAttachmentTile(filteredAttachments[index], index),
              ),
            ),
        ],
      ),
    );
  }

  List<card_model.Attachment> _getFilteredAttachments() {
    switch (_attachmentFilter) {
      case 'images':
        return _attachments.where((a) => a.fileType?.startsWith('image/') ?? false).toList();
      case 'documents':
        return _attachments.where((a) => a.fileType?.startsWith('application/') ?? false || a.fileType == 'text/plain').toList();
      case 'other':
        return _attachments.where((a) => !(a.fileType?.startsWith('image/') ?? false) && !(a.fileType?.startsWith('application/') ?? false) && a.fileType != 'text/plain').toList();
      default:
        return _attachments;
    }
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _attachmentFilter == value;
    return FilterChip(
      label: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label),
      ]),
      selected: isSelected,
      onSelected: (selected) => setState(() => _attachmentFilter = value),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildAttachmentTile(card_model.Attachment attachment, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedAttachmentIds.contains(attachment.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedAttachmentIds.add(attachment.id);
              } else {
                _selectedAttachmentIds.remove(attachment.id);
              }
            });
          },
        ),
        title: Text(
          attachment.fileName,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatFileSize(attachment.fileSize),
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (attachment.fileType?.startsWith('image/') ?? false)
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () => _previewImage(attachment),
                tooltip: 'Preview',
              ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadAttachment(attachment),
              tooltip: 'Download',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.shade400,
              onPressed: () => _confirmDeleteAttachment(attachment),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Attachments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Images'),
              leading: const Icon(Icons.image),
              onTap: () {
                setState(() => _attachmentFilter = 'images');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Documents'),
              leading: const Icon(Icons.description),
              onTap: () {
                setState(() => _attachmentFilter = 'documents');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Other'),
              leading: const Icon(Icons.insert_drive_file),
              onTap: () {
                setState(() => _attachmentFilter = 'other');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('All Files'),
              leading: const Icon(Icons.apps),
              onTap: () {
                setState(() => _attachmentFilter = 'all');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    if (widget.cardId == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _isUploading = true;
          _uploadProgress = 0;
        });

        _cardBloc.add(UploadCardAttachment(
          cardId: widget.cardId!,
          file: file,
        ));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: $e');
      setState(() => _isUploading = false);
    }
  }

  void _previewImage(card_model.Attachment attachment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(attachment.fileName), backgroundColor: Colors.black),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: attachment.fileUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _downloadAttachment(card_model.Attachment attachment) async {
    try {
      final uri = Uri.parse(attachment.fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch download URL');
      }
    } catch (e) {
      _showErrorSnackBar('Download failed: $e');
    }
  }

  void _confirmDeleteAttachment(card_model.Attachment attachment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attachment'),
        content: Text('Are you sure you want to delete ${attachment.fileName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.cardId != null) {
                _cardBloc.add(DeleteCardAttachment(
                  cardId: widget.cardId!,
                  attachmentId: attachment.id,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    final rootComments = _comments.where((c) => c.parentCommentId == null).toList();

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
            'Comments (${_comments.length})',
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (rootComments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No comments yet',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ThreadedCommentsList(
              comments: rootComments,
              onReply: (comment) => _showReplyDialog(comment),
            ),
          const SizedBox(height: 16),
          _buildCommentInput(context),
          if (_showMentionSuggestions) _buildMentionSuggestions(),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Add a comment...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          maxLength: _maxCommentLength,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${_commentController.text.length}/$_maxCommentLength',
              style: AppTextStyles.bodySmall.copyWith(
                color: _commentController.text.length > _maxCommentLength * 0.9
                    ? AppColors.error
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _commentController.text.trim().isEmpty ? null : _submitComment,
              icon: const Icon(Icons.send),
              label: const Text('Send'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMentionSuggestions() {
    if (_matchingUsers.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _matchingUsers.length,
        itemBuilder: (context, index) {
          final person = _matchingUsers[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(child: Text(person.value[0].toUpperCase())),
            title: Text(person.value),
            subtitle: Text('@${person.key}'),
            onTap: () => _applyMention(person),
          );
        },
      ),
    );
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty || widget.cardId == null) return;

    String? boardId = widget.boardId;
    if (boardId == null && _cardBloc.state is CardDetailsLoaded) {
      boardId = (_cardBloc.state as CardDetailsLoaded).card.boardId;
    }

    _cardBloc.add(AddCardComment(
      cardId: widget.cardId!,
      request: CreateCommentRequest(
        content: text,
        cardId: widget.cardId!,
        schema: 1,
        pageId: boardId,
        context: 'card_detail',
      ),
    ));

    _commentController.clear();
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

  List<card_model.Comment> _mergeComment(
    List<card_model.Comment> comments,
    card_model.Comment newComment,
  ) {
    final index = comments.indexWhere((c) => c.id == newComment.id);
    if (index != -1) {
      final updated = List<card_model.Comment>.from(comments);
      updated[index] = newComment;
      return updated;
    }
    
    if (newComment.parentCommentId != null) {
      final parentIndex = comments.indexWhere((c) => c.id == newComment.parentCommentId);
      if (parentIndex != -1) {
        final parent = comments[parentIndex];
        final updatedReplies = [...(parent.replies ?? []), newComment];
        final updatedParent = parent.copyWith(replies: updatedReplies);
        final updated = List<card_model.Comment>.from(comments);
        updated[parentIndex] = updatedParent;
        return updated;
      }
    }
    
    return [...comments, newComment];
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _saveCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              widget.cardId != null ? 'Update Card' : 'Create Card',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _saveCard() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a card title')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }

    if (widget.cardId != null) {
      _cardBloc.add(UpdateCard(
        cardId: widget.cardId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _mapUIStatusToApi(_selectedStatus),
        tags: _tags,
      ));
    } else {
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
