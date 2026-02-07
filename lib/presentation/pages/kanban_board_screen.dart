import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/boards/board_bloc.dart';
import '../bloc/cards/card_bloc.dart';
import '../bloc/boards/board_event.dart';
import '../bloc/cards/card_event.dart';
import '../bloc/boards/board_state.dart';
import '../bloc/cards/card_state.dart';
import '../../data/models/board.dart';
import '../../data/models/card.dart' as card_model;
import '../widgets/kanban_column.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as custom;

class KanbanBoardScreen extends StatefulWidget {
  final String boardId;
  final String boardName;

  const KanbanBoardScreen({
    super.key,
    required this.boardId,
    required this.boardName,
  });

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  @override
  void initState() {
    super.initState();
    _loadBoardDetails();
  }

  void _loadBoardDetails() {
    context.read<BoardBloc>().add(LoadBoardDetails(boardId: widget.boardId));
    
    // Try to get teamId from AuthBloc if available
    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }
    
    context.read<CardBloc>().add(LoadCards(
      teamId: teamId,
      boardId: widget.boardId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCardDialog,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BoardBloc, BoardState>(
            listener: (context, boardState) {
              if (boardState is BoardDetailsLoaded) {
                // If the resolved board ID is different from the one we started with
                // (e.g. we started with an Epic ID), re-load cards with the correct board ID
                if (boardState.board.id != widget.boardId) {
                  final authState = context.read<AuthBloc>().state;
                  String? teamId;
                  if (authState is Authenticated) {
                    teamId = authState.teamId;
                  }
                  context.read<CardBloc>().add(LoadCards(
                    teamId: teamId,
                    boardId: boardState.board.id,
                  ));
                }
              }
            },
          ),
          BlocListener<CardBloc, CardState>(
            listener: (context, cardState) {
              if (cardState is CardOperationSuccess) {
                // Reload board details to get fresh card data
                _loadBoardDetails();
              }
            },
          ),
        ],
        child: BlocBuilder<BoardBloc, BoardState>(
          builder: (context, boardState) {
            if (boardState is BoardLoadInProgress) {
              return const LoadingWidget();
            }

            if (boardState is BoardLoadFailure) {
              return custom.ErrorWidget(
                message: boardState.error,
                onRetry: _loadBoardDetails,
              );
            }

            if (boardState is BoardDetailsLoaded) {
              return BlocBuilder<CardBloc, CardState>(
                builder: (context, cardState) {
                  if (cardState is CardLoadInProgress) {
                    return const LoadingWidget();
                  }

                  if (cardState is CardLoadFailure) {
                    // Check if board.lists already have pre-loaded cards
                    final hasPreLoadedCards = boardState.board.lists?.any(
                      (list) => list.cards != null && list.cards!.isNotEmpty
                    ) ?? false;
                    
                    if (hasPreLoadedCards) {
                      // Show board anyway using pre-loaded cards
                      return _buildKanbanBoard(boardState.board, const []);
                    }
                    
                    return custom.ErrorWidget(
                      message: cardState.error,
                      onRetry: () => context.read<CardBloc>().add(LoadCards(
                        teamId: boardState.board.teamId,
                        boardId: boardState.board.id,
                      )),
                    );
                  }

                  if (cardState is CardLoadSuccess) {
                    return _buildKanbanBoard(boardState.board, cardState.cards);
                  }

                  // For any other state (initial, loading complete but no success yet),
                  // show pre-loaded cards from board.lists if available
                  final hasPreLoadedCards = boardState.board.lists?.any(
                    (list) => list.cards != null && list.cards!.isNotEmpty
                  ) ?? false;
                  
                  if (hasPreLoadedCards) {
                    return _buildKanbanBoard(boardState.board, const []);
                  }

                  return const SizedBox.shrink();
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildKanbanBoard(Board board, List<card_model.Card> cards) {
    final lists = board.lists ?? [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lists.map((list) {
          // Merge cards from CardBloc with pre-loaded cards from the list
          // This ensures we show cards even if CardBloc hasn't finished or has a filtered view
          final blocCards = cards.where((card) => card.listId == list.id).toList();
          final preLoadedCards = list.cards ?? [];
          
          // Use a Map to de-duplicate by ID, prioritizing blocCards
          final mergedCardsMap = {
            for (var c in preLoadedCards) c.id: c,
            for (var c in blocCards) c.id: c,
          };
          final listCards = mergedCardsMap.values.toList();

          return SizedBox(
            width: 310, // Fixed width for each column to prevent squashing
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: KanbanColumn(
                list: list,
                cards: listCards,
                onCardReordered: _handleCardReorder,
                onCardTapped: _handleCardTap,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleCardReorder(String cardId, String newListId, int newPosition) {
    context.read<CardBloc>().add(MoveCard(
      cardId: cardId,
      newListId: newListId,
      newPosition: newPosition,
    ));
  }

  void _handleCardTap(card_model.Card card) {
    context.push('/card/${card.id}');
  }

  void _showAddCardDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    // Get the current board state to access lists
    final boardState = context.read<BoardBloc>().state;
    List<BoardList> availableLists = [];
    String? selectedListId;
    
    if (boardState is BoardDetailsLoaded) {
      availableLists = boardState.board.lists ?? [];
      if (availableLists.isNotEmpty) {
        selectedListId = availableLists.first.id;
      }
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Card Title',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              if (availableLists.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedListId,
                  decoration: const InputDecoration(
                    labelText: 'Add to Column',
                    border: OutlineInputBorder(),
                  ),
                  items: availableLists.map((list) => DropdownMenuItem(
                    value: list.id,
                    child: Text(list.name),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedListId = value;
                    });
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  Navigator.pop(dialogContext);

                  // Get teamId from auth state
                  final authState = this.context.read<AuthBloc>().state;
                  String? teamId;
                  if (authState is Authenticated) {
                    teamId = authState.teamId;
                  }
                  
                  // Create card using CardBloc with listId
                  this.context.read<CardBloc>().add(
                    CreateCard(
                      teamId: teamId,
                      boardId: widget.boardId,
                      listId: selectedListId,
                      title: title,
                      description: descriptionController.text.trim(),
                    ),
                  );
                  
                  // Show success feedback
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Card "$title" created!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}