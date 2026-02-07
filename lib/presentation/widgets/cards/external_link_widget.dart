import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/external_link.dart';

class ExternalLinkWidget extends StatelessWidget {
  final ExternalLink externalLink;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ExternalLinkWidget({
    Key? key,
    required this.externalLink,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap ?? () => _launchLink(context),
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final type = externalLink.type.toLowerCase();
    if (type == 'github' || type == 'gitlab') {
      return _buildGitHubPr(context);
    }
    return _buildGenericLink(context);
  }

  Widget _buildGitHubPr(BuildContext context) {
    final pr = externalLink.githubPullRequest;
    if (pr == null) return const SizedBox.shrink();

    return Row(
      children: [
        _buildStatusIcon(pr.state, pr.merged),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PR #' + pr.number.toString(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pr.title ?? 'No title',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (pr.head != null) ...[
                const SizedBox(height: 4),
                Text(
                  pr.head!.ref + ' -> main',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.open_in_new,
          size: 16,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildGenericLink(BuildContext context) {
    final generic = externalLink.generic;
    if (generic == null) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(Icons.link, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                generic.displayText ?? _extractDomain(generic.url),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                generic.url,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.open_in_new,
          size: 16,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildStatusIcon(String? state, bool? merged) {
    if (merged == true) {
      return const Icon(Icons.merge_type, color: Colors.purple, size: 24);
    }

    switch (state?.toLowerCase()) {
      case 'open':
        return const Icon(Icons.radio_button_unchecked, color: Colors.green, size: 24);
      case 'closed':
        return const Icon(Icons.close_circle, color: Colors.red, size: 24);
      case 'merged':
        return const Icon(Icons.merge_type, color: Colors.purple, size: 24);
      case 'draft':
        return const Icon(Icons.drafts, color: Colors.grey, size: 24);
      default:
        return const Icon(Icons.link, color: Colors.grey, size: 24);
    }
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  Future<void> _launchLink(BuildContext context) async {
    String url = '';
    final type = externalLink.type.toLowerCase();
    if (type == 'github' || type == 'gitlab') {
      url = externalLink.githubPullRequest?.htmlUrl ?? '';
    } else {
      url = externalLink.generic?.url ?? '';
    }

    if (url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No URL available')),
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch ' + url)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: ' + e.toString())),
        );
      }
    }
  }
}

class ExternalLinksList extends StatelessWidget {
  final List<ExternalLink> links;
  final String? emptyMessage;

  const ExternalLinksList({
    Key? key,
    required this.links,
    this.emptyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            emptyMessage ?? 'No external links',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.link, size: 18),
              const SizedBox(width: 8),
              Text(
                'External Links',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  links.length.toString(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
        ...links.map((link) => ExternalLinkWidget(externalLink: link)),
      ],
    );
  }
}
