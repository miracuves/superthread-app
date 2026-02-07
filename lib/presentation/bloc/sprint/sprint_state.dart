import 'package:equatable/equatable.dart';
import 'package:superthread_app/core/services/api/api_models.dart';

abstract class SprintState extends Equatable {
  const SprintState();

  @override
  List<Object?> get props => [];
}

class SprintInitial extends SprintState {
  const SprintInitial();
}

class SprintLoading extends SprintState {
  const SprintLoading();
}

class SprintLoaded extends SprintState {
  final List<Sprint> sprints;
  final int totalCount;
  final int? currentPage;
  final int? totalPages;
  final String? activeFilter;

  const SprintLoaded({
    required this.sprints,
    required this.totalCount,
    this.currentPage,
    this.totalPages,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [sprints, totalCount, currentPage, totalPages, activeFilter];
}

class SprintCreated extends SprintState {
  final Sprint sprint;

  const SprintCreated({required this.sprint});

  @override
  List<Object?> get props => [sprint];
}

class SprintUpdated extends SprintState {
  final Sprint sprint;

  const SprintUpdated({required this.sprint});

  @override
  List<Object?> get props => [sprint];
}

class SprintDeleted extends SprintState {
  final String sprintId;

  const SprintDeleted({required this.sprintId});

  @override
  List<Object?> get props => [sprintId];
}

class SprintCompleted extends SprintState {
  final Sprint sprint;

  const SprintCompleted({required this.sprint});

  @override
  List<Object?> get props => [sprint];
}

class SprintOperationSuccess extends SprintState {
  final String message;

  const SprintOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SprintError extends SprintState {
  final String message;

  const SprintError({required this.message});

  @override
  List<Object?> get props => [message];
}
