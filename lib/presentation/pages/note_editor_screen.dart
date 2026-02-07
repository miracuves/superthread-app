import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_quill/flutter_quill.dart';  // Temporarily disabled
import '../bloc/notes/note_bloc.dart';
import '../bloc/boards/board_bloc.dart';
import '../bloc/boards/board_state.dart';
import '../../data/models/note.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../widgets/custom_button.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  // final QuillController _contentController = QuillController.basic();
  final TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;
  bool _isPinned = false;
  List<String> _tags = [];
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();

    if (widget.noteId != null) {
      _loadNote();
    }
  }

  void _loadNote() {
    // Load existing note from bloc
    if (widget.noteId != null) {
      context.read<NoteBloc>().add(GetNoteDetails(noteId: widget.noteId!));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteDetailsLoaded) {
          final note = state.note;
          _titleController.text = note.title;
          // Parse content from note - handle HTML or plain text
          try {
            final content = note.content;
            _contentController.text = content.isNotEmpty ? content : '';
          } catch (e) {
            _contentController.text = '';
          }
          _isPinned = note.isPinned ?? false;
          _tags = note.tags ?? [];
          setState(() {
            _isLoading = false;
          });
        } else if (state is NoteLoadFailure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load note: ${state.error}')),
          );
        } else if (state is NoteLoadInProgress && widget.noteId != null) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.noteId == null ? 'New Note' : 'Edit Note'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
              children: [
                // Title Input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _titleController,
                    style: AppTextStyles.headline6,
                    decoration: InputDecoration(
                      hintText: 'Note Title',
                      border: InputBorder.none,
                      hintStyle: AppTextStyles.headline6.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

                // Tags and Project Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTagsSection(),
                      const SizedBox(height: 12),
                      _buildProjectSelector(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Rich Text Editor - Temporarily using TextField instead of QuillEditor
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Note content...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),

                // Formatting Toolbar - Temporarily disabled
                /*
                */
              ],
            ),
        bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Save Note',
                onPressed: _saveNote,
              ),
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              isOutlined: true,
            ),
          ],
        ),
      ),
      ),
    );
  }
  
  String _stripHtmlTags(String html) {
    // Simple HTML tag stripper - removes <p>, </p>, etc.
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _tags.map((tag) {
            return InputChip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
              },
              deleteIcon: const Icon(Icons.close, size: 16),
            );
          }).toList(),
        ),
        TextButton.icon(
          onPressed: _addTag,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Tag'),
        ),
      ],
    );
  }

  Widget _buildProjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        BlocBuilder<BoardBloc, BoardState>(
          builder: (context, state) {
            List<DropdownMenuItem<String>> projectItems = [
              const DropdownMenuItem(
                value: null,
                child: Text('No Project'),
              ),
            ];
            
            if (state is BoardLoadSuccess) {
              projectItems.addAll(
                state.boards.map((board) => DropdownMenuItem(
                  value: board.id,
                  child: Text(board.name),
                )).toList(),
              );
            }
            
            return DropdownButtonFormField<String>(
              value: _selectedProjectId,
              decoration: InputDecoration(
                hintText: 'Select Project',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: projectItems,
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value;
                });
              },
            );
          },
        ),
      ],
    );
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter tag name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _tags.add(controller.text.trim());
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final contentText = _contentController.text;
      final note = Note(
        id: widget.noteId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: contentText,
        tags: _tags,
        isPinned: _isPinned,
        projectId: _selectedProjectId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.noteId == null) {
        context.read<NoteBloc>().add(CreateNote(
              title: note.title,
              content: note.content,
              tags: _tags,
              isPinned: _isPinned,
            ));
      } else {
        context.read<NoteBloc>().add(UpdateNote(
              noteId: widget.noteId!,
              title: note.title,
              content: note.content,
              tags: _tags,
              isPinned: _isPinned,
            ));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.noteId == null ? 'Note created' : 'Note updated'),
        ),
      );

      Navigator.of(context).pop(note);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}