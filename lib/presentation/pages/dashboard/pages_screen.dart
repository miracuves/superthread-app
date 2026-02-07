import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/pages/page_bloc.dart';
import '../../bloc/pages/page_event.dart';
import '../../bloc/pages/page_state.dart';
import '../../../data/models/page.dart' as page_model;

class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key});

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  void _loadPages() {
    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }
    context.read<PageBloc>().add(LoadPages(teamId: teamId, page: 1, limit: 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPages,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/pages/create'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadPages(),
        child: BlocConsumer<PageBloc, PageState>(
          listener: (context, state) {
            if (state is PageOperationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
            if (state is PageOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final actualState =
                state is PageOperationSuccess ? state.previousState : state;

            if (actualState is PageLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (actualState is PageLoadFailure) {
              return _buildError(actualState.error);
            }
            if (actualState is PageLoadSuccess) {
              if (actualState.pages.isEmpty) {
                return _buildEmpty();
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: actualState.pages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final page = actualState.pages[index];
                  return _buildPageCard(context, page);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPageCard(BuildContext context, page_model.Page page) {
    return InkWell(
      onTap: () => context.push('/pages/${page.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              page.title,
              style: AppTextStyles.headline4.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if ((page.content ?? '').isNotEmpty)
              Text(
                (page.content ?? '').replaceAll(RegExp(r'<[^>]*>'), '').trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  page.createdAt.toLocal().toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                if (page.isPinned == true)
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadPages,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('No pages yet.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/pages/create'),
              child: const Text('Create your first page'),
            ),
          ],
        ),
      ),
    );
  }
}

