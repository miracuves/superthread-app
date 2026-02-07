import 'package:equatable/equatable.dart';
import '../../../data/models/requests/create_epic_request.dart';
import '../../../data/models/requests/update_epic_request.dart';

abstract class EpicEvent extends Equatable {
  const EpicEvent();

  @override
  List<Object?> get props => [];
}

class LoadEpics extends EpicEvent {
  final String? teamId;
  final String? boardId;
  final int? page;
  final int? limit;

  const LoadEpics({
    this.teamId,
    this.boardId,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [teamId, boardId, page, limit];
}

class LoadSpaces extends EpicEvent {
  final String? teamId;
  final int? page;
  final int? limit;

  const LoadSpaces({
    this.teamId,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [teamId, page, limit];
}

class LoadEpic extends EpicEvent {
  final String epicId;

  const LoadEpic({required this.epicId});

  @override
  List<Object?> get props => [epicId];
}

class CreateEpic extends EpicEvent {
  final String? teamId;
  final CreateEpicRequest request;

  const CreateEpic({
    this.teamId,
    required this.request,
  });

  @override
  List<Object?> get props => [teamId, request];
}

class UpdateEpic extends EpicEvent {
  final String epicId;
  final UpdateEpicRequest request;

  const UpdateEpic({
    required this.epicId,
    required this.request,
  });

  @override
  List<Object?> get props => [epicId, request];
}

class ArchiveEpic extends EpicEvent {
  final String epicId;

  const ArchiveEpic({required this.epicId});

  @override
  List<Object?> get props => [epicId];
}

class RefreshEpics extends EpicEvent {
  final String teamId;

  const RefreshEpics({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}

class ClearEpicError extends EpicEvent {
  const ClearEpicError();
}
