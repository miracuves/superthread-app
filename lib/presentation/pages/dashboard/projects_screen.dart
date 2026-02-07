import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../../core/services/service_locator.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/epics/epic_bloc.dart';
import '../../bloc/epics/epic_event.dart';
import '../../bloc/epics/epic_state.dart';
import '../../../core/services/api/api_models.dart' show Epic, Project;
import '../../../core/services/api/api_service.dart';
import '../../../data/models/board.dart';
import '../../../data/models/requests/create_epic_request.dart';
import '../../../data/models/requests/update_epic_request.dart';
import '../../widgets/custom_button.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ApiService _apiService;
  late ScrollController _scrollController;
  // Common state
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isGridView = true;

  // Hierarchy state
  int _currentLevel = 0; // 0: Spaces, 1: Boards, 2: Epics
  Project? _selectedSpace;
  Board? _selectedBoard;
  
  // Boards state
  Map<String, List<Board>> _projectBoards = {};
  bool _loadingBoards = false;
  
  // Pagination state
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize ApiService using service locator
    _apiService = sl<ApiService>();
    
    // Initialize ScrollController
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
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

    // Load Spaces (Level 0) by default
    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }
    
    if (teamId != null) {
      context.read<EpicBloc>().add(LoadSpaces(teamId: teamId, limit: 100));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      final state = context.read<EpicBloc>().state;
      
      final authState = context.read<AuthBloc>().state;
      String? teamId;
      if (authState is Authenticated) {
        teamId = authState.teamId;
      }
      
      if (teamId == null) return;

      if (state is SpaceLoadSuccess && state.hasMore) {
        setState(() => _isLoadingMore = true);
        context.read<EpicBloc>().add(LoadSpaces(
              teamId: teamId,
              page: state.currentPage + 1,
              limit: 100,
            ));
      } else if (state is EpicLoadSuccess && state.hasMore) {
        setState(() => _isLoadingMore = true);
        context.read<EpicBloc>().add(LoadEpics(
              teamId: teamId,
              boardId: _selectedBoard?.id,
              page: state.currentPage + 1,
              limit: 100,
            ));
      }
    }
  }

  void _loadMoreProjects() {
    final state = context.read<EpicBloc>().state;
    if (state is EpicLoadSuccess && state.hasMore && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      final authState = context.read<AuthBloc>().state;
      String? teamId;
      if (authState is Authenticated) {
        teamId = authState.teamId;
      }
      
      if (teamId != null) {
        context.read<EpicBloc>().add(LoadEpics(
          teamId: teamId,
          page: state.currentPage + 1,
          limit: 100,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EpicBloc, EpicState>(
      listener: (context, state) {
        if (state is EpicLoadSuccess && _isLoadingMore) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: _currentLevel > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleBackNavigation,
              )
            : null,
        title: Text(
          _getAppBarTitle(),
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
              Icons.filter_list,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.dashboard,
                        color: _selectedFilter == 'all' ? AppColors.primary : null),
                    const SizedBox(width: 8),
                    Text('All Projects'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'active',
                child: Row(
                  children: [
                    Icon(Icons.play_circle,
                        color: _selectedFilter == 'active' ? AppColors.primary : null),
                    const SizedBox(width: 8),
                    Text('Active'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: _selectedFilter == 'completed' ? AppColors.primary : null),
                    const SizedBox(width: 8),
                    Text('Completed'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archived',
                child: Row(
                  children: [
                    Icon(Icons.archive,
                        color: _selectedFilter == 'archived' ? AppColors.primary : null),
                    const SizedBox(width: 8),
                    Text('Archived'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          Expanded(child: _buildProjectsList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    ));
  }

  Widget _buildSearchAndFilter(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search projects...',
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
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedFilter != 'all'
                  ? AppColors.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getFilterDisplayName(_selectedFilter),
              style: AppTextStyles.bodySmall.copyWith(
                color: _selectedFilter != 'all'
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: _selectedFilter != 'all' ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context) {
    return BlocBuilder<EpicBloc, EpicState>(
      builder: (context, state) {
        final actualState =
            state is EpicOperationSuccess ? state.previousState : state;

        if (actualState is EpicLoadInProgress) {
          return _buildLoadingState();
        } else if (actualState is EpicLoadFailure) {
          return _buildErrorState(context, actualState.error);
        }

        // Switch on current level to determine what to show
        switch (_currentLevel) {
          case 1:
            // Level 1: Boards view
            if (_selectedSpace == null) {
              return _buildEmptyState(context, 'No space selected');
            }
            final boards = _selectedSpace!.boards ?? [];
            if (boards.isEmpty) {
              return _buildEmptyState(context, 'No boards found in ${_selectedSpace!.name}');
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: _isGridView
                  ? _buildBoardsGrid(context, boards)
                  : _buildBoardsListView(context, boards),
            );

          case 2:
            // Level 2: Epics
            if (_selectedBoard == null) {
              return _buildEmptyState(context, 'No board selected');
            }

            // Combine pre-loaded epics from the board and its lists
            final List<Epic> preLoadedEpics = [];
            if (_selectedBoard!.epics != null) {
              preLoadedEpics.addAll(_selectedBoard!.epics!);
            }
            if (_selectedBoard!.lists != null) {
              for (var list in _selectedBoard!.lists!) {
                if (list.epics != null) {
                  for (var epic in list.epics!) {
                    if (!preLoadedEpics.any((e) => e.id == epic.id)) {
                      preLoadedEpics.add(epic);
                    }
                  }
                }
              }
            }

            final List<Epic> epicsToShow = actualState is EpicLoadSuccess
                ? actualState.epics
                : preLoadedEpics;

            final items = _filterProjects(epicsToShow);

            return Column(
              children: [
                // Option to view all cards for this board
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 0,
                    color: AppColors.primary.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      onTap: () {
                        context.push('/kanban/${_selectedBoard!.id}?name=${Uri.encodeComponent(_selectedBoard!.name)}');
                      },
                      leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary),
                      title: const Text('View All Board Cards', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      subtitle: const Text('Navigate directly to the Kanban board'),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                    ),
                  ),
                ),
                if (items.isEmpty && actualState is! EpicLoadInProgress && preLoadedEpics.isEmpty)
                  Expanded(child: _buildEmptyState(context, 'No projects found in ${_selectedBoard!.name}'))
                else
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isGridView
                          ? _buildProjectsGrid(context, items)
                          : _buildProjectsListView(context, items),
                    ),
                  ),
              ],
            );

          case 0:
          default:
            // Level 0: Spaces
            if (actualState is SpaceLoadSuccess) {
              final items = _filterSpaces(actualState.spaces);
              if (items.isEmpty) return _buildEmptyState(context, 'No spaces found');

              return FadeTransition(
                opacity: _fadeAnimation,
                child: _isGridView
                    ? _buildSpacesGrid(context, items)
                    : _buildSpacesListView(context, items),
              );
            }
            // Fallback for initial state
            return _buildEmptyState(context, 'No item found');
        }
      },
    );
  }

  String _getAppBarTitle() {
    switch (_currentLevel) {
      case 0:
        return 'Spaces';
      case 1:
        return _selectedSpace?.name ?? 'Boards';
      case 2:
        return _selectedBoard?.name ?? 'Projects';
      default:
        return 'Projects';
    }
  }

  void _handleBackNavigation() {
    setState(() {
      if (_currentLevel == 2) {
        _currentLevel = 1;
        _selectedBoard = null;
      } else if (_currentLevel == 1) {
        _currentLevel = 0;
        _selectedSpace = null;
        // Re-load spaces to be sure
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          context.read<EpicBloc>().add(LoadSpaces(teamId: authState.teamId, limit: 100));
        }
      }
    });
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
            'Failed to load projects',
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
              final authState = context.read<AuthBloc>().state;
              String? teamId;
              if (authState is Authenticated) {
                teamId = authState.teamId;
              }
              if (teamId != null) {
                context.read<EpicBloc>().add(LoadEpics(teamId: teamId));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpacesGrid(BuildContext context, List<Project> spaces) {
    return AnimationLimiter(
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: spaces.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= spaces.length) return const _LoadingIndicator();
          final space = spaces[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildSpaceCard(context, space),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpacesListView(BuildContext context, List<Project> spaces) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: spaces.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= spaces.length) return const _LoadingIndicator();
        final space = spaces[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSpaceListCard(context, space),
        );
      },
    );
  }

  Widget _buildBoardsGrid(BuildContext context, List<Board> boards) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return _buildBoardCard(context, board);
      },
    );
  }

  Widget _buildBoardsListView(BuildContext context, List<Board> boards) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildBoardListCard(context, board),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Create content to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context, List<Epic> epics) {
    return AnimationLimiter(
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemCount: epics.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= epics.length) {
            // Loading indicator at bottom
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (index >= epics.length) {
            // Loading indicator at bottom
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final project = epics[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildProjectCard(context, project),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectsListView(BuildContext context, List<Epic> epics) {
    return AnimationLimiter(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: epics.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= epics.length) {
            // Loading indicator at bottom
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final epic = epics[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProjectListCard(context, epic),
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Epic epic) {
    return GestureDetector(
      onTap: () => _navigateToProject(context, epic),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getProjectColor(epic).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getProjectIcon(epic),
                      color: _getProjectColor(epic),
                      size: 20,
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
                      _handleProjectAction(context, epic, value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                              PopupMenuItem(
                                value: 'archive',
                                child: Text(
                                    epic.archived ? 'Activate' : 'Archive'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
              const SizedBox(height: 12),
              Text(
                epic.title,
                style: AppTextStyles.headline5.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                epic.content ?? 'No description',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Boards section
              _buildBoardChips(context, epic),
              const SizedBox(height: 8),
              if (epic.updatedAt != null)
                Text(
                  'Updated ${_formatDate(epic.updatedAt!)}',
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

  Widget _buildProjectListCard(BuildContext context, Epic project) {
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
            color: _getProjectColor(project).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getProjectIcon(project),
            color: _getProjectColor(project),
            size: 24,
          ),
        ),
        title: Text(
          project.title,
          style: AppTextStyles.headline6.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          project.content ?? 'No description',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToProject(context, project),
      ),
    );
  }

  List<Project> _filterSpaces(List<Project> spaces) {
    if (_searchQuery.isEmpty) return spaces;
    final query = _searchQuery.toLowerCase();
    return spaces.where((space) {
      return space.name.toLowerCase().contains(query) ||
          (space.description ?? '').toLowerCase().contains(query);
    }).toList();
  }

  List<Epic> _filterProjects(List<Epic> epics) {
    var filtered = epics.where((epic) {
      if (_searchQuery.isNotEmpty) {
        final title = epic.title.toLowerCase();
        final content = (epic.content ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!title.contains(query) && !content.contains(query)) {
          return false;
        }
      }

      if (_selectedFilter != 'all') {
        final isArchived = epic.archived;
        switch (_selectedFilter) {
          case 'active':
            if (isArchived) return false;
            break;
          case 'archived':
            if (!isArchived) return false;
            break;
        }
      }

      return true;
    }).toList();
    return filtered;
  }

  Color _getProjectColor(Epic project) {
    // Implement color logic based on project type/title
    final title = project.title.toLowerCase();
    final id = project.id;
    
    // Color coding based on project characteristics
    if (title.contains('mobile') || title.contains('app')) {
      return AppColors.primary;
    } else if (title.contains('web') || title.contains('frontend')) {
      return AppColors.secondary;
    } else if (title.contains('backend') || title.contains('api')) {
      return AppColors.accent;
    } else if (title.contains('urgent') || title.contains('critical')) {
      return Colors.red.shade400;
    } else if (title.contains('feature') || title.contains('new')) {
      return Colors.green.shade400;
    } else if (title.contains('bug') || title.contains('fix')) {
      return Colors.orange.shade400;
    }
    
    // Fallback to hash-based color
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
    ];
    return colors[(id.hashCode) % colors.length];
  }

  IconData _getProjectIcon(Epic project) {
    final title = project.title.toLowerCase();
    
    // Icon based on project title patterns
    if (title.contains('mobile') || title.contains('app')) {
      return Icons.phone_android;
    } else if (title.contains('web') || title.contains('frontend')) {
      return Icons.web;
    } else if (title.contains('backend') || title.contains('api')) {
      return Icons.api;
    } else if (title.contains('design') || title.contains('ui')) {
      return Icons.design_services;
    } else if (title.contains('marketing')) {
      return Icons.campaign;
    } else if (title.contains('docs') || title.contains('documentation')) {
      return Icons.description;
    }
    
    return Icons.dashboard;
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'archived':
        return 'Archived';
      default:
        return 'All';
    }
  }

  String _formatDate(dynamic date) {
    // Implement proper date formatting
    if (date == null) return 'Unknown';
    
    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'Unknown';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  Future<void> _loadBoardsForProjects(List<Epic> projects) async {
    if (_loadingBoards || projects.isEmpty) return;
    
    setState(() {
      _loadingBoards = true;
    });

    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }

    if (teamId == null) {
      setState(() {
        _loadingBoards = false;
      });
      return;
    }

    // Load boards for each project
    for (final project in projects) {
      if ((project.boards != null && project.boards!.isNotEmpty) || 
          _projectBoards.containsKey(project.id)) continue;
          
      try {
        final response = await _apiService.getBoards(
          teamId,
          projectId: project.id,
          archived: 'false',
          limit: 50,
        );
        
        if (mounted) {
          setState(() {
            _projectBoards[project.id] = response.boards;
          });
        }
      } catch (e) {
        debugPrint('Failed to load boards for project ${project.id}: $e');
        // Continue loading boards for other projects
      }
    }

    if (mounted) {
      setState(() {
        _loadingBoards = false;
      });
    }
  }

  Widget _buildBoardChips(BuildContext context, Epic project) {
    final boards = project.boards ?? _projectBoards[project.id];
    
    if (boards == null) {
      // Still loading
      return const SizedBox(
        height: 24,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    
    if (boards.isEmpty) {
      return Text(
        'No boards',
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: boards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final board = boards[index];
          return GestureDetector(
            onTap: () {
              context.push('/kanban/${board.id}?name=${Uri.encodeComponent(board.name)}');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dashboard,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    board.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToProject(BuildContext context, Epic project) {
    context.push('/kanban/${project.id}?name=${Uri.encodeComponent(project.title)}');
  }

  void _handleProjectAction(BuildContext context, Epic project, String action) {
    switch (action) {
      case 'edit':
        _showEditProjectDialog(context, project);
        break;
      case 'archive':
        _archiveProject(context, project);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, project);
        break;
    }
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create New Project',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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
                hintText: 'Enter project description',
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
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                final authState = context.read<AuthBloc>().state;
                String? teamId;
                if (authState is Authenticated) {
                  teamId = authState.teamId;
                }
                
                if (teamId != null) {
                  context.read<EpicBloc>().add(
                    CreateEpic(
                      teamId: teamId,
                      request: CreateEpicRequest(
                        title: nameController.text.trim(),
                        content: descriptionController.text.trim(),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, Epic project) {
    final nameController = TextEditingController(text: project.title);
    final descriptionController = TextEditingController(text: project.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Project',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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
                hintText: 'Enter project description',
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
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<EpicBloc>().add(
                  UpdateEpic(
                    epicId: project.id,
                    request: UpdateEpicRequest(
                      title: nameController.text.trim(),
                      content: descriptionController.text.trim(),
                    ),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _archiveProject(BuildContext context, Epic project) {
    context.read<EpicBloc>().add(ArchiveEpic(epicId: project.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Project "${project.title}" archived')),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Epic project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Project',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${project.title}"? This action cannot be undone.',
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
              context.read<EpicBloc>().add(ArchiveEpic(epicId: project.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Project "${project.title}" deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceCard(BuildContext context, Project space) {
    return GestureDetector(
      onTap: () => _navigateToSpace(space),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                space.name,
                style: AppTextStyles.headline4.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${space.boards?.length ?? 0} Boards',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceListCard(BuildContext context, Project space) {
    return ListTile(
      onTap: () => _navigateToSpace(space),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.folder, color: AppColors.primary, size: 20),
      ),
      title: Text(space.name, style: AppTextStyles.headline5),
      subtitle: Text('${space.boards?.length ?? 0} Boards'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildBoardCard(BuildContext context, Board board) {
    return GestureDetector(
      onTap: () => _navigateToBoard(board),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dashboard_outlined, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                board.name,
                style: AppTextStyles.headline5,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardListCard(BuildContext context, Board board) {
    return ListTile(
      onTap: () => _navigateToBoard(board),
      leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary),
      title: Text(board.name, style: AppTextStyles.headline6),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  void _navigateToSpace(Project space) {
    setState(() {
      _selectedSpace = space;
      _currentLevel = 1;
    });
  }

  void _navigateToBoard(Board board) {
    setState(() {
      _selectedBoard = board;
      _currentLevel = 2;
    });
    // Trigger Fetching Epics for this board
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<EpicBloc>().add(LoadEpics(
        teamId: authState.teamId,
        boardId: board.id,
        limit: 100,
      ));
    }
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}