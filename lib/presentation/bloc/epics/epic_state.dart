import 'package:equatable/equatable.dart';
import '../../../core/services/api/api_models.dart';

abstract class EpicState extends Equatable {
  const EpicState();

  @override
  List<Object?> get props => [];
}

class EpicInitial extends EpicState {
  const EpicInitial();
}

class EpicLoadInProgress extends EpicState {
  const EpicLoadInProgress();
}

class EpicLoadSuccess extends EpicState {
  final List<Epic> epics;
  final bool hasMore;
  final int currentPage;

  const EpicLoadSuccess({
    required this.epics,
    this.hasMore = false,
    this.currentPage = 1,
  });

  EpicLoadSuccess copyWith({
    List<Epic>? epics,
    bool? hasMore,
    int? currentPage,
  }) {
    return EpicLoadSuccess(
      epics: epics ?? this.epics,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [epics, hasMore, currentPage];
}

class SpaceLoadSuccess extends EpicState {
  final List<Project> spaces;
  final bool hasMore;
  final int currentPage;

  const SpaceLoadSuccess({
    required this.spaces,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [spaces, hasMore, currentPage];
}

class EpicDetailsLoaded extends EpicState {
  final Epic epic;

  const EpicDetailsLoaded({required this.epic});

  @override
  List<Object?> get props => [epic];
}

class EpicOperationSuccess extends EpicState {
  final String message;
  final EpicState previousState;

  const EpicOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

class EpicLoadFailure extends EpicState {
  final String error;

  const EpicLoadFailure({required this.error});

  String get message => error;

  @override
  List<Object?> get props => [error];
}

class EpicOperationFailure extends EpicState {
  final String error;
  final EpicState previousState;

  const EpicOperationFailure({
    required this.error,
    required this.previousState,
  });

  String get message => error;

  @override
  List<Object?> get props => [error, previousState];
}
