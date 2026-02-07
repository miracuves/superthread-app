import 'package:equatable/equatable.dart';
import '../../../data/models/board.dart';

abstract class BoardState extends Equatable {
  const BoardState();

  @override
  List<Object?> get props => [];
}

class BoardInitial extends BoardState {
  const BoardInitial();
}

class BoardLoadInProgress extends BoardState {
  const BoardLoadInProgress();
}

class BoardLoadSuccess extends BoardState {
  final List<Board> boards;

  const BoardLoadSuccess({required this.boards});

  BoardLoadSuccess copyWith({List<Board>? boards}) {
    return BoardLoadSuccess(boards: boards ?? this.boards);
  }

  @override
  List<Object?> get props => [boards];
}

class BoardDetailsLoaded extends BoardState {
  final Board board;

  const BoardDetailsLoaded({required this.board});

  @override
  List<Object?> get props => [board];
}

class BoardOperationSuccess extends BoardState {
  final String message;
  final BoardState previousState;

  const BoardOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

class BoardLoadFailure extends BoardState {
  final String error;

  const BoardLoadFailure({required this.error});

  String get message => error;

  @override
  List<Object?> get props => [error];
}

class BoardOperationFailure extends BoardState {
  final String error;
  final BoardState previousState;

  const BoardOperationFailure({
    required this.error,
    required this.previousState,
  });

  String get message => error;

  @override
  List<Object?> get props => [error, previousState];
}