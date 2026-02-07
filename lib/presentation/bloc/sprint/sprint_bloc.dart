import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api/api_service.dart';
import '../../../../core/services/storage/storage_service.dart';
import 'sprint_event.dart';
import 'sprint_state.dart';

class SprintBloc extends Bloc<SprintEvent, SprintState> {
  final ApiService _apiService;
  final StorageService _storageService;

  SprintBloc(this._apiService, this._storageService) : super(SprintInitial()) {
    on<LoadSprints>(_onLoadSprints);
    on<CreateSprint>(_onCreateSprint);
    on<UpdateSprint>(_onUpdateSprint);
    on<DeleteSprint>(_onDeleteSprint);
    on<CompleteSprint>(_onCompleteSprint);
    on<AddCardsToSprint>(_onAddCardsToSprint);
    on<RemoveCardsFromSprint>(_onRemoveCardsFromSprint);
    on<RefreshSprints>(_onRefreshSprints);
  }

  Future<void> _onLoadSprints(
    LoadSprints event,
    Emitter<SprintState> emit,
  ) async {
    emit(SprintLoading());
    try {
      final response = await _apiService.getSprints(
        event.teamId,
        page: event.page,
        limit: event.limit,
        status: event.status,
        projectId: event.projectId,
      );

      emit(SprintLoaded(
        sprints: response.sprints,
        totalCount: response.totalCount,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        activeFilter: event.status,
      ));
    } catch (e) {
      emit(SprintError(message: 'Failed to load sprints: ${e.toString()}'));
    }
  }

  Future<void> _onCreateSprint(
    CreateSprint event,
    Emitter<SprintState> emit,
  ) async {
    try {
      final response = await _apiService.createSprint(event.teamId, event.request);
      emit(SprintCreated(sprint: response.sprint));
      
      // Reload sprints after creation
      add(LoadSprints(teamId: event.teamId));
    } catch (e) {
      emit(SprintError(message: 'Failed to create sprint: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSprint(
    UpdateSprint event,
    Emitter<SprintState> emit,
  ) async {
    try {
      final response = await _apiService.updateSprint(event.teamId, event.sprintId, event.request);
      emit(SprintUpdated(sprint: response.sprint));
      
      // Reload sprints after update
      add(LoadSprints(teamId: event.teamId));
    } catch (e) {
      emit(SprintError(message: 'Failed to update sprint: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteSprint(
    DeleteSprint event,
    Emitter<SprintState> emit,
  ) async {
    try {
      await _apiService.deleteSprint(event.teamId, event.sprintId);
      emit(SprintDeleted(sprintId: event.sprintId));
      
      // Reload sprints after deletion
      add(LoadSprints(teamId: event.teamId));
    } catch (e) {
      emit(SprintError(message: 'Failed to delete sprint: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteSprint(
    CompleteSprint event,
    Emitter<SprintState> emit,
  ) async {
    try {
      final response = await _apiService.completeSprint(event.teamId, event.sprintId);
      emit(SprintCompleted(sprint: response.sprint));
      
      // Reload sprints after completion
      add(LoadSprints(teamId: event.teamId));
    } catch (e) {
      emit(SprintError(message: 'Failed to complete sprint: ${e.toString()}'));
    }
  }

  Future<void> _onAddCardsToSprint(
    AddCardsToSprint event,
    Emitter<SprintState> emit,
  ) async {
    try {
      await _apiService.addCardsToSprint(event.teamId, event.sprintId, {'cardIds': event.cardIds});
      emit(SprintOperationSuccess(message: 'Cards added to sprint successfully'));
      
      // Reload sprints after adding cards
      add(LoadSprints(teamId: event.teamId));
    } catch (e) {
      emit(SprintError(message: 'Failed to add cards to sprint: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveCardsFromSprint(
    RemoveCardsFromSprint event,
    Emitter<SprintState> emit,
  ) async {
    try {
      await _apiService.removeCardsFromSprint(event.teamId, event.sprintId, {'cardIds': event.cardIds});
      emit(SprintOperationSuccess(message: 'Cards removed from sprint successfully'));
      
      // Reload sprints after removing cards
      add(LoadSprints(teamId: event.teamId));
    } catch (e) {
      emit(SprintError(message: 'Failed to remove cards from sprint: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshSprints(
    RefreshSprints event,
    Emitter<SprintState> emit,
  ) async {
    try {
      // Get current team ID from storage if not provided
      final teamId = event.teamId.isEmpty ? await _storageService.getTeamId() : event.teamId;
      
      if (teamId != null) {
        add(LoadSprints(teamId: teamId));
      } else {
        emit(const SprintError(message: 'No team ID found'));
      }
    } catch (e) {
      emit(SprintError(message: 'Failed to refresh sprints: ${e.toString()}'));
    }
  }
}