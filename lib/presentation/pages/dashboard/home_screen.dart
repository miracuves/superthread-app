import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/boards/board_bloc.dart';
import '../../bloc/cards/card_bloc.dart';
import '../../bloc/epics/epic_bloc.dart';
import '../../bloc/notes/note_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/requests/create_epic_request.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    // Load dashboard data
    _loadDashboardData();
  }

  void _loadDashboardData() {
    // Use the authenticated workspace/team id instead of a placeholder.
    final authState = context.read<AuthBloc>().state;
    String? teamId;

    if (authState is Authenticated) {
      teamId = authState.teamId;
    }

    // The blocs also know how to fall back to StorageService.getTeamId()
    // if this is null, so passing a nullable teamId is safe.
    context.read<EpicBloc>().add(LoadEpics(teamId: teamId));
    context.read<BoardBloc>().add(LoadBoards(teamId: teamId));
    context.read<CardBloc>().add(LoadCards(teamId: teamId));
    context.read<NoteBloc>().add(LoadNotes(teamId: teamId));
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
          'Dashboard',
          style: AppTextStyles.headline3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              _showNotifications(context);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _loadDashboardData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDashboardData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context),
                const SizedBox(height: 24),
                _buildStatsGrid(context),
                const SizedBox(height: 24),
                _buildRecentActivitySection(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is Authenticated
            ? authState.user.name ?? 'User'
            : 'User';
        final greeting = _getGreeting();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName!',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready to organize your work today?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textInverse.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textInverse.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.textInverse.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_sunny,
                  size: 30,
                  color: AppColors.textInverse,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return AnimationLimiter(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            context: context,
            title: 'Projects',
            value: BlocBuilder<EpicBloc, EpicState>(
              builder: (context, state) {
                if (state is EpicLoadSuccess) {
                  return Text('${state.epics.length}', style: AppTextStyles.headline2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold));
                }
                return Text('0', style: AppTextStyles.headline2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold));
              },
            ),
            icon: Icons.dashboard,
            color: AppColors.primary,
            onTap: () => _navigateToTab(context, 1),
          ),
          _buildStatCard(
            context: context,
            title: 'Cards',
            value: BlocBuilder<CardBloc, CardState>(
              builder: (context, state) {
                if (state is CardLoadSuccess) {
                  return Text('${state.cards.length}', style: AppTextStyles.headline2.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold));
                }
                return Text('0', style: AppTextStyles.headline2.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold));
              },
            ),
            icon: Icons.style,
            color: AppColors.secondary,
            onTap: () => _navigateToTab(context, 2),
          ),
          _buildStatCard(
            context: context,
            title: 'Notes',
            value: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoadSuccess) {
                  return Text('${state.notes.length}', style: AppTextStyles.headline2.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold));
                }
                return Text('0', style: AppTextStyles.headline2.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold));
              },
            ),
            icon: Icons.note_alt,
            color: AppColors.accent,
            onTap: () => _navigateToTab(context, 3),
          ),
          _buildStatCard(
            context: context,
            title: 'Tasks',
            value: BlocBuilder<CardBloc, CardState>(
              builder: (context, state) {
                if (state is CardLoadSuccess) {
                  return Text('${state.cards.length}', style: AppTextStyles.headline2.copyWith(color: AppColors.success, fontWeight: FontWeight.bold));
                }
                return Text('0', style: AppTextStyles.headline2.copyWith(color: AppColors.success, fontWeight: FontWeight.bold));
              },
            ),
            icon: Icons.task_alt,
            color: AppColors.success,
            onTap: () => _navigateToTab(context, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required Widget value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimationConfiguration.staggeredGrid(
      position: 0,
      duration: const Duration(milliseconds: 375),
      columnCount: 2,
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        value,
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.headline4.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to search screen with activity filter
                context.go('/search');
              },
              child: Text(
                'View All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActivityList(context),
      ],
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return BlocBuilder<BoardBloc, BoardState>(
      builder: (context, boardState) {
        return BlocBuilder<CardBloc, CardState>(
          builder: (context, cardState) {
            return BlocBuilder<NoteBloc, NoteState>(
              builder: (context, noteState) {
                return BlocBuilder<EpicBloc, EpicState>(
                  builder: (context, epicState) {
                    final activities = _getActivities(context);
                    
                    if (activities.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.history,
                                size: 48,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recent activity',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                
                final activitiesList = activities;
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activitiesList.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                    itemBuilder: (context, index) {
                      final activity = activitiesList[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: activity.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity.icon,
                            color: activity.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          activity.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                          ),
                        ),
                        subtitle: Text(
                          activity.time,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                      );
                    }
                      )
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.headline4.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Create Project',
                icon: Icons.add,
                onPressed: () {
                  _showCreateProjectDialog(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Add Note',
                icon: Icons.note_add,
                isOutlined: true,
                onPressed: () {
                  _showCreateNoteDialog(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Browse Pages',
          icon: Icons.description_outlined,
          isOutlined: true,
          onPressed: () {
            context.go('/pages');
          },
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getTaskCount() {
    // Get actual task count from cards
    final cardState = context.read<CardBloc>().state;
    if (cardState is CardLoadSuccess) {
      return '${cardState.cards.length}';
    }
    return '0';
  }

  List<ActivityItem> _getActivities(BuildContext context) {
    final activities = <ActivityItem>[];
    
    // Get recent notes
    final noteState = context.read<NoteBloc>().state;
    if (noteState is NoteLoadSuccess) {
      for (final note in noteState.notes.take(2)) {
        activities.add(ActivityItem(
          title: 'Note: ${note.title}',
          icon: Icons.note_alt,
          color: AppColors.accent,
          time: _formatTimeAgo(note.createdAt),
        ));
      }
    }
    
    // Get recent cards
    final cardState = context.read<CardBloc>().state;
    if (cardState is CardLoadSuccess) {
      for (final card in cardState.cards.take(2)) {
        activities.add(ActivityItem(
          title: 'Card: ${card.title}',
          icon: Icons.style,
          color: AppColors.primary,
          time: _formatTimeAgo(card.createdAt),
        ));
      }
    }
    
    // Get recent boards
    final boardState = context.read<BoardBloc>().state;
    if (boardState is BoardLoadSuccess) {
      for (final board in boardState.boards.take(1)) {
        activities.add(ActivityItem(
          title: 'Project: ${board.name}',
          icon: Icons.grid_view,
          color: AppColors.success,
          time: _formatTimeAgo(board.createdAt),
        ));
      }
    }

    // Get recent projects (epics)
    final epicState = context.read<EpicBloc>().state;
    if (epicState is EpicLoadSuccess) {
      for (final epic in epicState.epics.take(2)) {
        activities.add(ActivityItem(
          title: 'Project: ${epic.title}',
          icon: Icons.dashboard,
          color: AppColors.primary,
          time: epic.createdAt != null 
              ? _formatTimeAgo(epic.createdAt!) 
              : 'Recently',
        ));
      }
    }
    
    // Sort by time (most recent first) and limit to 4
    activities.sort((a, b) => b.time.compareTo(a.time));
    return activities.take(4).toList();
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToTab(BuildContext context, int index) {
    // Navigate to specific tab in dashboard using GoRouter
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/cards');
        break;
      case 3:
        context.go('/notes');
        break;
      case 4:
        context.go('/search');
        break;
      case 5:
        context.go('/profile');
        break;
      default:
        context.go('/dashboard');
    }
  }

  void _showNotifications(BuildContext context) {
    context.push('/notifications/history');
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter project name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter project description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                // Get teamId from auth state
                final authState = context.read<AuthBloc>().state;
                String? teamId;
                if (authState is Authenticated) {
                  teamId = authState.teamId;
                }
                context.read<EpicBloc>().add(
                  CreateEpic(
                    teamId: teamId,
                    request: CreateEpicRequest(
                      title: name,
                      content: descriptionController.text.trim(),
                    ),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Project "$name" created successfully!')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Note Title',
                hintText: 'Enter note title',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Enter note content (optional)',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                Navigator.pop(context);
                // Get teamId from auth state
                final authState = context.read<AuthBloc>().state;
                String? teamId;
                if (authState is Authenticated) {
                  teamId = authState.teamId;
                }
                context.read<NoteBloc>().add(
                  CreateNote(
                    teamId: teamId,
                    title: title,
                    content: contentController.text.trim(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note "$title" created successfully!')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class ActivityItem {
  final String title;
  final IconData icon;
  final Color color;
  final String time;

  ActivityItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.time,
  });
}