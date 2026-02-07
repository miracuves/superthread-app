import 'package:equatable/equatable.dart';
import '../../../data/models/board.dart';
import '../../../data/models/requests/create_board_request.dart';

abstract class BoardEvent extends Equatable {
  const BoardEvent();

  @override
  List<Object?> get props => [];
}

class LoadBoards extends BoardEvent {
  final String? teamId;

  const LoadBoards({this.teamId});

  @override
  List<Object?> get props => [teamId];
}

class CreateBoard extends BoardEvent {
  final String? teamId;
  final String? name;
  final String? description;

  const CreateBoard({
    this.teamId,
    this.name,
    this.description,
  });

  @override
  List<Object?> get props => [teamId, name, description];
}

class UpdateBoard extends BoardEvent {
  final String boardId;
  final String? name;
  final String? description;

  const UpdateBoard({
    required this.boardId,
    this.name,
    this.description,
  });

  @override
  List<Object?> get props => [boardId, name, description];
}

class DeleteBoard extends BoardEvent {
  final String boardId;

  const DeleteBoard({required this.boardId});

  @override
  List<Object?> get props => [boardId];
}

class LoadBoardDetails extends BoardEvent {
  final String boardId;

  const LoadBoardDetails({required this.boardId});

  @override
  List<Object?> get props => [boardId];
}

class ReorderBoardLists extends BoardEvent {
  final String boardId;
  final List<BoardList> lists;

  const ReorderBoardLists({
    required this.boardId,
    required this.lists,
  });

  @override
  List<Object?> get props => [boardId, lists];
}

class AddBoardList extends BoardEvent {
  final String boardId;
  final String name;

  const AddBoardList({
    required this.boardId,
    required this.name,
  });

  @override
  List<Object?> get props => [boardId, name];
}

class RefreshBoards extends BoardEvent {
  final String teamId;

  const RefreshBoards({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}

class ClearBoardError extends BoardEvent {
  const ClearBoardError();
}