import 'package:equatable/equatable.dart';
import '../../../core/services/api/api_service.dart';
import '../../../core/services/api/api_models.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final String token;
  final String teamId;

  const Authenticated({
    required this.user,
    required this.token,
    required this.teamId,
  });

  Authenticated copyWith({
    User? user,
    String? token,
    String? teamId,
  }) {
    return Authenticated(
      user: user ?? this.user,
      token: token ?? this.token,
      teamId: teamId ?? this.teamId,
    );
  }

  @override
  List<Object> get props => [user, token, teamId];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class PatTokenInvalid extends AuthState {
  final String message;

  const PatTokenInvalid({required this.message});

  @override
  List<Object> get props => [message];
}

class PatTokenValid extends AuthState {
  final User user;

  const PatTokenValid({required this.user});

  @override
  List<Object> get props => [user];
}

class PatTokenValidated extends AuthState {
  final String patToken;
  final User user;
  final String teamId;

  const PatTokenValidated({
    required this.patToken,
    required this.user,
    required this.teamId,
  });

  @override
  List<Object> get props => [patToken, user, teamId];
}