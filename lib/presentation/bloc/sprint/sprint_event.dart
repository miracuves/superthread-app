import 'package:equatable/equatable.dart';
import 'package:superthread_app/core/services/api/api_models.dart';

abstract class SprintEvent extends Equatable {
  const SprintEvent();

  @override
  List<Object?> get props => [];
}

class LoadSprints extends SprintEvent {
  final String teamId;
  final int? page;
  final int? limit;
  final String? status;
  final String? projectId;

  const LoadSprints({
    this.teamId = '',
    this.page,
    this.limit,
    this.status,
    this.projectId,
  });

  @override
  List<Object?> get props => [teamId, page, limit, status, projectId];
}

class CreateSprint extends SprintEvent {
  final String teamId;
  final CreateSprintRequest request;

  const CreateSprint({required this.teamId, required this.request});

  @override
  List<Object?> get props => [teamId, request];
}

class UpdateSprint extends SprintEvent {
  final String teamId;
  final String sprintId;
  final UpdateSprintRequest request;

  const UpdateSprint({required this.teamId, required this.sprintId, required this.request});

  @override
  List<Object?> get props => [teamId, sprintId, request];
}

class DeleteSprint extends SprintEvent {
  final String teamId;
  final String sprintId;

  const DeleteSprint({required this.teamId, required this.sprintId});

  @override
  List<Object?> get props => [teamId, sprintId];
}

class CompleteSprint extends SprintEvent {
  final String teamId;
  final String sprintId;

  const CompleteSprint({required this.teamId, required this.sprintId});

  @override
  List<Object?> get props => [teamId, sprintId];
}

class AddCardsToSprint extends SprintEvent {
  final String teamId;
  final String sprintId;
  final List<String> cardIds;

  const AddCardsToSprint({required this.teamId, required this.sprintId, required this.cardIds});

  @override
  List<Object?> get props => [teamId, sprintId, cardIds];
}

class RemoveCardsFromSprint extends SprintEvent {
  final String teamId;
  final String sprintId;
  final List<String> cardIds;

  const RemoveCardsFromSprint({required this.teamId, required this.sprintId, required this.cardIds});

  @override
  List<Object?> get props => [teamId, sprintId, cardIds];
}

class RefreshSprints extends SprintEvent {
  final String teamId;

  const RefreshSprints({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}
