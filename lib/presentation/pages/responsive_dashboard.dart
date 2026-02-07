import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../bloc/boards/board_bloc.dart';
import '../bloc/boards/board_state.dart';
import '../bloc/boards/board_event.dart';
import '../bloc/cards/card_bloc.dart';
import '../bloc/notes/note_bloc.dart';
import '../bloc/notes/note_state.dart';
import '../bloc/notes/note_event.dart';
import '../bloc/search/search_bloc.dart';
import '../../data/models/board.dart';
import '../../data/models/note.dart';
import '../../data/models/card.dart' as superthread_card;
import '../widgets/kanban_board.dart';
import '../widgets/error_handling.dart';
import 'note_editor_screen.dart';
import 'dashboard/search_screen.dart';
import '../../core/services/api/api_service.dart';
import '../../core/services/storage/storage_service.dart';
import '../../core/services/connectivity/connectivity_service.dart';

class ResponsiveDashboard extends StatefulWidget {
  const ResponsiveDashboard({super.key});

  @override
  State<ResponsiveDashboard> createState() => _ResponsiveDashboardState();
}

class _ResponsiveDashboardState extends State<ResponsiveDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  String? _teamId;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _loadTeamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    final storageService = StorageService();
    await storageService.init();
    _teamId = await storageService.getTeamId();

    if (_teamId != null) {
      if (!mounted) return;
      // Load initial data
      context.read<BoardBloc>().add(LoadBoards(teamId: _teamId!));
      context.read<NoteBloc>().add(LoadNotes(teamId: _teamId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();

    return Scaffold(
      body: MultiBlocErrorHandler(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildHomeTab(),
            _buildProjectsTab(),
            _buildCardsTab(),
            _buildNotesTab(),
            _buildSearchTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeTab() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Superthread'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Show notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Show settings
                },
              ),
            ],
          ),
        ];
      },
      body: _buildHomeContent(),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_teamId != null) {
          if (!mounted) return;
          context.read<BoardBloc>().add(LoadBoards(teamId: _teamId!));
          context.read<NoteBloc>().add(LoadNotes(teamId: _teamId!));
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.card_membership,
                    title: 'Cards',
                    count: '0', // Would be populated from BLoC state
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.note,
                    title: 'Notes',
                    count: '0', // Would be populated from BLoC state
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.description,
                    title: 'Pages',
                    count: '0', // Would be populated from BLoC state
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const EmptyStateWidget(
              title: 'No recent activity',
              subtitle: 'Your recent changes and updates will appear here',
              icon: Icons.history,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: Column(
            children: List.generate(
              4,
              (index) => AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _QuickActionCard(
                      icon: _getQuickActionIcon(index),
                      title: _getQuickActionTitle(index),
                      subtitle: _getQuickActionSubtitle(index),
                      onTap: () => _onQuickActionTap(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsTab() {
    return BlocBuilder<BoardBloc, BoardState>(
      builder: (context, state) {
        if (state is BoardLoadInProgress) {
          return const LoadingWidget(message: 'Loading boards...');
        } else if (state is BoardLoadFailure) {
          return ErrorHandlingWidget(
            error: state.error,
            onRetry: () {
              if (_teamId != null) {
                context.read<BoardBloc>().add(LoadBoards(teamId: _teamId!));
              }
            },
          );
        } else if (state is BoardLoadSuccess) {
          return _buildBoardsList(state.boards);
        }
        return const LoadingWidget();
      },
    );
  }

  Widget _buildBoardsList(List<Board> boards) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_teamId != null) {
          if (!mounted) return;
          context.read<BoardBloc>().add(LoadBoards(teamId: _teamId!));
        }
      },
      child: boards.isEmpty
          ? const EmptyStateWidget(
              title: 'No boards yet',
              subtitle: 'Create your first board to get started',
              icon: Icons.dashboard,
            )
          : AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: boards.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _BoardCard(
                          board: boards[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) => CardBloc(
                                        context.read<ApiService>(),
                                        context.read(),
                                      ),
                                    ),
                                  ],
                                  child: KanbanBoard(
                                    board: boards[index],
                                    teamId: _teamId!,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCardsTab() {
    return const Center(
      child: Text('Cards Tab - Navigate from Projects'),
    );
  }

  Widget _buildNotesTab() {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoadInProgress) {
          return const LoadingWidget(message: 'Loading notes...');
        } else if (state is NoteLoadFailure) {
          return ErrorHandlingWidget(
            error: state.error,
            onRetry: () {
              if (_teamId != null) {
                context.read<NoteBloc>().add(LoadNotes(teamId: _teamId!));
              }
            },
          );
        } else if (state is NoteLoadSuccess) {
          return _buildNotesList(state.notes);
        }
        return const LoadingWidget();
      },
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_teamId != null) {
          if (!mounted) return;
          context.read<NoteBloc>().add(LoadNotes(teamId: _teamId!));
        }
      },
      child: notes.isEmpty
          ? const EmptyStateWidget(
              title: 'No notes yet',
              subtitle: 'Create your first note to get started',
              icon: Icons.note,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return _NoteCard(
                  note: notes[index],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NoteEditorScreen(
                          noteId: notes[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildSearchTab() {
    if (_teamId == null) {
      return const EmptyStateWidget(
        title: 'Not authenticated',
        subtitle: 'Please log in to use search',
      );
    }
    return SearchScreen();
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });

          // Animate FAB
          if (index == 2) {
            _fabAnimationController.forward();
          } else {
            _fabAnimationController.reverse();
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: FloatingActionButton(
            onPressed: _onFabPressed,
            child: _currentIndex == 2
                ? const Icon(Icons.card_membership)
                : const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _onFabPressed() {
    switch (_currentIndex) {
      case 0:
        _showCreateOptions();
        break;
      case 1:
        _createNewBoard();
        break;
      case 2:
        _createNewCard();
        break;
      case 3:
        _createNewNote();
        break;
      case 4:
        break;
    }
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('New Board'),
            onTap: () {
              Navigator.pop(context);
              _createNewBoard();
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_membership),
            title: const Text('New Card'),
            onTap: () {
              Navigator.pop(context);
              _createNewCard();
            },
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('New Note'),
            onTap: () {
              Navigator.pop(context);
              _createNewNote();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('New Page'),
            onTap: () {
              Navigator.pop(context);
              _createNewPage();
            },
          ),
        ],
      ),
    );
  }

  void _createNewBoard() {
    // Implementation for creating new board
  }

  void _createNewCard() {
    // Implementation for creating new card
  }

  void _createNewNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteEditorScreen(),
      ),
    );
  }

  void _createNewPage() {
    // Implementation for creating new page
  }

  void _onQuickActionTap(int index) {
    switch (index) {
      case 0:
        _createNewCard();
        break;
      case 1:
        _createNewNote();
        break;
      case 2:
        Navigator.of(context).pushNamed('/search');
        break;
      case 3:
        _showCalendarView();
        break;
    }
  }

  void _showCalendarView() {
    // Implementation for calendar view
  }

  IconData _getQuickActionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.add_circle;
      case 1:
        return Icons.note_add;
      case 2:
        return Icons.search;
      case 3:
        return Icons.calendar_month;
      default:
        return Icons.circle;
    }
  }

  String _getQuickActionTitle(int index) {
    switch (index) {
      case 0:
        return 'Quick Add';
      case 1:
        return 'Quick Note';
      case 2:
        return 'Quick Search';
      case 3:
        return 'Calendar View';
      default:
        return '';
    }
  }

  String _getQuickActionSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Create a new item quickly';
      case 1:
        return 'Jot down a quick note';
      case 2:
        return 'Search across all items';
      case 3:
        return 'View your schedule';
      default:
        return '';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  final Board board;
  final VoidCallback onTap;

  const _BoardCard({
    required this.board,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                board.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.list, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${board.lists?.length ?? 0} lists',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _NoteCard({
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _formatDate(note.updatedAt),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}