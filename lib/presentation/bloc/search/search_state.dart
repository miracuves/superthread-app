part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final SearchResponse searchResponse;
  final String currentQuery;
  final Map<String, dynamic> currentFilters;

  const SearchLoaded({
    required this.searchResponse,
    required this.currentQuery,
    required this.currentFilters,
  });

  @override
  List<Object?> get props => [searchResponse, currentQuery, currentFilters];
}

class SearchSuggestionsLoaded extends SearchState {
  final List<SearchSuggestion> suggestions;

  const SearchSuggestionsLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class SavedSearchesLoaded extends SearchState {
  final List<SavedSearch> savedSearches;

  const SavedSearchesLoaded(this.savedSearches);

  @override
  List<Object?> get props => [savedSearches];
}

class SearchSaved extends SearchState {
  final SavedSearch savedSearch;

  const SearchSaved(this.savedSearch);

  @override
  List<Object?> get props => [savedSearch];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}