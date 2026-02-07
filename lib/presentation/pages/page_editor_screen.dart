import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/pages/page_bloc.dart';
import '../bloc/pages/page_event.dart';
import '../bloc/pages/page_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/custom_button.dart';

class PageEditorScreen extends StatefulWidget {
  final String? pageId;

  const PageEditorScreen({super.key, this.pageId});

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pageId != null) {
      final authState = context.read<AuthBloc>().state;
      String? teamId;
      if (authState is Authenticated) {
        teamId = authState.teamId;
      }
      context.read<PageBloc>().add(GetPageDetails(pageId: widget.pageId!, teamId: teamId));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    if (widget.pageId == null) {
      context.read<PageBloc>().add(CreatePage(
            teamId: teamId,
            title: title,
            content: content,
          ));
    } else {
      context.read<PageBloc>().add(UpdatePage(
            pageId: widget.pageId!,
            teamId: teamId,
            title: title,
            content: content,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PageBloc, PageState>(
      listener: (context, state) {
        if (state is PageDetailsLoaded) {
          _titleController.text = state.page.title;
          _contentController.text = state.page.content ?? '';
          setState(() => _isLoading = false);
        } else if (state is PageOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.pop();
        } else if (state is PageLoadInProgress) {
          setState(() => _isLoading = true);
        } else if (state is PageLoadFailure || state is PageOperationFailure) {
          setState(() => _isLoading = false);
          final error = state is PageLoadFailure
              ? state.error
              : (state as PageOperationFailure).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.pageId == null ? 'Create Page' : 'Edit Page'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          hintText: 'Write your page content...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Save',
                            onPressed: _save,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            isOutlined: true,
                            onPressed: () => context.pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

