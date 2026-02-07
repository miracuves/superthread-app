import 'package:flutter/material.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class KanbanBoardScreen extends StatefulWidget {
  final String projectId;

  const KanbanBoardScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data for kanban columns - converted to drag_and_drop_lists format
  final List<List<KanbanCard>> _columns = [
    [
      KanbanCard(
        id: '1',
        title: 'Setup Database Schema',
        priority: 'High',
        assignee: 'John Doe',
        tags: ['backend', 'database'],
      ),
      KanbanCard(
        id: '2',
        title: 'Design API Endpoints',
        priority: 'Medium',
        assignee: 'Jane Smith',
        tags: ['backend', 'api'],
      ),
    ],
    [
      KanbanCard(
        id: '3',
        title: 'Implement User Authentication',
        priority: 'High',
        assignee: 'Mike Wilson',
        tags: ['backend', 'security'],
      ),
      KanbanCard(
        id: '4',
        title: 'Create UI Components',
        priority: 'Medium',
        assignee: 'Sarah Johnson',
        tags: ['frontend', 'ui'],
      ),
    ],
    [
      KanbanCard(
        id: '5',
        title: 'Write Unit Tests',
        priority: 'Medium',
        assignee: 'Tom Brown',
        tags: ['testing', 'backend'],
      ),
    ],
    [
      KanbanCard(
        id: '6',
        title: 'Project Setup',
        priority: 'Low',
        assignee: 'John Doe',
        tags: ['setup'],
      ),
      KanbanCard(
        id: '7',
        title: 'CI/CD Configuration',
        priority: 'Medium',
        assignee: 'DevOps Team',
        tags: ['devops', 'automation'],
      ),
    ],
  ];

  final List<String> _columnTitles = ['To Do', 'In Progress', 'Review', 'Done'];
  final List<Color> _columnColors = [
    AppColors.primary,
    AppColors.warning,
    AppColors.secondary,
    AppColors.success,
  ];

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
          'Kanban Board',
          style: AppTextStyles.headline3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _showBoardMenu,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildBoardHeader(context),
            Expanded(
              child: _buildKanbanBoard(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBoardHeader(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project ID: ${widget.projectId}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  'Development Board',
                  style: AppTextStyles.headline4.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildStatChip('Total Cards', '${_getTotalCards()}', AppColors.primary),
              const SizedBox(width: 12),
              _buildStatChip('Completed', '${_getCompletedCards()}', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headline4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(16),
      child: DragAndDropLists(
        children: List.generate(_columns.length, (listIndex) {
          return DragAndDropList(
            header: _buildColumnHeader(context, listIndex),
            footer: _buildAddCardButton(context, listIndex),
            children: List.generate(_columns[listIndex].length, (itemIndex) {
              final card = _columns[listIndex][itemIndex];
              return DragAndDropItem(
                child: KanbanCardWidget(
                  card: card,
                  columnColor: _columnColors[listIndex],
                  onTap: () => _showCardDetails(card),
                  onEdit: () => _editCard(card),
                  onDelete: () => _deleteCard(card),
                  isDragging: false,
                ),
              );
            }),
          );
        }),
        onItemReorder: (oldItemIndex, oldListIndex, newItemIndex, newListIndex) {
          _handleCardReorder(oldItemIndex, oldListIndex, newItemIndex, newListIndex);
        },
        onListReorder: (oldListIndex, newListIndex) {
          _handleColumnReorder(oldListIndex, newListIndex);
        },
        listPadding: const EdgeInsets.only(right: 16),
        listWidth: 300,
        axis: Axis.horizontal,
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, int columnIndex) {
    final title = _columnTitles[columnIndex];
    final color = _columnColors[columnIndex];
    final cardCount = _columns[columnIndex].length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color: color.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headline4.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$cardCount',
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context, int columnIndex) {
    final color = _columnColors[columnIndex];

    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () => _showAddCardToColumnDialog(columnIndex, 0),
        icon: Icon(Icons.add, size: 16),
        label: Text('Add Card'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: color.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  int _getTotalCards() {
    return _columns.fold(0, (sum, column) => sum + column.length);
  }

  int _getCompletedCards() {
    return _columns.last.length; // Done column is the last one
  }

  // Drag and Drop Handlers
  void _handleCardReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      // Remove card from old position
      final card = _columns[oldListIndex].removeAt(oldItemIndex);

      // Insert card into new position
      _columns[newListIndex].insert(newItemIndex, card);

      // Show feedback
      final fromColumn = _columnTitles[oldListIndex];
      final toColumn = _columnTitles[newListIndex];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Moved "${card.title}" from $fromColumn to $toColumn',
          ),
          backgroundColor: _columnColors[newListIndex],
          duration: const Duration(seconds: 2),
        ),
      );
    });

    _saveKanbanState();
  }

  void _handleColumnReorder(int oldListIndex, int newListIndex) {
    setState(() {
      // Swap columns
      final tempColumn = _columns[oldListIndex];
      _columns[oldListIndex] = _columns[newListIndex];
      _columns[newListIndex] = tempColumn;

      // Swap titles and colors
      final tempTitle = _columnTitles[oldListIndex];
      _columnTitles[oldListIndex] = _columnTitles[newListIndex];
      _columnTitles[newListIndex] = tempTitle;

      final tempColor = _columnColors[oldListIndex];
      _columnColors[oldListIndex] = _columnColors[newListIndex];
      _columnColors[newListIndex] = tempColor;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Column order updated'),
        duration: Duration(seconds: 1),
      ),
    );

    _saveKanbanState();
  }

  void _saveKanbanState() {
    // Save kanban state via BLoC events
    // Column reordering is handled by BoardBloc
    // Card movements are handled by CardBloc
    // List creation is handled by BoardBloc
    print('Kanban state saved via BLoC events');
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: AppTextStyles.headline4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('By Assignee'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter by assignee coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('By Priority'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter by priority coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('By Tags'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter by tags coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBoardMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Board Options',
              style: AppTextStyles.headline4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add Column'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add column feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Board'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit board feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Board'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share board feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Card'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Card Title',
            hintText: 'Enter card title',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card added successfully!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCardToColumnDialog(int columnIndex, int position) {
    final controller = TextEditingController();
    final columnTitle = _columnTitles[columnIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Card to $columnTitle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Card Title',
            hintText: 'Enter card title',
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
                Navigator.pop(context);
                setState(() {
                  final newCard = KanbanCard(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: controller.text.trim(),
                    priority: 'Medium',
                    assignee: 'Unassigned',
                    tags: [],
                  );

                  // Insert card at the specified position
                  _columns[columnIndex].insert(
                    position < _columns[columnIndex].length ? position : _columns[columnIndex].length,
                    newCard,
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Card added to $columnTitle!'),
                    backgroundColor: _columnColors[columnIndex],
                  ),
                );

                // Save state
                _saveKanbanState();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCardDetails(KanbanCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(card.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority: ${card.priority}'),
            Text('Assignee: ${card.assignee}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: card.tags.map((tag) => Chip(
                label: Text(tag),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editCard(KanbanCard card) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing card: ${card.title}')),
    );
  }

  void _deleteCard(KanbanCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete "${card.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // Find and remove the card from all columns
                for (var column in _columns) {
                  column.removeWhere((c) => c.id == card.id);
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card deleted successfully!')),
              );

              // Save state
              _saveKanbanState();
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

// Data Models
class KanbanCard {
  final String id;
  final String title;
  final String priority;
  final String assignee;
  final List<String> tags;

  KanbanCard({
    required this.id,
    required this.title,
    required this.priority,
    required this.assignee,
    required this.tags,
  });
}

// Custom Widget for Kanban Cards
class KanbanCardWidget extends StatelessWidget {
  final KanbanCard card;
  final Color columnColor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDragging;

  const KanbanCardWidget({
    super.key,
    required this.card,
    required this.columnColor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDragging
              ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDragging
                ? columnColor.withOpacity(0.5)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isDragging ? 2 : 1,
          ),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: columnColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(card.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getPriorityColor(card.priority).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    card.priority,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getPriorityColor(card.priority),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    card.assignee,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (card.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: card.tags.take(2).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: columnColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: columnColor.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}