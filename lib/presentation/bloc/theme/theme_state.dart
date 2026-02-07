import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/services/storage/storage_service.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeStateInitial extends ThemeState {
  final ThemeMode themeMode;

  const ThemeStateInitial(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class AppThemeState extends ThemeState {
  final ThemeMode themeMode;

  const AppThemeState({required this.themeMode});

  static AppThemeState initial(StorageService storageService) {
    final themeModeString = storageService.getThemeMode();
    ThemeMode themeMode;

    switch (themeModeString) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
        break;
    }

    return AppThemeState(themeMode: themeMode);
  }

  AppThemeState copyWith({
    ThemeMode? themeMode,
  }) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [themeMode];
}