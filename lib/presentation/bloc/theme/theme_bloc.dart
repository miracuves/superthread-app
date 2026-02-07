import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../core/services/storage/storage_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final StorageService _storageService;

  ThemeBloc(this._storageService) : super(AppThemeState.initial(_storageService)) {
    on<ThemeChanged>(_onThemeChanged);
    on<ThemeModeChanged>(_onThemeModeChanged);
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is AppThemeState) {
      final appThemeState = state as AppThemeState;
      emit(appThemeState.copyWith(themeMode: event.themeMode));
    } else {
      emit(AppThemeState(themeMode: event.themeMode));
    }
    await _storageService.setThemeMode(event.themeMode.name);
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is AppThemeState) {
      final appThemeState = state as AppThemeState;
      emit(appThemeState.copyWith(themeMode: event.themeMode));
    } else {
      emit(AppThemeState(themeMode: event.themeMode));
    }
    await _storageService.setThemeMode(event.themeMode.name);
  }
}