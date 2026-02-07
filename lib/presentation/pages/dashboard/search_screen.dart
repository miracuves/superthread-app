import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/boards/board_bloc.dart';
import '../../bloc/cards/card_bloc.dart';
import '../../bloc/notes/note_bloc.dart';
import '../../bloc/search/search_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/services/api/api_models.dart';
import '../../widgets/custom_button.dart';

class SearchScreen extends StatefulWidget {
  final String? query;

  const SearchScreen({super.key, this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedType = 'all';
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Load initial data
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<BoardBloc>().add(const LoadBoards());
    context.read<CardBloc>().add(const LoadCards());
    context.read<NoteBloc>().add(const LoadNotes());

    // If query is provided, perform search immediately
    if (widget.query != null && widget.query!.isNotEmpty) {
      _searchController.text = widget.query!;
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: AppTextStyles.headline3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _showSearchHistory(context),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: (value) {
              setState(() {
                _selectedType = value;
              });
              if (_searchController.text.isNotEmpty) {
                _performSearchWithQuery(_searchController.text);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 18),
                    SizedBox(width: 8),
                    Text('All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'projects',
                child: Row(
                  children: [
                    Icon(Icons.dashboard, size: 18),
                    SizedBox(width: 8),
                    Text('Projects'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cards',
                child: Row(
                  children: [
                    Icon(Icons.style, size: 18),
                    SizedBox(width: 8),
                    Text('Cards'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'notes',
                child: Row(
                  children: [
                    Icon(Icons.note_alt, size: 18),
                    SizedBox(width: 8),
                    Text('Notes'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildSearchFilters(context),
          Expanded(child: _buildSearchResults(context)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search projects, cards, and notes...',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {});
                context.read<SearchBloc>().add(ClearSearch());
              })
              : null,
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
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _performSearchWithQuery(value);
          }
        },
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && value.length >= 2) {
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated) {
              context.read<SearchBloc>().add(
                GetSearchSuggestions(
                  teamId: authState.teamId,
                  query: value,
                ),
              );
            }
          } else {
            context.read<SearchBloc>().add(const ClearSearch());
          }
        },
      ),
    );
  }

  Widget _buildSearchFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context: context,
              label: 'All',
              icon: Icons.all_inclusive,
              isSelected: _selectedType == 'all',
              onTap: () => setState(() => _selectedType = 'all'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context: context,
              label: 'Projects',
              icon: Icons.dashboard,
              isSelected: _selectedType == 'projects',
              onTap: () => setState(() => _selectedType = 'projects'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context: context,
              label: 'Cards',
              icon: Icons.style,
              isSelected: _selectedType == 'cards',
              onTap: () => setState(() => _selectedType = 'cards'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context: context,
              label: 'Notes',
              icon: Icons.note_alt,
              isSelected: _selectedType == 'notes',
              onTap: () => setState(() => _selectedType = 'notes'),
            ),
          ],
        ),
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

  Widget _buildSearchResults(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return _buildSearchInitialState(context);
        } else if (state is SearchLoading) {
          return _buildSearchInProgress();
        } else if (state is SearchLoaded) {
          if (state.searchResponse.results.isEmpty) {
            return _buildNoResultsState(context);
          }
          _animationController.forward();
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSearchResultsList(context, state.searchResponse.results),
          );
        } else if (state is SearchSuggestionsLoaded) {
          return _buildSearchSuggestions(context, state.suggestions.map((s) => s.text).toList());
        } else if (state is SearchError) {
          return _buildSearchErrorState(context, state.message);
        } else {
          return _buildSearchInitialState(context);
        }
      },
    );
  }

  Widget _buildSearchInitialState(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildQuickSearches(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: AppTextStyles.headline6.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _searchHistory.map((term) {
              return InputChip(
                label: Text(term),
                onPressed: () {
                  _searchController.text = term;
                  _performSearchWithQuery(term);
                },
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _searchHistory.remove(term);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInProgress() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching...'),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(BuildContext context, List results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildSearchResultItem(context, result, index);
      },
    );
  }

  Widget _buildSearchResultItem(BuildContext context, dynamic result, int index) {
    final searchResult = result as SearchResult;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              color: _getTypeColor(searchResult.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(searchResult.type),
              color: _getTypeColor(searchResult.type),
              size: 24,
            ),
          ),
          title: Text(
            searchResult.title,
            style: AppTextStyles.headline6.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (searchResult.content != null && searchResult.content!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    searchResult.content!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(searchResult.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getTypeLabel(searchResult.type).toUpperCase(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getTypeColor(searchResult.type),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (searchResult.updatedAt != null)
                    Text(
                      _formatTimestamp(searchResult.updatedAt!.toIso8601String()),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateToResult(context, searchResult),
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: AppTextStyles.headline4.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Clear Search',
                icon: Icons.clear,
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                  context.read<SearchBloc>().add(ClearSearch());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchErrorState(BuildContext context, String message) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
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
                'Search Error',
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
                  if (_searchController.text.isNotEmpty) {
                    _performSearchWithQuery(_searchController.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _performSearchWithQuery(query);
  }

  void _performSearchWithQuery(String query) {
    if (query.trim().isEmpty) return;

    // Get teamId from auth state
    final authState = context.read<AuthBloc>().state;
    String? teamId;
    if (authState is Authenticated) {
      teamId = authState.teamId;
    }

    // Add to search history
    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.take(10).toList();
      }
    });

    context.read<SearchBloc>().add(
      PerformSearch(
        teamId: teamId ?? '',
        query: query.trim(),
        type: _selectedType == 'all' ? null : _selectedType,
      ),
    );
  }

  void _showSearchHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _searchHistory.isEmpty
              ? const Center(
            child: Text('No search history yet'),
          )
              : ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_searchHistory[index]),
                leading: const Icon(Icons.history),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _searchHistory.removeAt(index);
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  _searchController.text = _searchHistory[index];
                  _performSearchWithQuery(_searchHistory[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_searchHistory.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchHistory.clear();
                });
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'board':
        return AppColors.primary;
      case 'card':
        return AppColors.secondary;
      case 'note':
        return AppColors.accent;
      case 'list':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'board':
        return Icons.dashboard;
      case 'card':
        return Icons.style;
      case 'note':
        return Icons.note_alt;
      case 'list':
        return Icons.list;
      default:
        return Icons.description;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'board':
        return 'Board';
      case 'card':
        return 'Card';
      case 'note':
        return 'Note';
      case 'list':
        return 'List';
      default:
        return 'Item';
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return 'Older';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _navigateToResult(BuildContext context, SearchResult result) {
    // Navigate to the appropriate detail screen based on type
    switch (result.type) {
      case 'board':
        context.pushNamed(
          'kanban-board',
          pathParameters: {'boardId': result.id},
          queryParameters: {'name': result.title},
        );
        break;
      case 'card':
        context.pushNamed(
          'card-detail',
          pathParameters: {'cardId': result.id},
        );
        break;
      case 'note':
        context.pushNamed(
          'note-edit',
          pathParameters: {'id': result.id},
        );
        break;
      case 'page':
        context.pushNamed(
          'page-edit',
          pathParameters: {'id': result.id},
        );
        break;
      case 'list':
        if (result.boardId != null) {
          context.pushNamed(
            'kanban-board',
            pathParameters: {'boardId': result.boardId!},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening list: ${result.title}')),
          );
        }
        break;
      default:
      // Attempt to navigate based on IDs if type is ambiguous but IDs are present
        if (result.boardId != null) {
          context.pushNamed(
            'kanban-board',
            pathParameters: {'boardId': result.boardId!},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${result.type}: ${result.title}')),
          );
        }
    }
  }

  Widget _buildSearchSuggestions(BuildContext context, List<String> suggestions) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggestions',
            style: AppTextStyles.headline6.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return InputChip(
                label: Text(suggestion),
                onPressed: () {
                  _searchController.text = suggestion;
                  _performSearchWithQuery(suggestion);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
