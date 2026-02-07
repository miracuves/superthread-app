import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api/api_service.dart';
import '../../../core/services/api/api_models.dart';
import '../../../data/models/requests/create_note_request.dart';
import '../../../data/models/requests/update_note_request.dart';
import '../../../core/services/storage/storage_service.dart';
import 'note_event.dart';
import 'note_state.dart';

export 'note_event.dart';
export 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final ApiService _apiService;
  final StorageService _storageService;

  NoteBloc(this._apiService, this._storageService) : super(NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<GetNoteDetails>(_onGetNoteDetails);
    on<RefreshNotes>(_onRefreshNotes);
    on<ClearNoteError>(_onClearNoteError);
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoadInProgress());
    try {
      final teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(const NoteLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.getNotes(
        teamId: teamId,
        page: event.page ?? 1,
        limit: event.limit ?? 20,
      );

      print('NoteBloc: Successfully loaded ${response.notes.length} notes');
      for (var note in response.notes) {
        print('NoteBloc: Note ID: ${note.id}, Title: ${note.title}');
      }

      emit(NoteLoadSuccess(
        notes: response.notes,
        hasMore: false,
        currentPage: 1,
      ));
    } catch (e, stackTrace) {
      print('NoteBloc: Error loading notes: $e');
      print('NoteBloc: Stacktrace: $stackTrace');
      String errorMessage = 'Failed to load notes';

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
              errorMessage = 'Invalid request. Please check your filters.';
              break;
            case 401:
              errorMessage = 'Authentication required. Please log in again.';
              break;
            case 403:
              errorMessage = 'Access denied. Your Personal Access Token may not have permission to view notes.';
              break;
            case 404:
              errorMessage = 'Notes not found.';
              break;
            case 500:
            case 502:
            case 503:
            case 504:
              errorMessage = 'Server error occurred. Please try again later.';
              break;
            default:
              errorMessage = serverMessage ?? 'Failed to load notes';
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

      emit(NoteLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onCreateNote(
    CreateNote event,
    Emitter<NoteState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(NoteOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final request = event.request ??
          CreateNoteRequest(
            title: event.title ?? '',
            content: event.content ?? '',
            tags: event.tags,
          );

      final response = await _apiService.createNote(teamId, request);

      if (currentState is NoteLoadSuccess) {
        final updatedNotes = [response.note, ...currentState.notes];
        final newState = currentState.copyWith(notes: updatedNotes);
        emit(newState);
        emit(NoteOperationSuccess(
          message: 'Note created successfully',
          previousState: newState,
        ));
      } else {
        emit(NoteOperationSuccess(
          message: 'Note created successfully',
          previousState: currentState,
        ));
      }
    } catch (e) {
      String errorMessage = 'Failed to create note';
      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid note data';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(NoteOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<NoteState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(NoteOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final request = event.request ??
          UpdateNoteRequest(
            title: event.title,
            content: event.content,
            tags: event.tags,
          );

      final response = await _apiService.updateNote(teamId, event.noteId, request);

      if (currentState is NoteLoadSuccess) {
        final updatedNotes = currentState.notes.map((note) {
          return note.id == event.noteId ? response.note : note;
        }).toList();
        emit(currentState.copyWith(notes: updatedNotes));
      }

      if (currentState is NoteDetailsLoaded && currentState.note.id == event.noteId) {
        emit(NoteDetailsLoaded(note: response.note));
      }

      emit(NoteOperationSuccess(
        message: 'Note updated successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to update note';
      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Note not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(NoteOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NoteState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(NoteOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      await _apiService.deleteNote(teamId, event.noteId);

      if (currentState is NoteLoadSuccess) {
        final updatedNotes =
            currentState.notes.where((note) => note.id != event.noteId).toList();
        emit(currentState.copyWith(notes: updatedNotes));
      }

      emit(NoteOperationSuccess(
        message: 'Note deleted successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to delete note';
      emit(NoteOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onGetNoteDetails(
    GetNoteDetails event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const NoteLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.getNote(teamId, event.noteId);
      emit(NoteDetailsLoaded(note: response.note));
    } catch (e) {
      String errorMessage = 'Failed to load note details';
      emit(NoteLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onRefreshNotes(
    RefreshNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoadInProgress());
    try {
      final response = await _apiService.getNotes(teamId: event.teamId);
      emit(NoteLoadSuccess(
        notes: response.notes,
        hasMore: false,
        currentPage: 1,
      ));
    } catch (e) {
      emit(const NoteLoadFailure(error: 'Failed to refresh notes'));
    }
  }

  Future<void> _onClearNoteError(
    ClearNoteError event,
    Emitter<NoteState> emit,
  ) async {
    if (state is NoteOperationFailure) {
      emit((state as NoteOperationFailure).previousState);
    } else if (state is NoteOperationSuccess) {
      emit((state as NoteOperationSuccess).previousState);
    }
  }
}