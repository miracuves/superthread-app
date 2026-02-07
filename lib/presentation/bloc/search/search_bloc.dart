import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superthread_app/core/services/api/api_service.dart';
import 'package:superthread_app/core/services/api/api_models.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiService _apiService;

  SearchBloc({required ApiService apiService})
      : _apiService = apiService,
        super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<PerformSearch>(_onPerformSearch);
    on<GetSearchSuggestions>(_onGetSearchSuggestions);
    on<SaveSearch>(_onSaveSearch);
    on<GetSavedSearches>(_onGetSavedSearches);
    on<ClearSearch>(_onClearSearch);
    on<LoadSavedSearch>(_onLoadSavedSearch);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.length >= 2) {
      add(GetSearchSuggestions(teamId: event.teamId, query: event.query));
    }
  }

  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final searchResponse = await _apiService.search(
        event.teamId,
        event.query,
        event.type,
        event.projectId,
        event.boardId,
        event.listId,
        event.assignedTo,
        event.status,
        event.tags,
        event.dateFrom,
        event.dateTo,
        event.page ?? 1,
        event.limit ?? 20,
      );

      final filters = <String, dynamic>{
        'type': event.type,
        'projectId': event.projectId,
        'boardId': event.boardId,
        'listId': event.listId,
        'assignedTo': event.assignedTo,
        'status': event.status,
        'tags': event.tags,
        'dateFrom': event.dateFrom,
        'dateTo': event.dateTo,
      };

      emit(SearchLoaded(
        searchResponse: searchResponse,
        currentQuery: event.query,
        currentFilters: filters,
      ));
    } catch (e) {
      emit(SearchError('Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onGetSearchSuggestions(
    GetSearchSuggestions event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final suggestionsResponse = await _apiService.getSearchSuggestions(
        event.teamId,
        event.query,
        event.type,
        event.limit ?? 5,
      );
      emit(SearchSuggestionsLoaded(suggestionsResponse.suggestions));
    } catch (e) {
      emit(SearchError('Failed to get suggestions: ${e.toString()}'));
    }
  }

  Future<void> _onSaveSearch(
    SaveSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final saveSearchRequest = SaveSearchRequest(
        name: event.name,
        query: event.query,
        filters: event.filters,
      );

      final savedSearchResponse = await _apiService.saveSearch(
        event.teamId,
        saveSearchRequest,
      );

      emit(SearchSaved(savedSearchResponse.savedSearch));
    } catch (e) {
      emit(SearchError('Failed to save search: ${e.toString()}'));
    }
  }

  Future<void> _onGetSavedSearches(
    GetSavedSearches event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final savedSearchesResponse = await _apiService.getSavedSearches(event.teamId);
      emit(SavedSearchesLoaded(savedSearchesResponse.savedSearches));
    } catch (e) {
      emit(SearchError('Failed to get saved searches: ${e.toString()}'));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchInitial());
  }

  Future<void> _onLoadSavedSearch(
    LoadSavedSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final filters = event.savedSearch.filters ?? {};
      final searchResponse = await _apiService.search(
        event.teamId,
        event.savedSearch.query,
        filters['type'],
        filters['projectId'],
        filters['boardId'],
        filters['listId'],
        filters['assignedTo'],
        filters['status'],
        filters['tags']?.cast<String>(),
        filters['dateFrom'],
        filters['dateTo'],
        1,
        20,
      );

      emit(SearchLoaded(
        searchResponse: searchResponse,
        currentQuery: event.savedSearch.query,
        currentFilters: filters,
      ));
    } catch (e) {
      emit(SearchError('Failed to load saved search: ${e.toString()}'));
    }
  }
}