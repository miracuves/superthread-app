import 'package:flutter/material.dart';

class EstimateWidget extends StatelessWidget {
  final int? estimate;
  final VoidCallback? onTap;
  const EstimateWidget({Key? key, this.estimate, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (estimate == null) return const SizedBox.shrink();
    Color col = Colors.green;
    if (estimate! > 2) col = Colors.blue;
    if (estimate! > 5) col = Colors.orange;
    if (estimate! > 8) col = Colors.red;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: col)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bar_chart, size: 14, color: col),
          const SizedBox(width: 4),
          Text('$estimate', style: TextStyle(color: col, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
