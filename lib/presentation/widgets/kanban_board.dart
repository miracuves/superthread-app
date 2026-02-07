import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/board.dart';
import '../../../data/models/card.dart' as superthread_card;
import '../bloc/cards/card_bloc.dart';
import '../bloc/boards/board_bloc.dart';
import '../../../data/models/requests/create_board_request.dart';
import '../../../data/models/requests/create_card_request.dart';
import '../../../data/models/requests/update_card_request.dart';

class KanbanBoard extends StatefulWidget {
  final Board board;
  final String teamId;

  const KanbanBoard({
    super.key,
    required this.board,
    required this.teamId,
  });

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final Map<String, List<superthread_card.Card>> _cardsByList = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    for (final list in widget.board.lists ?? []) {
      _cardsByList[list.id] = [];
    }

    // Load cards for each list
    for (final list in widget.board.lists ?? []) {
      if (mounted) {
        context.read<CardBloc>().add(LoadCards(
          teamId: widget.teamId,
          boardId: widget.board.id,
          listId: list.id,
        ));
      }
    }
  }

  void _onDragStarted(List<BoardList> lists, int listIndex, int cardIndex, [dynamic details]) {
    // Card drag started - could add visual feedback here
  }

  void _onDragEnded(List<BoardList>? lists, int fromListIndex, int fromCardIndex, int? toListIndex, int? toCardIndex) {
    if (toListIndex == null || toCardIndex == null || lists == null) return;
    if (fromListIndex < 0 || fromListIndex >= lists.length || toListIndex < 0 || toListIndex >= lists.length) return;

    final card = _cardsByList[lists[fromListIndex].id]?[fromCardIndex];
    if (card == null) return;

    final fromList = lists[fromListIndex];
    final toList = lists[toListIndex];

    // Move card in backend
    context.read<CardBloc>().add(MoveCard(
      cardId: card.id,
      newListId: toList.id,
      newPosition: toCardIndex,
    ));

    // Update local state immediately for better UX
    setState(() {
      _cardsByList[fromList.id]?.removeAt(fromCardIndex);
      _cardsByList[toList.id]?.insert(toCardIndex, card);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddListDialog,
          ),
        ],
      ),
      body: Row(
        children: (widget.board.lists ?? []).map((list) {
          final cards = _cardsByList[list.id] ?? [];
          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            list.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cards.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: DragTarget<List>(
                      onAcceptWithDetails: (details) {
                        final data = details.data;
                        final fromListIndex = data[0] as int;
                        final fromCardIndex = data[1] as int;
                        final currentListIndex = widget.board.lists?.indexOf(list) ?? -1;

                        _onDragEnded(
                          widget.board.lists ?? [],
                          fromListIndex,
                          fromCardIndex,
                          currentListIndex,
                          cards.length,
                        );
                      },
                      builder: (context, candidateData, rejectedData) {
                        return _buildCardList(list, cards);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _showAddCardDialog(list),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add card'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardList(BoardList list, List<superthread_card.Card> cards) {
    if (cards.isEmpty) {
      return Container(
        height: double.infinity,
        child: const Center(
          child: Text(
            'No cards yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final listIndex = widget.board.lists?.indexOf(list) ?? -1;

        return DraggableCard(
          key: ValueKey(card.id),
          card: card,
          listIndex: listIndex,
          cardIndex: index,
          onDragStarted: (List<BoardList>? lists, int listIdx, int cardIdx, [dynamic? details]) => _onDragStarted(widget.board.lists ?? [], listIndex, index),
          onTap: () => _showCardDetails(card),
        );
      },
    );
  }

  void _showAddListDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'List name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<BoardBloc>().add(AddBoardList(
                  boardId: widget.board.id,
                  name: controller.text,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog(BoardList list) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Card title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                border: OutlineInputBorder(),
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
                context.read<CardBloc>().add(CreateCard(
                  teamId: widget.teamId,
                  request: CreateCardRequest(
                    title: titleController.text,
                    boardId: widget.board.id,
                    listId: list.id,
                    content: contentController.text.trim().isNotEmpty ? contentController.text : null,
                  ),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCardDetails(superthread_card.Card card) {
    Navigator.of(context).pushNamed('/card-details', arguments: card);
  }
}

class DraggableCard extends StatelessWidget {
  final superthread_card.Card card;
  final int listIndex;
  final int cardIndex;
  final Function(List<BoardList>?, int, int, [dynamic?]) onDragStarted;
  final VoidCallback onTap;

  const DraggableCard({
    super.key,
    required this.card,
    required this.listIndex,
    required this.cardIndex,
    required this.onDragStarted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Draggable<List>(
        data: [listIndex, cardIndex],
        feedback: Material(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (card.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    card.description!,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
        childWhenDragging: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onDragStarted: () => onDragStarted([], 0, 0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (card.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    card.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (card.tags?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: card.tags!.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardDragFeedback extends StatelessWidget {
  final superthread_card.Card card;

  const CardDragFeedback({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              card.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (card.description?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                card.description!,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CardDragPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}