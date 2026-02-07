import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api/api_service.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../data/models/page.dart';
import '../../../data/models/requests/create_page_request.dart';
import '../../../data/models/requests/update_page_request.dart';
import 'page_event.dart';
import 'page_state.dart';

class PageBloc extends Bloc<PageEvent, PageState> {
  final ApiService _apiService;
  final StorageService _storageService;

  PageBloc(this._apiService, this._storageService) : super(const PageInitial()) {
    on<LoadPages>(_onLoadPages);
    on<RefreshPages>(_onRefreshPages);
    on<GetPageDetails>(_onGetPageDetails);
    on<CreatePage>(_onCreatePage);
    on<UpdatePage>(_onUpdatePage);
    on<DeletePage>(_onDeletePage);
    on<ClearPageError>(_onClearPageError);
  }

  Future<String?> _resolveTeamId(String? provided) async {
    if (provided != null && provided!.isNotEmpty) return provided;
    return _storageService.getTeamId();
  }

  Future<void> _onLoadPages(
    LoadPages event,
    Emitter<PageState> emit,
  ) async {
    emit(const PageLoadInProgress());
    try {
      final teamId = await _resolveTeamId(event.teamId);
      if (teamId == null) {
        emit(const PageLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.getPages(
        teamId,
        page: event.page,
        limit: event.limit,
      );

      emit(PageLoadSuccess(
        pages: response.pages,
        hasMore: response.pages.length == (event.limit ?? response.pages.length),
        currentPage: event.page ?? 1,
      ));
    } catch (e) {
      emit(PageLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onRefreshPages(
    RefreshPages event,
    Emitter<PageState> emit,
  ) async {
    try {
      final teamId = await _resolveTeamId(event.teamId);
      if (teamId == null) {
        emit(const PageLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.getPages(teamId);
      emit(PageLoadSuccess(
        pages: response.pages,
        hasMore: false,
        currentPage: 1,
      ));
    } catch (e) {
      emit(PageLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onGetPageDetails(
    GetPageDetails event,
    Emitter<PageState> emit,
  ) async {
    try {
      final teamId = await _resolveTeamId(event.teamId);
      if (teamId == null) {
        emit(const PageLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.getPage(teamId, event.pageId);
      emit(PageDetailsLoaded(page: response.page));
    } catch (e) {
      emit(PageLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onCreatePage(
    CreatePage event,
    Emitter<PageState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _resolveTeamId(event.teamId);
      if (teamId == null) {
        emit(PageOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final request = event.request ??
          CreatePageRequest(
            title: event.title ?? '',
            content: event.content,
            projectId: event.projectId,
            tags: event.tags,
            isPinned: event.isPinned,
          );

      final response = await _apiService.createPage(teamId, request);
      
      PageState finalState = currentState;
      if (currentState is PageLoadSuccess) {
        finalState = currentState.copyWith(
          pages: List<Page>.from(currentState.pages)..insert(0, response.page),
        );
        emit(finalState);
      }

      emit(PageOperationSuccess(
        message: 'Page created',
        page: response.page,
        previousState: finalState,
      ));
    } catch (e) {
      emit(PageOperationFailure(error: e.toString(), previousState: currentState));
    }
  }

  Future<void> _onUpdatePage(
    UpdatePage event,
    Emitter<PageState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _resolveTeamId(event.teamId);
      if (teamId == null) {
        emit(PageOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final request = event.request ??
          UpdatePageRequest(
            title: event.title,
            content: event.content,
            projectId: event.projectId,
            tags: event.tags,
            isArchived: event.isArchived,
            isPinned: event.isPinned,
          );

      final response = await _apiService.updatePage(teamId, event.pageId, request);
      
      PageState finalState = currentState;
      if (currentState is PageLoadSuccess) {
        finalState = currentState.copyWith(
          pages: currentState.pages.map((p) => p.id == event.pageId ? response.page : p).toList(),
        );
        emit(finalState);
      }

      emit(PageOperationSuccess(
        message: 'Page updated',
        page: response.page,
        previousState: finalState,
      ));
    } catch (e) {
      emit(PageOperationFailure(error: e.toString(), previousState: currentState));
    }
  }

  Future<void> _onDeletePage(
    DeletePage event,
    Emitter<PageState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _resolveTeamId(event.teamId);
      if (teamId == null) {
        emit(PageOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      await _apiService.deletePage(teamId, event.pageId);
      
      PageState finalState = currentState;
      if (currentState is PageLoadSuccess) {
        finalState = currentState.copyWith(
          pages: currentState.pages.where((p) => p.id != event.pageId).toList(),
        );
        emit(finalState);
      }

      emit(PageOperationSuccess(
        message: 'Page deleted',
        previousState: finalState,
      ));
    } catch (e) {
      emit(PageOperationFailure(error: e.toString(), previousState: currentState));
    }
  }

  void _onClearPageError(
    ClearPageError event,
    Emitter<PageState> emit,
  ) {
    emit(state);
  }
}

