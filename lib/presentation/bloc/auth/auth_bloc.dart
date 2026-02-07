import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api/api_service.dart';
import '../../../core/services/api/api_models.dart';
import '../../../core/services/storage/storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthBloc(this._apiService, this._storageService) : super(AuthInitial()) {
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
    on<PatAuthenticationRequested>(_onPatAuthenticationRequested);
    on<ValidatePatToken>(_onValidatePatToken);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthTokenSaved>(_onAuthTokenSaved);
    on<ProfileUpdated>(_onProfileUpdated);
  }

  Future<void> _onCheckAuthenticationStatus(
    CheckAuthenticationStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await _storageService.getAccessToken();
      final teamId = await _storageService.getTeamId();

      if (token != null && teamId != null) {
        // Verify token is still valid
        try {
          final userResponse = await _apiService.getCurrentUser();
          await _storageService.saveUserId(userResponse.user.id);

          // Use the teamId from storage, but if the API returns one, 
          // use the API's version as it has the correct casing.
          final finalTeamId = userResponse.teamId ?? teamId;
          
          if (finalTeamId != teamId) {
            await _storageService.saveTeamId(finalTeamId);
          }

          emit(Authenticated(
            user: userResponse.user,
            token: token,
            teamId: finalTeamId,
          ));
        } catch (e) {
          // Token is invalid, clear it
          await _storageService.removeAccessToken();
          await _storageService.removeTeamId();
          await _storageService.removeUserId();
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to check authentication status'));
    }
  }

  Future<void> _onPatAuthenticationRequested(
    PatAuthenticationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Save PAT token and team ID to storage
      await _storageService.saveAccessToken(event.patToken);
      await _storageService.saveTeamId(event.teamId);

      // Validate PAT token by fetching current user
      final userResponse = await _apiService.getCurrentUser();
      await _storageService.saveUserId(userResponse.user.id);

      // Validate and normalize team ID
      String userProvidedId = event.teamId.trim();
      String? apiReturnedId = userResponse.teamId;
      String finalTeamId = userProvidedId;

      if (apiReturnedId != null) {
        // If user didn't provide one, or if it matches case-insensitively, 
        // use the correct-cased one from the API.
        if (userProvidedId.isEmpty || 
            userProvidedId.toLowerCase() == apiReturnedId.toLowerCase()) {
          finalTeamId = apiReturnedId;
        }
      }
      
      if (finalTeamId.isEmpty) {
        throw Exception('Team ID is required. Please provide it in the login form.');
      }
      
      // Save teamId to storage
      await _storageService.saveTeamId(finalTeamId);

      emit(Authenticated(
        user: userResponse.user,
        token: event.patToken,
        teamId: finalTeamId,
      ));
    } catch (e) {
      // Clear any previously saved credentials so the next attempt starts clean.
      await _storageService.removeAccessToken();
      await _storageService.removeTeamId();

      String errorMessage = 'Authentication failed';

      if (e is DioException) {
        final status = e.response?.statusCode;
        final serverMessage = e.response?.data?['message']?.toString();

        if (serverMessage != null && serverMessage.isNotEmpty) {
          errorMessage = serverMessage;
        }

        if (status == 401 || status == 403) {
          errorMessage = serverMessage ?? 'Invalid PAT token or workspace ID';
        } else if (status != null && status >= 500) {
          errorMessage = serverMessage ?? 'Server unavailable. Please try again.';
        }

        // Log details to help debugging without exposing to the UI.
        debugPrint('Auth error: status=$status message=${e.message} body=$serverMessage');
      } else if (e.toString().toLowerCase().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = e.toString();
      }

      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onValidatePatToken(
    ValidatePatToken event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    emit(AuthLoading());
    try {
      // Temporarily save token to storage so interceptor can use it
      final originalToken = await _storageService.getAccessToken();
      final originalTeamId = await _storageService.getTeamId();
      
      await _storageService.saveAccessToken(event.patToken);
      
      try {
        final response = await _apiService.getCurrentUser();
        
        emit(PatTokenValidated(
          patToken: event.patToken,
          user: response.user,
          teamId: response.teamId ?? '',
        ));
      } finally {
        // Restore original tokens if we were just validating
        if (originalToken != null) {
          await _storageService.saveAccessToken(originalToken);
        } else {
          await _storageService.removeAccessToken();
        }
        if (originalTeamId != null) {
          await _storageService.saveTeamId(originalTeamId);
        }
      }
    } catch (e) {
      emit(AuthError(message: 'Token validation failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Clear storage
      await _storageService.clearAll();

      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to logout'));
    }
  }

  Future<void> _onAuthTokenSaved(
    AuthTokenSaved event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _storageService.saveAccessToken(event.token);
      await _storageService.saveTeamId(event.teamId);

      final userResponse = await _apiService.getCurrentUser();
      await _storageService.saveUserId(userResponse.user.id);

      emit(Authenticated(
        user: userResponse.user,
        token: event.token,
        teamId: event.teamId,
      ));
    } catch (e) {
      emit(AuthError(message: 'Failed to save authentication token'));
    }
  }

  Future<void> _onProfileUpdated(
    ProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      try {
        // Convert userData map to UpdateProfileRequest
        final request = UpdateProfileRequest(
          name: event.userData['name'],
          email: event.userData['email'],
          avatarUrl: event.userData['avatarUrl'],
        );
        final updatedUser = await _apiService.updateProfile(request);

        emit((state as Authenticated).copyWith(
          user: updatedUser.user,
        ));
      } catch (e) {
        emit(AuthError(message: 'Failed to update profile'));
      }
    }
  }
}