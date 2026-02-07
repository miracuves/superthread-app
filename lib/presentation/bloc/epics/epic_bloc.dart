import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api/api_service.dart';
import '../../../core/services/api/api_models.dart';
import '../../../core/services/storage/storage_service.dart';
import 'epic_event.dart';
import 'epic_state.dart';

export 'epic_event.dart';
export 'epic_state.dart';

class EpicBloc extends Bloc<EpicEvent, EpicState> {
  final ApiService _apiService;
  final StorageService _storageService;

  EpicBloc(this._apiService, this._storageService) : super(const EpicInitial()) {
    on<LoadEpics>(_onLoadEpics);
    on<LoadSpaces>(_onLoadSpaces);
    on<LoadEpic>(_onLoadEpic);
    on<CreateEpic>(_onCreateEpic);
    on<UpdateEpic>(_onUpdateEpic);
    on<ArchiveEpic>(_onArchiveEpic);
    on<RefreshEpics>(_onRefreshEpics);
    on<ClearEpicError>(_onClearEpicError);
  }

  Future<void> _onLoadEpics(
    LoadEpics event,
    Emitter<EpicState> emit,
  ) async {
    print('DEBUG: _onLoadEpics started (boardId: ${event.boardId})');
    emit(const EpicLoadInProgress());

    String? teamId;
    try {
      teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(const EpicLoadFailure(error: 'Team ID not found'));
        return;
      }

      // Fetch Epics
      final response = await _apiService.getEpics(
        teamId,
        page: event.page ?? 1,
        limit: event.limit ?? 100,
      );
      
      List<Epic> epics = response.epics;

      // If boardId is provided, filter epics locally
      if (event.boardId != null) {
        epics = epics.where((epic) {
          return epic.boards?.any((b) => b.id == event.boardId) ?? false;
        }).toList();
      }
      
      // Append to existing epics if loading more pages
      if (event.page != null && event.page! > 1 && state is EpicLoadSuccess) {
        final existingEpics = (state as EpicLoadSuccess).epics;
        final List<Epic> updatedList = [...existingEpics];
        for (var item in epics) {
          if (!updatedList.any((e) => e.id == item.id)) {
            updatedList.add(item);
          }
        }
        epics = updatedList;
      }

      final hasMore = response.total != null && response.epics.length < response.total!;

      emit(EpicLoadSuccess(
        epics: epics,
        hasMore: hasMore,
        currentPage: event.page ?? 1,
      ));
    } catch (e) {
      emit(EpicLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadSpaces(
    LoadSpaces event,
    Emitter<EpicState> emit,
  ) async {
    print('DEBUG: _onLoadSpaces started');
    emit(const EpicLoadInProgress());

    String? teamId;
    try {
      teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(const EpicLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.getProjects(
        teamId,
        page: event.page ?? 1,
        limit: event.limit ?? 100,
      );

      List<Project> spaces = response.projects;
      
      // Append to existing spaces if loading more pages
      if (event.page != null && event.page! > 1 && state is SpaceLoadSuccess) {
        final existingSpaces = (state as SpaceLoadSuccess).spaces;
        final List<Project> updatedList = [...existingSpaces];
        for (var item in spaces) {
          if (!updatedList.any((s) => s.id == item.id)) {
            updatedList.add(item);
          }
        }
        spaces = updatedList;
      }

      final hasMore = response.total != null && response.projects.length < response.total!;

      emit(SpaceLoadSuccess(
        spaces: spaces,
        hasMore: hasMore,
        currentPage: event.page ?? 1,
      ));
    } catch (e) {
      emit(EpicLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadEpic(
    LoadEpic event,
    Emitter<EpicState> emit,
  ) async {
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const EpicLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.getEpic(teamId, event.epicId);
      emit(EpicDetailsLoaded(epic: response.epic));
    } catch (e) {
      String errorMessage = 'Failed to load epic details';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Epic not found';
      }

      emit(EpicLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onCreateEpic(
    CreateEpic event,
    Emitter<EpicState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(EpicOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final response = await _apiService.createEpic(teamId, event.request);

      if (currentState is EpicLoadSuccess) {
        final updatedEpics = [response.epic, ...currentState.epics];
        emit(currentState.copyWith(epics: updatedEpics));
      }

      emit(EpicOperationSuccess(
        message: 'Epic created successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to create epic';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid epic data';
      }

      emit(EpicOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onUpdateEpic(
    UpdateEpic event,
    Emitter<EpicState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(EpicOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final response = await _apiService.updateEpic(teamId, event.epicId, event.request);

      if (currentState is EpicLoadSuccess) {
        final updatedEpics = currentState.epics.map((epic) {
          return epic.id == event.epicId ? response.epic : epic;
        }).toList();
        emit(currentState.copyWith(epics: updatedEpics));
      }

      if (currentState is EpicDetailsLoaded && currentState.epic.id == event.epicId) {
        emit(EpicDetailsLoaded(epic: response.epic));
      }

      emit(EpicOperationSuccess(
        message: 'Epic updated successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to update epic';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Epic not found';
      }

      emit(EpicOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onArchiveEpic(
    ArchiveEpic event,
    Emitter<EpicState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(EpicOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final response = await _apiService.archiveEpic(teamId, event.epicId);

      if (currentState is EpicLoadSuccess) {
        final updatedEpics = currentState.epics.map((epic) {
          return epic.id == event.epicId ? response.epic : epic;
        }).toList();
        emit(currentState.copyWith(epics: updatedEpics));
      }

      emit(EpicOperationSuccess(
        message: 'Epic archived successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to archive epic';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      }

      emit(EpicOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onRefreshEpics(
    RefreshEpics event,
    Emitter<EpicState> emit,
  ) async {
    emit(const EpicLoadInProgress());

    try {
      final response = await _apiService.getEpics(
        event.teamId,
        page: 1,
        limit: 20,
      );

      emit(EpicLoadSuccess(
        epics: response.epics,
        hasMore: response.total != null && response.epics.length < response.total!,
        currentPage: response.page ?? 1,
      ));
    } catch (e) {
      String errorMessage = 'Failed to refresh epics';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      }

      emit(EpicLoadFailure(error: errorMessage));
    }
  }

  void _onClearEpicError(
    ClearEpicError event,
    Emitter<EpicState> emit,
  ) {
    if (state is EpicOperationFailure) {
      emit((state as EpicOperationFailure).previousState);
    } else if (state is EpicLoadFailure) {
      emit(const EpicInitial());
    }
  }

  void _printFullJson(dynamic data) {
    try {
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      // Print in chunks to avoid truncation in some consoles
      const chunkSize = 800;
      for (var i = 0; i < jsonStr.length; i += chunkSize) {
        final end = (i + chunkSize < jsonStr.length) ? i + chunkSize : jsonStr.length;
        print(jsonStr.substring(i, end));
      }
    } catch (e) {
      print('DEBUG: Could not print JSON: $e');
      print('DEBUG: RAW DATA: $data');
    }
  }
}
