import 'package:flutter/material.dart';
import '../../../data/models/card_hint.dart';

class CardHintWidget extends StatelessWidget {
  final CardHint hint;
  final VoidCallback? onDismiss;
  final VoidCallback? onApply;
  const CardHintWidget({Key? key, required this.hint, this.onDismiss, this.onApply}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue[200]!)),
      child: Row(children: [
        const Icon(Icons.lightbulb_outline, color: Colors.amber),
        const SizedBox(width: 12),
        Expanded(child: hint.type == 'tag' && hint.tag != null 
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Suggested tag:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Chip(label: Text(hint.tag!.name), backgroundColor: Colors.blue[100]),
            ])
          : hint.relation != null 
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Related (${((hint.relation!.similarity ?? 0) * 100).toInt()}%)', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(hint.relation!.card.title, style: TextStyle(fontWeight: FontWeight.w500)),
              ])
            : const SizedBox.shrink()),
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (onApply != null && hint.type == 'tag') TextButton(onPressed: onApply, child: const Text('Apply', style: TextStyle(fontSize: 12))),
          if (onDismiss != null) TextButton(onPressed: onDismiss, child: const Text('Dismiss', style: TextStyle(fontSize: 12))),
        ]),
      ]),
    );
  }
}
