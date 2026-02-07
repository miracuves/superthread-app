import 'package:flutter/material.dart';
import '../../../data/models/card.dart';

class ThreadedCommentWidget extends StatefulWidget {
  final Comment comment;
  final int depth;
  final int maxDepth;
  final VoidCallback? onReply;
  final bool isInitiallyExpanded;
  const ThreadedCommentWidget({Key? key, required this.comment, this.depth = 0, this.maxDepth = 5, this.onReply, this.isInitiallyExpanded = true}) : super(key: key);
  @override
  State<ThreadedCommentWidget> createState() => _ThreadedCommentWidgetState();
}

class _ThreadedCommentWidgetState extends State<ThreadedCommentWidget> {
  late bool _expanded;
  @override
  void initState() { super.initState(); _expanded = widget.isInitiallyExpanded; }
  void _toggle() { setState(() { _expanded = !_expanded; }); }
  
  @override
  Widget build(BuildContext context) {
    final replies = widget.comment.replies ?? [];
    final hasReplies = replies.isNotEmpty;
    final canNest = widget.depth < widget.maxDepth;
    return Container(
      margin: EdgeInsets.only(left: widget.depth * 16.0),
      decoration: widget.depth > 0 ? BoxDecoration(border: Border(left: BorderSide(color: Colors.grey[300]!, width: 2))) : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(margin: const EdgeInsets.symmetric(vertical: 4), child: Padding(padding: const EdgeInsets.all(12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(radius: 16, backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: Text(widget.comment.authorName.isNotEmpty ? widget.comment.authorName[0].toUpperCase() : '?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.comment.authorName.isNotEmpty ? widget.comment.authorName : 'Anonymous', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(_formatTime(widget.comment.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ])),
            ]),
            const SizedBox(height: 8),
            Text(widget.comment.content, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              TextButton.icon(onPressed: widget.onReply, icon: const Icon(Icons.reply, size: 16), label: const Text('Reply'), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
              if (hasReplies) TextButton.icon(onPressed: _toggle, icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 16), label: Text(_expanded ? 'Hide' : replies.length.toString() + ' replies'), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
            ]),
          ],
        ))),
        if (hasReplies && canNest) ...[
          if (!_expanded)
            TextButton.icon(onPressed: _toggle, icon: const Icon(Icons.expand_more, size: 16), label: Text('Show ' + replies.length.toString() + ' replies'))
          else
            ...replies.map((r) => Padding(padding: const EdgeInsets.only(top: 8), child: ThreadedCommentWidget(comment: r, depth: widget.depth + 1, maxDepth: widget.maxDepth, onReply: widget.onReply))),
        ],
      ]),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return diff.inMinutes.toString() + 'm ago';
    if (diff.inHours < 24) return diff.inHours.toString() + 'h ago';
    if (diff.inDays < 7) return diff.inDays.toString() + 'd ago';
    return dt.day.toString() + '/' + dt.month.toString() + '/' + dt.year.toString();
  }
}

class ThreadedCommentsList extends StatelessWidget {
  final List<Comment> comments;
  final String? emptyMessage;
  final Function(Comment)? onReply;
  const ThreadedCommentsList({Key? key, required this.comments, this.emptyMessage, this.onReply}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) return Padding(padding: const EdgeInsets.all(16), child: Center(child: Text(emptyMessage ?? 'No comments', style: TextStyle(color: Colors.grey[600]))));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Row(children: [
        const Icon(Icons.comment, size: 18), const SizedBox(width: 8), Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(comments.length.toString(), style: TextStyle(fontSize: 12))),
      ])),
      ...comments.map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ThreadedCommentWidget(comment: c, onReply: onReply != null ? () => onReply!(c) : null))),
    ]);
  }
}
