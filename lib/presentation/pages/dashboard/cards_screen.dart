import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/cards/card_bloc.dart';
import '../../bloc/cards/card_event.dart';
import '../../bloc/cards/card_state.dart';
import '../../bloc/boards/board_bloc.dart';
import '../../bloc/boards/board_state.dart';
import '../../widgets/custom_button.dart';
import '../card_detail_screen.dart';
import '../../../data/models/card.dart' as model;

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedBoard = 'all';
  String _selectedStatus = 'all';
  String _selectedPriority = 'all';
  bool _isGridView = true;
  bool _showAssignedToMe = false;

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
    _scrollController.addListener(_onScroll);

    // Load cards and boards - get teamId from auth state
    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }
    context.read<CardBloc>().add(LoadCards(teamId: teamId));
    context.read<BoardBloc>().add(LoadBoards(teamId: teamId));
  }

  void _loadCards({int page = 1}) {
    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }

    context.read<CardBloc>().add(LoadCards(
      teamId: teamId,
      boardId: _selectedBoard == 'all' ? null : _selectedBoard,
      status: _selectedStatus == 'all' ? null : _selectedStatus,
      assignedToMe: _showAssignedToMe,
      page: page,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<CardBloc>().state;
      if (state is CardLoadSuccess && state.hasMore) {
        _loadCards(page: state.currentPage + 1);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cards',
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
              _showFilterDialog(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.tune),
                    SizedBox(width: 8),
                    Text('Filters'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort),
                    SizedBox(width: 8),
                    Text('Sort'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context),
          Expanded(child: _buildCardsList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCardDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Card'),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search cards...',
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
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context: context,
                  label: 'Board: ${_selectedBoard == 'all' ? 'All' : _selectedBoard}',
                  icon: Icons.dashboard,
                  isSelected: _selectedBoard != 'all',
                  onTap: () => _showBoardSelector(context),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'Status: ${_getStatusLabel(_selectedStatus)}',
                  icon: Icons.flag,
                  isSelected: _selectedStatus != 'all',
                  onTap: () => _showStatusSelector(context),
                ),
                const SizedBox(width: 8),
                  _buildFilterChip(
                    context: context,
                    label: 'Priority: ${_getPriorityLabel(_selectedPriority)}',
                    icon: Icons.priority_high,
                    isSelected: _selectedPriority != 'all',
                    onTap: () => _showPrioritySelector(context),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context: context,
                    label: 'My Cards',
                    icon: Icons.person,
                    isSelected: _showAssignedToMe,
                    onTap: _toggleAssignedToMe,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
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
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildCardsList(BuildContext context) {
    return BlocBuilder<CardBloc, CardState>(
      builder: (context, state) {
        if (state is CardLoadInProgress) {
          return _buildLoadingState();
        } else if (state is CardLoadSuccess) {
          final filteredCards = _filterCards(state.cards);
          if (filteredCards.isEmpty) {
            return _buildEmptyState(context);
          }
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _isGridView
                ? _buildCardsGrid(context, filteredCards)
                : _buildCardsListView(context, filteredCards),
          );
        } else if (state is CardLoadFailure) {
          return _buildErrorState(context, state.message);
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
            'Failed to load cards',
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
              context.read<CardBloc>().add(LoadCards(teamId: teamId));
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
            Icons.style_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards found',
            style: AppTextStyles.headline4.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _hasActiveFilters()
                ? 'No cards match your filters'
                : 'Create your first card to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (!_hasActiveFilters() && _searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            CustomButton(
              text: 'Create Card',
              icon: Icons.add,
              onPressed: () => _showCreateCardDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardsGrid(BuildContext context, List<model.Card> cards) {
    final state = context.read<CardBloc>().state;
    final bool hasMore = state is CardLoadSuccess && state.hasMore;

    return AnimationLimiter(
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: hasMore ? cards.length + 2 : cards.length,
        itemBuilder: (context, index) {
          if (index >= cards.length) {
            // Fill remaining grid slots with empty space or a centered loader if it's the last one
            if (index == cards.length && hasMore) {
               return const Center(child: CircularProgressIndicator());
            }
            return const SizedBox.shrink();
          }
          final card = cards[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildCardGridItem(context, card),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardsListView(BuildContext context, List<model.Card> cards) {
    final state = context.read<CardBloc>().state;
    final bool hasMore = state is CardLoadSuccess && state.hasMore;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: hasMore ? cards.length + 1 : cards.length,
      itemBuilder: (context, index) {
        if (index >= cards.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final card = cards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCardListItem(card),
        );
      },
    );
  }

  Widget _buildCardGridItem(BuildContext context, model.Card card) {
    return GestureDetector(
      onTap: () => _navigateToCardDetail(context, card),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(card.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      card.status?.toUpperCase() ?? 'TODO',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getStatusColor(card.status),
                        fontWeight: FontWeight.bold,
                      ),
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
                      _handleCardAction(context, card, value);
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
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive, size: 18),
                            SizedBox(width: 8),
                            Text('Archive'),
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
                card.title,
                style: AppTextStyles.headline6.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (card.description != null && card.description!.isNotEmpty)
                Text(
                  card.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.comment,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${card.totalComments ?? 0}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.flag,
                    size: 16,
                    color: _getStatusColor(card.status),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    card.status?.toString().toUpperCase() ?? 'TODO',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getStatusColor(card.status),
                      fontWeight: FontWeight.bold,
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

  Widget _buildCardListItem(model.Card card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(card.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.style,
            color: _getStatusColor(card.status),
            size: 24,
          ),
        ),
        title: Text(
          card.title,
          style: AppTextStyles.headline6.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.description != null && card.description!.isNotEmpty)
              Text(
                card.description!,
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
                  Icons.dashboard_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  card.boardTitle ?? 'General',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.flag,
                  size: 14,
                  color: _getStatusColor(card.status),
                ),
                const SizedBox(width: 4),
                Text(
                  card.status?.toUpperCase() ?? 'TODO',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getStatusColor(card.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToCardDetail(context, card),
      ),
    );
  }

  List<model.Card> _filterCards(List<model.Card> cards) {
    return cards.where((card) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final title = card.title.toLowerCase();
        final description = (card.description ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!title.contains(query) && !description.contains(query)) {
          return false;
        }
      }

      // Board filter
      if (_selectedBoard != 'all') {
        if (card.boardId != _selectedBoard) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatus != 'all') {
        final cardStatus = card.status?.toString().toLowerCase() ?? '';
        bool matches = false;
        
        if (_selectedStatus == 'todo') {
          matches = cardStatus == 'todo' || cardStatus == 'to_do' || cardStatus == '';
        } else if (_selectedStatus == 'in_progress') {
          matches = cardStatus == 'started' || cardStatus == 'in_progress';
        } else if (_selectedStatus == 'done') {
          matches = cardStatus == 'done' || cardStatus == 'completed';
        } else {
          matches = cardStatus == _selectedStatus.toLowerCase();
        }
        
        if (!matches) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _hasActiveFilters() {
    return _selectedBoard != 'all' ||
           _selectedStatus != 'all' ||
           _selectedPriority != 'all';
  }

  Color _getPriorityColor(dynamic priority) {
    switch (priority?.toString().toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'todo':
      case 'to_do':
        return AppColors.textSecondary;
      case 'started':
      case 'in_progress':
        return AppColors.primary;
      case 'done':
      case 'completed':
        return AppColors.success;
      case 'review':
        return AppColors.warning;
      case 'blocked':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'all':
        return 'All';
      case 'todo':
      case 'to_do':
        return 'To Do';
      case 'started':
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'done':
      case 'completed':
        return 'Done';
      case 'blocked':
        return 'Blocked';
      default:
        return 'All';
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'all':
        return 'All';
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      case 'critical':
        return 'Critical';
      default:
        return 'All';
    }
  }

  void _navigateToCardDetail(BuildContext context, model.Card card) {
    context.push('/card/${card.id}');
  }

  void _handleCardAction(BuildContext context, model.Card card, String action) {
    switch (action) {
      case 'edit':
        _showEditCardDialog(context, card);
        break;
      case 'archive':
        _archiveCard(context, card);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, card);
        break;
    }
  }

  void _showEditCardDialog(BuildContext context, model.Card card) {
    final titleController = TextEditingController(text: card.title);
    final descriptionController = TextEditingController(text: card.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Card',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Card Title',
                hintText: 'Enter card title',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter card description',
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
              if (titleController.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<CardBloc>().add(
                  UpdateCard(
                    cardId: card.id,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
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

  void _archiveCard(BuildContext context, model.Card card) {
    context.read<CardBloc>().add(DeleteCard(cardId: card.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Card "${card.title}" archived')),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, model.Card card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Card',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${card.title}"? This action cannot be undone.',
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
              context.read<CardBloc>().add(DeleteCard(cardId: card.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Card "${card.title}" deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBoardSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Board',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: BlocBuilder<BoardBloc, BoardState>(
          builder: (context, state) {
            if (state is BoardLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BoardLoadSuccess) {
              final boards = state.boards;
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: boards.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: const Text('All Boards'),
                        leading: const Icon(Icons.all_inclusive),
                        selected: _selectedBoard == 'all',
                        onTap: () {
                          setState(() {
                            _selectedBoard = 'all';
                          });
                          _loadCards();
                          Navigator.pop(context);
                        },
                      );
                    }
                    final board = boards[index - 1];
                    return ListTile(
                      title: Text(board.name),
                      leading: const Icon(Icons.dashboard),
                      selected: _selectedBoard == board.id,
                      onTap: () {
                        setState(() {
                          _selectedBoard = board.id;
                        });
                        _loadCards();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            }
            return const Text('Failed to load boards');
          },
        ),
      ),
    );
  }

  void _showStatusSelector(BuildContext context) {
    final statuses = ['all', 'todo', 'in_progress', 'done', 'blocked'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Status',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: statuses.length,
            itemBuilder: (context, index) {
              final status = statuses[index];
              return ListTile(
                title: Text(_getStatusLabel(status)),
                leading: Icon(
                  Icons.flag,
                  color: _getStatusColor(status == 'all' ? null : status),
                ),
                selected: _selectedStatus == status,
                onTap: () {
                  setState(() {
                    _selectedStatus = status;
                  });
                  _loadCards();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPrioritySelector(BuildContext context) {
    final priorities = ['all', 'critical', 'high', 'medium', 'low'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Priority',
          style: AppTextStyles.headline5.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: priorities.length,
            itemBuilder: (context, index) {
              final priority = priorities[index];
              return ListTile(
                title: Text(_getPriorityLabel(priority)),
                leading: Icon(
                  Icons.priority_high,
                  color: _getPriorityColor(priority == 'all' ? null : priority),
                ),
                selected: _selectedPriority == priority,
                onTap: () {
                  setState(() {
                    _selectedPriority = priority;
                  });
                  _loadCards();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _toggleAssignedToMe() {
    setState(() {
      _showAssignedToMe = !_showAssignedToMe;
    });
    _loadCards();
  }

  void _showFilterDialog(BuildContext context) {
    String tempBoard = _selectedBoard;
    String tempStatus = _selectedStatus;
    String tempPriority = _selectedPriority;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Filter Cards',
            style: AppTextStyles.headline5.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Board', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempBoard,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Boards')),
                    ...(_getBoardOptions()),
                  ],
                  onChanged: (value) => setDialogState(() => tempBoard = value ?? 'all'),
                ),
                const SizedBox(height: 16),
                Text('Status', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'todo', child: Text('To Do')),
                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'done', child: Text('Done')),
                  ],
                  onChanged: (value) => setDialogState(() => tempStatus = value ?? 'all'),
                ),
                const SizedBox(height: 16),
                Text('Priority', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempPriority,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'critical', child: Text('Critical')),
                  ],
                  onChanged: (value) => setDialogState(() => tempPriority = value ?? 'all'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  tempBoard = 'all';
                  tempStatus = 'all';
                  tempPriority = 'all';
                });
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedBoard = tempBoard;
                  _selectedStatus = tempStatus;
                  _selectedPriority = tempPriority;
                });
                _loadCards();
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
  
  List<DropdownMenuItem<String>> _getBoardOptions() {
    final boardState = context.read<BoardBloc>().state;
    if (boardState is BoardLoadSuccess) {
      return boardState.boards.map((board) => DropdownMenuItem(
        value: board.id,
        child: Text(board.name),
      )).toList();
    }
    return [];
  }

  List<Map<String, String>> _getBoardSelectionOptions() {
    final boardState = context.read<BoardBloc>().state;
    if (boardState is BoardLoadSuccess) {
      return boardState.boards
          .map((board) => {'id': board.id, 'name': board.name})
          .toList();
    }
    return [];
  }

  void _showCreateCardDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final boardsMap = _getBoardSelectionOptions();

    if (boardsMap.isEmpty) {
      // Show a helpful dialog instead of just a snackbar
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'No Boards Available',
            style: AppTextStyles.headline5.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            'You need to create a board before adding cards. Would you like to create a board now?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showCreateBoardDialog(context);
              },
              child: const Text('Create Board'),
            ),
          ],
        ),
      );
      return;
    }

    String selectedBoardId = _selectedBoard != 'all'
        ? _selectedBoard
        : boardsMap.first['id'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Create New Card',
            style: AppTextStyles.headline5.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBoardId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Board',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: boardsMap
                    .map((board) => DropdownMenuItem(
                          value: board['id'],
                          child: Text(board['name'] ?? ''),
                        ))
                    .toList(),
                onChanged: (value) => setDialogState(() => selectedBoardId = value ?? selectedBoardId),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Card Title',
                  hintText: 'Enter card title',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter card description',
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
                if (titleController.text.isNotEmpty && selectedBoardId.isNotEmpty) {
                  Navigator.pop(context);
                  context.read<CardBloc>().add(
                    CreateCard(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      boardId: selectedBoardId,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateBoardDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create New Board',
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
                labelText: 'Board Name',
                hintText: 'Enter board name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter board description',
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
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final authState = context.read<AuthBloc>().state;
                String? teamId;
                if (authState is Authenticated) {
                  teamId = authState.teamId;
                }
                
                Navigator.pop(context);
                context.read<BoardBloc>().add(
                  CreateBoard(
                    teamId: teamId,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  ),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Board created! You can now add cards.'),
                  ),
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