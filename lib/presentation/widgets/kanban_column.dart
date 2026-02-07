import 'package:flutter/material.dart';
import '../../data/models/board.dart';
import '../../data/models/card.dart' as card_model;

class KanbanColumn extends StatelessWidget {
  final BoardList list;
  final List<card_model.Card> cards;
  final Function(String cardId, String newListId, int newPosition)? onCardReordered;
  final Function(card_model.Card card)? onCardTapped;

  const KanbanColumn({
    super.key,
    required this.list,
    required this.cards,
    this.onCardReordered,
    this.onCardTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              list.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: cards.isEmpty
                ? const Center(
                    child: Text(
                      'No cards',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            card.title,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: (card.description?.isNotEmpty ?? false)
                              ? Text(
                                  card.description!,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () => onCardTapped?.call(card),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}