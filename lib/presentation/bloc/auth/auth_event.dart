import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthenticationStatus extends AuthEvent {}

class PatAuthenticationRequested extends AuthEvent {
  final String patToken;
  final String teamId;

  const PatAuthenticationRequested({required this.patToken, required this.teamId});

  @override
  List<Object> get props => [patToken, teamId];
}

class ValidatePatToken extends AuthEvent {
  final String patToken;

  const ValidatePatToken({required this.patToken});

  @override
  List<Object> get props => [patToken];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthTokenSaved extends AuthEvent {
  final String token;
  final String teamId;

  const AuthTokenSaved({required this.token, required this.teamId});

  @override
  List<Object> get props => [token, teamId];
}

class ProfileUpdated extends AuthEvent {
  final Map<String, dynamic> userData;

  const ProfileUpdated({required this.userData});

  @override
  List<Object> get props => [userData];
}