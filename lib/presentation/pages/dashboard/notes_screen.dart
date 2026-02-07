import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../bloc/notes/note_bloc.dart';
import '../../bloc/notes/note_event.dart';
import '../../bloc/notes/note_state.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/note.dart';
import '../note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedSort = 'recent';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // Load notes
    context.read<NoteBloc>().add(LoadNotes());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: AppTextStyles.headline3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 18),
                    SizedBox(width: 8),
                    Text('Recently Updated'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'created',
                child: Row(
                  children: [
                    Icon(Icons.add_circle, size: 18),
                    SizedBox(width: 8),
                    Text('Recently Created'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'title',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 18),
                    SizedBox(width: 8),
                    Text('Title (A-Z)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndCategories(context),
          Expanded(child: _buildNotesList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNoteEditor(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildSearchAndCategories(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(
                  context: context,
                  label: 'All Notes',
                  icon: Icons.notes,
                  isSelected: _selectedCategory == 'all',
                  onTap: () => setState(() => _selectedCategory = 'all'),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  context: context,
                  label: 'Personal',
                  icon: Icons.person,
                  isSelected: _selectedCategory == 'personal',
                  onTap: () => setState(() => _selectedCategory = 'personal'),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  context: context,
                  label: 'Work',
                  icon: Icons.work,
                  isSelected: _selectedCategory == 'work',
                  onTap: () => setState(() => _selectedCategory = 'work'),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  context: context,
                  label: 'Ideas',
                  icon: Icons.lightbulb,
                  isSelected: _selectedCategory == 'ideas',
                  onTap: () => setState(() => _selectedCategory = 'ideas'),
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  context: context,
                  label: 'Meeting',
                  icon: Icons.groups,
                  isSelected: _selectedCategory == 'meeting',
                  onTap: () => setState(() => _selectedCategory = 'meeting'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      selectedColor: AppColors.accent.withOpacity(0.2),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? AppColors.accent : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildNotesList(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        final actualState = state is NoteOperationSuccess ? state.previousState : state;

        if (actualState is NoteLoadInProgress) {
          return _buildLoadingState();
        } else if (actualState is NoteLoadSuccess) {
          final filteredNotes = _filterNotes(actualState.notes);
          if (filteredNotes.isEmpty) {
            return _buildEmptyState(context);
          }
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _isGridView
                ? _buildNotesGrid(context, filteredNotes)
                : _buildNotesListView(context, filteredNotes),
          );
        } else if (actualState is NoteLoadFailure) {
          return _buildErrorState(context, actualState.message);
        } else {
          return _buildEmptyState(context);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load notes',
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Retry',
            icon: Icons.refresh,
            onPressed: () {
              context.read<NoteBloc>().add(LoadNotes());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No notes found',
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'all'
                ? 'No notes match your criteria'
                : 'Create your first note to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (_searchQuery.isEmpty && _selectedCategory == 'all') ...[
            const SizedBox(height: 24),
            CustomButton(
              text: 'Create Note',
              icon: Icons.add,
              onPressed: () => _navigateToNoteEditor(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesGrid(BuildContext context, List<Note> notes) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildNoteGridItem(context, note),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesListView(BuildContext context, List<Note> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildNoteListItem(context, note),
        );
      },
    );
  }

  Widget _buildNoteGridItem(BuildContext context, Note note) {
    // Determine category from tags or content if applicable
    final category = _getCategoryFromNote(note);

    return GestureDetector(
      onTap: () => _navigateToNoteEditor(context, note),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getCategoryLabel(category),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onSelected: (value) {
                      _handleNoteAction(context, note, value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.content_copy, size: 18),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.title.isEmpty ? 'Untitled Note' : note.title,
                style: AppTextStyles.headline6.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (note.content.isNotEmpty)
                Text(
                  _stripHtml(note.content),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Text(
                _formatDate(note.updatedAt ?? note.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteListItem(BuildContext context, Note note) {
    final category = _getCategoryFromNote(note);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.note_alt,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                note.title.isEmpty ? 'Untitled Note' : note.title,
                style: AppTextStyles.headline6.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 12,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _getCategoryLabel(category).toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty)
              Text(
                _stripHtml(note.content),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(note.updatedAt ?? note.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToNoteEditor(context, note),
      ),
    );
  }

  List<Note> _filterNotes(List<Note> notes) {
    var filtered = List<Note>.from(notes);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        final title = note.title.toLowerCase();
        final content = _stripHtml(note.content).toLowerCase();
        return title.contains(query) || content.contains(query);
      }).toList();
    }

    // Category filter
    if (_selectedCategory != 'all') {
      filtered = filtered.where((note) =>
      _getCategoryFromNote(note) == _selectedCategory).toList();
    }

    // Sort
    switch (_selectedSort) {
      case 'recent':
        filtered.sort((a, b) {
          final bDate = b.updatedAt ?? b.createdAt;
          final aDate = a.updatedAt ?? a.createdAt;
          return bDate.compareTo(aDate);
        });
        break;
      case 'created':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  }

  String? _getCategoryFromNote(Note note) {
    // Priority 1: Check metadata if available
    if (note.metadata != null && note.metadata!['category'] != null) {
      return note.metadata!['category'].toString().toLowerCase();
    }

    // Priority 2: Check tags
    if (note.tags != null && note.tags!.isNotEmpty) {
      // Return first tag as potential category
      return note.tags!.first.toLowerCase();
    }

    // Fallback: Check status
    if (note.status != null) {
      return note.status!.toLowerCase();
    }

    return null;
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'personal':
        return Icons.person;
      case 'work':
        return Icons.work;
      case 'ideas':
        return Icons.lightbulb;
      case 'meeting':
        return Icons.groups;
      default:
        return Icons.notes;
    }
  }

  String _getCategoryLabel(String? category) {
    switch (category) {
      case 'personal':
        return 'Personal';
      case 'work':
        return 'Work';
      case 'ideas':
        return 'Ideas';
      case 'meeting':
        return 'Meeting';
      default:
        return 'General';
    }
  }

  String _stripHtml(String html) {
    // Simple HTML stripping - in production, use proper HTML parser
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .trim();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No Date';
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today, ${DateFormat.jm().format(date)}';
      } else if (difference.inDays == 1) {
        return 'Yesterday, ${DateFormat.jm().format(date)}';
      } else if (difference.inDays < 7) {
        return '${DateFormat.EEEE().format(date)}, ${DateFormat.jm().format(date)}';
      } else {
        return DateFormat('MMM d, y').format(date);
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Future<void> _navigateToNoteEditor(BuildContext context, [Note? note]) async {
    // Capture the bloc before navigation to avoid context issues after async gap
    final noteBloc = context.read<NoteBloc>();

    if (note != null) {
      await context.push('/notes/${note.id}');
    } else {
      await context.push('/notes/create');
    }

    // Reload notes when returning from editor
    // We check mounted to ensure we don't trigger updates if the screen is gone
    if (mounted) {
      noteBloc.add(LoadNotes());
    }
  }

  void _handleNoteAction(BuildContext context, Note note, String action) {
    switch (action) {
      case 'edit':
        _navigateToNoteEditor(context, note);
        break;
      case 'duplicate':
        _duplicateNote(context, note);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, note);
        break;
    }
  }

  void _duplicateNote(BuildContext context, Note note) {
    context.read<NoteBloc>().add(CreateNote(
      title: '${note.title} (Copy)',
      content: note.content,
      tags: note.tags,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note duplicated')),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Note',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${note.title}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NoteBloc>().add(DeleteNote(noteId: note.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Note "${note.title}" deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
