part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String teamId;
  final String query;

  const SearchQueryChanged({required this.teamId, required this.query});

  @override
  List<Object> get props => [teamId, query];
}

class PerformSearch extends SearchEvent {
  final String teamId;
  final String query;
  final String? type;
  final String? projectId;
  final String? boardId;
  final String? listId;
  final String? assignedTo;
  final String? status;
  final List<String>? tags;
  final String? dateFrom;
  final String? dateTo;
  final int? page;
  final int? limit;

  const PerformSearch({
    required this.teamId,
    required this.query,
    this.type,
    this.projectId,
    this.boardId,
    this.listId,
    this.assignedTo,
    this.status,
    this.tags,
    this.dateFrom,
    this.dateTo,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [
        teamId,
        query,
        type,
        projectId,
        boardId,
        listId,
        assignedTo,
        status,
        tags,
        dateFrom,
        dateTo,
        page,
        limit,
      ];
}

class GetSearchSuggestions extends SearchEvent {
  final String teamId;
  final String query;
  final String? type;
  final int? limit;

  const GetSearchSuggestions({
    required this.teamId,
    required this.query,
    this.type,
    this.limit,
  });

  @override
  List<Object?> get props => [teamId, query, type, limit];
}

class SaveSearch extends SearchEvent {
  final String teamId;
  final String name;
  final String query;
  final Map<String, dynamic>? filters;

  const SaveSearch({
    required this.teamId,
    required this.name,
    required this.query,
    this.filters,
  });

  @override
  List<Object?> get props => [teamId, name, query, filters];
}

class GetSavedSearches extends SearchEvent {
  final String teamId;

  const GetSavedSearches({required this.teamId});

  @override
  List<Object> get props => [teamId];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();

  @override
  List<Object> get props => [];
}

class LoadSavedSearch extends SearchEvent {
  final String teamId;
  final SavedSearch savedSearch;

  const LoadSavedSearch({
    required this.teamId,
    required this.savedSearch,
  });

  @override
  List<Object> get props => [teamId, savedSearch];
}