import 'package:equatable/equatable.dart';
import '../../../data/models/note.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {
  const NoteInitial();
}

class NoteLoadInProgress extends NoteState {
  const NoteLoadInProgress();
}

class NoteLoadSuccess extends NoteState {
  final List<Note> notes;
  final bool hasMore;
  final int currentPage;

  const NoteLoadSuccess({
    required this.notes,
    this.hasMore = false,
    this.currentPage = 1,
  });

  NoteLoadSuccess copyWith({
    List<Note>? notes,
    bool? hasMore,
    int? currentPage,
  }) {
    return NoteLoadSuccess(
      notes: notes ?? this.notes,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [notes, hasMore, currentPage];
}

class NoteDetailsLoaded extends NoteState {
  final Note note;

  const NoteDetailsLoaded({required this.note});

  @override
  List<Object?> get props => [note];
}

class NoteOperationSuccess extends NoteState {
  final String message;
  final NoteState previousState;

  const NoteOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

class NoteLoadFailure extends NoteState {
  final String error;

  const NoteLoadFailure({required this.error});

  String get message => error;

  @override
  List<Object?> get props => [error];
}

class NoteOperationFailure extends NoteState {
  final String error;
  final NoteState previousState;

  const NoteOperationFailure({
    required this.error,
    required this.previousState,
  });

  String get message => error;

  @override
  List<Object?> get props => [error, previousState];
}