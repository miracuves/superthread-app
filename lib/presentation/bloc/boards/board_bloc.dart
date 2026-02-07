import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api/api_service.dart' show ApiService;
import '../../../core/services/api/api_models.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../data/models/board.dart';
import '../../../data/models/requests/create_board_request.dart';
import 'board_event.dart';
import 'board_state.dart';

export 'board_event.dart';
export 'board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  final ApiService _apiService;
  final StorageService _storageService;

  BoardBloc(this._apiService, this._storageService) : super(BoardInitial()) {
    on<LoadBoards>(_onLoadBoards);
    on<CreateBoard>(_onCreateBoard);
    on<UpdateBoard>(_onUpdateBoard);
    on<DeleteBoard>(_onDeleteBoard);
    on<LoadBoardDetails>(_onLoadBoardDetails);
    on<ReorderBoardLists>(_onReorderBoardLists);
    on<AddBoardList>(_onAddBoardList);
    on<RefreshBoards>(_onRefreshBoards);
    on<ClearBoardError>(_onClearBoardError);
  }

  /// Helper method to load boards with fallback strategy
  /// Tries different parameter combinations to handle API restrictions
  /// API requires at least one of: bookmarked=true, archived=true, or project_id
  /// NOTE: bookmarked=false is NOT supported by the API
  Future<BoardsResponse> _loadBoardsWithFallback(String teamId) async {
    // Attempt 1: Try to get boards via project_id
    // This is the most reliable method as it doesn't depend on bookmarked/archived flags
    try {
      final epicsResponse = await _apiService.getEpics(
        teamId,
        page: 1,
        limit: 100,
      );
      
      if (epicsResponse.epics.isNotEmpty) {
        // Try to load boards for the first project
        final firstProjectId = epicsResponse.epics.first.id;
        
        final response = await _apiService.getBoards(
          teamId,
          page: 1,
          limit: 100,
          projectId: firstProjectId,
        );
        
        if (response.boards.isNotEmpty) {
          return response;
        }
        
        // Try other projects if the first one had no boards
        for (var i = 1; i < epicsResponse.epics.length && i < 3; i++) {
          try {
            final projectId = epicsResponse.epics[i].id;
            final resp = await _apiService.getBoards(
              teamId,
              page: 1,
              limit: 100,
              projectId: projectId,
            );
            if (resp.boards.isNotEmpty) {
              return resp;
            }
          } catch (e) {
            // Continue to next project
          }
        }
      } else {
        // No epics/projects found
      }
    } catch (e0) {
      // Continue to next attempt
    }

    // Attempt 2: Try with bookmarked="true" (bookmarked boards only)
    // Note: bookmarked="false" is NOT supported by the API
    try {
      final response = await _apiService.getBoards(
        teamId,
        page: 1,
        limit: 100,
        bookmarked: "true",
      );
      if (response.boards.isNotEmpty) {
        return response;
      }
    } catch (e1) {
      // Continue to next attempt
    }

    // Attempt 2.1: Try with archived="false" (active boards only)
    try {
      final response = await _apiService.getBoards(
        teamId,
        page: 1,
        limit: 100,
        archived: "false",
      );
      if (response.boards.isNotEmpty) {
        return response;
      }
    } catch (e1_5) {
      // Continue to next attempt
    }

    // Attempt 3: Try archived="true" (archived boards)
    try {
      final response = await _apiService.getBoards(
        teamId,
        page: 1,
        limit: 100,
        archived: "true",
      );
      if (response.boards.isNotEmpty) {
        return response;
      }
    } catch (e) {
      // Continue to final fallback
    }

    // Final fallback: return empty list
    return const BoardsResponse(boards: []);
  }

  Future<void> _onLoadBoards(
    LoadBoards event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardLoadInProgress());

    try {
      final teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(const BoardLoadFailure(error: 'Team ID not found'));
        return;
      }

      // API requires at least one of: bookmarked, archived, or project_id
      // Use fallback strategy to handle 500 errors
      final response = await _loadBoardsWithFallback(teamId);
      
      // Check if we got an empty response due to permission issues
      if (response.boards.isEmpty) {
        emit(const BoardLoadFailure(
          error: 'Unable to load boards. Your Personal Access Token may not have permission to access projects/epics. Please check your token permissions in team settings or contact your administrator.',
        ));
        return;
      }
      
      emit(BoardLoadSuccess(boards: response.boards));
    } catch (e) {
      String errorMessage = 'Failed to load boards';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied. Your Personal Access Token may not have permission to access projects/epics. Please check your token permissions.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Boards not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server temporarily unavailable. Please try again later.';
      }

      emit(BoardLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onCreateBoard(
    CreateBoard event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(const BoardOperationFailure(
          error: 'Team ID not found',
          previousState: BoardInitial(),
        ));
        return;
      }

      final CreateBoardRequest request = CreateBoardRequest(
        name: event.name ?? '',
        description: event.description,
        teamId: teamId,
      );

      final response = await _apiService.createBoard(teamId, request);

      if (currentState is BoardLoadSuccess) {
        final updatedBoards = [response.board, ...currentState.boards];
        final newState = BoardLoadSuccess(boards: updatedBoards);
        emit(newState);
        emit(BoardOperationSuccess(
          message: 'Board created successfully',
          previousState: newState,
        ));
      } else {
        emit(BoardOperationSuccess(
          message: 'Board created successfully',
          previousState: currentState,
        ));
      }
    } catch (e) {
      String errorMessage = 'Failed to create board';

      // Extract error message from DioException if available
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final serverMessage = e.response?.data?['message']?.toString();
        
        // Use server message if available, otherwise use default
        if (serverMessage != null && serverMessage.isNotEmpty) {
          errorMessage = serverMessage;
        } else {
          // Fallback to status code based messages
          switch (statusCode) {
            case 400:
              errorMessage = 'Invalid board data. Please check your input.';
              break;
            case 401:
              errorMessage = 'Authentication required. Please log in again.';
              break;
            case 403:
              errorMessage = 'Access denied. Your Personal Access Token may not have permission to create boards in this team. Please check your token permissions or contact your team administrator.';
              break;
            case 404:
              errorMessage = 'Team or resource not found.';
              break;
            case 500:
            case 502:
            case 503:
            case 504:
              errorMessage = 'Server error occurred. Please try again later.';
              break;
            default:
              errorMessage = serverMessage ?? 'Failed to create board';
          }
        }
      } else {
        // Handle non-DioException errors
        if (e.toString().contains('network')) {
          errorMessage = 'No internet connection';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout';
        } else {
          errorMessage = e.toString();
        }
      }

      emit(BoardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onUpdateBoard(
    UpdateBoard event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const BoardOperationFailure(
          error: 'Team ID not found',
          previousState: BoardInitial(),
        ));
        return;
      }

      final dynamic request = UpdateBoardRequest(
            name: event.name,
            description: event.description,
          );

      final response = await _apiService.updateBoard(teamId, event.boardId, request);

      if (currentState is BoardLoadSuccess) {
        final updatedBoards = currentState.boards.map((board) {
          return board.id == event.boardId ? response.board : board;
        }).toList();
        emit(BoardLoadSuccess(boards: updatedBoards));
      }

      if (currentState is BoardDetailsLoaded && currentState.board.id == event.boardId) {
        emit(BoardDetailsLoaded(board: response.board));
      }

      emit(BoardOperationSuccess(
        message: 'Board updated successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to update board';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Board not found';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid board data';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(BoardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onDeleteBoard(
    DeleteBoard event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const BoardOperationFailure(
          error: 'Team ID not found',
          previousState: BoardInitial(),
        ));
        return;
      }

      await _apiService.deleteBoard(teamId, event.boardId);

      if (currentState is BoardLoadSuccess) {
        final updatedBoards = currentState.boards
            .where((board) => board.id != event.boardId)
            .toList();
        final newState = BoardLoadSuccess(boards: updatedBoards);
        emit(newState);
        emit(BoardOperationSuccess(
          message: 'Board deleted successfully',
          previousState: newState,
        ));
      } else {
        emit(BoardOperationSuccess(
          message: 'Board deleted successfully',
          previousState: currentState,
        ));
      }
    } catch (e) {
      String errorMessage = 'Failed to delete board';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Board not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(BoardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onLoadBoardDetails(
    LoadBoardDetails event,
    Emitter<BoardState> emit,
  ) async {
    try {
      // Get boards to find the specific board by ID
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const BoardLoadFailure(error: 'Team ID not found'));
        return;
      }

      // Try direct API first, then fallback to list lookup if that fails (handles 403s on boards/{id})
      Board? board;
      try {
        final boardResponse = await _apiService.getBoard(teamId, event.boardId);
        board = boardResponse.board;
      } catch (e) {
        debugPrint('Direct getBoard failed, trying fallback search for ID ${event.boardId}: $e');
        final response = await _loadBoardsWithFallback(teamId);
        try {
          board = response.boards.firstWhere((b) => b.id == event.boardId);
          debugPrint('Found board in fallback list!');
        } catch (_) {
          // If not in board lists, maybe it's an EPIC ID?
          debugPrint('Not found in board list, trying getEpic fallback...');
          try {
            final epicResponse = await _apiService.getEpic(teamId, event.boardId);
            final epic = epicResponse.epic;
            if (epic.boards != null && epic.boards!.isNotEmpty) {
              board = epic.boards!.first;
              debugPrint('Found Epic with ${epic.boards!.length} boards. Using the first one: ${board.name}');
            } else {
              // If epic has no boards, we still can't show Kanban, but let's rethrow 
              // for better error handling
              throw Exception('This project has no boards');
            }
          } catch (e2) {
            debugPrint('getEpic fallback also failed: $e2');
            rethrow; // Final failure, rethrow original or this error
          }
        }
      }

      emit(BoardDetailsLoaded(board: board));
    } catch (e) {
      debugPrint('BoardBloc error: $e');
      String errorMessage = 'Failed to load board details';
      
      if (e is DioException) {
        final serverMessage = e.response?.data?['message']?.toString();
        if (serverMessage != null && serverMessage.isNotEmpty) {
          errorMessage = serverMessage;
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Access denied to this board';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Board not found';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'Server error occurred';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'No internet connection';
        }
      }

      emit(BoardLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onReorderBoardLists(
    ReorderBoardLists event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    try {
      // Note: Board list reordering is handled locally as the API doesn't have
      // a bulk reorder endpoint. Individual list positions could be updated
      // via updateList API if needed, but for now local state is sufficient.

      if (currentState is BoardLoadSuccess) {
        final updatedBoards = currentState.boards.map((board) {
          if (board.id == event.boardId) {
            return board.copyWith(lists: event.lists);
          }
          return board;
        }).toList();
        emit(BoardLoadSuccess(boards: updatedBoards));
      }

      if (currentState is BoardDetailsLoaded && currentState.board.id == event.boardId) {
        emit(BoardDetailsLoaded(board: currentState.board.copyWith(lists: event.lists)));
      }
    } catch (e) {
      String errorMessage = 'Failed to reorder board lists';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Board not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(BoardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onAddBoardList(
    AddBoardList event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(BoardOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      if (currentState is BoardDetailsLoaded) {
        // Create list via API
        final request = CreateListRequest(
          title: event.name,
          boardId: currentState.board.id,
        );
        
        final response = await _apiService.createList(teamId, request);

        // Map API model to UI model
        final apiList = response.list;
        final createdAt = DateTime.fromMillisecondsSinceEpoch(apiList.timeCreated);
        final updatedAt = DateTime.fromMillisecondsSinceEpoch(apiList.timeUpdated);

        final newBoardList = BoardList(
          id: apiList.id,
          name: apiList.title,
          boardId: apiList.boardId,
          position: apiList.cardOrder['position'] is int ? apiList.cardOrder['position'] as int? : null,
          cardIds: apiList.cardOrder['cards'] is List
              ? List<String>.from((apiList.cardOrder['cards'] as List).map((e) => e.toString()))
              : null,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        // Update local state with the new list from API
        final existingLists = currentState.board.lists ?? [];
        final newLists = List<BoardList>.from(existingLists);
        newLists.add(newBoardList);

        final updatedBoard = currentState.board.copyWith(lists: newLists);
        emit(BoardDetailsLoaded(board: updatedBoard));
        
        emit(BoardOperationSuccess(
          message: 'List created successfully',
          previousState: currentState,
        ));
      }
    } catch (e) {
      String errorMessage = 'Failed to add board list';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Board not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(BoardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onRefreshBoards(
    RefreshBoards event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardLoadInProgress());

    try {
      final teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(const BoardLoadFailure(error: 'Team ID not found'));
        return;
      }
      // API requires at least one of: bookmarked, archived, or project_id
      // Use fallback strategy to handle 500 errors
      final response = await _loadBoardsWithFallback(teamId);
      emit(BoardLoadSuccess(boards: response.boards));
    } catch (e) {
      String errorMessage = 'Failed to refresh boards';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Boards not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(BoardLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onClearBoardError(
    ClearBoardError event,
    Emitter<BoardState> emit,
  ) async {
    if (state is BoardOperationFailure) {
      emit((state as BoardOperationFailure).previousState);
    } else if (state is BoardOperationSuccess) {
      emit((state as BoardOperationSuccess).previousState);
    }
  }
}