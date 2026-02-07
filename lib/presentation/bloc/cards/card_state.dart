import 'package:equatable/equatable.dart';
import '../../../data/models/card.dart';

abstract class CardState extends Equatable {
  const CardState();

  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {
  const CardInitial();
}

class CardLoadInProgress extends CardState {
  const CardLoadInProgress();
}

class CardLoadSuccess extends CardState {
  final List<Card> cards;
  final bool hasMore;
  final int currentPage;

  const CardLoadSuccess({
    required this.cards,
    this.hasMore = false,
    this.currentPage = 1,
  });

  CardLoadSuccess copyWith({
    List<Card>? cards,
    bool? hasMore,
    int? currentPage,
  }) {
    return CardLoadSuccess(
      cards: cards ?? this.cards,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [cards, hasMore, currentPage];
}

class CardOperationSuccess extends CardState {
  final String message;
  final CardState previousState;

  const CardOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

class CardDetailsLoaded extends CardState {
  final Card card;

  const CardDetailsLoaded({required this.card});

  @override
  List<Object?> get props => [card];
}

class CardCommentsLoaded extends CardState {
  final List<Comment> comments;

  const CardCommentsLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class CardAttachmentsLoaded extends CardState {
  final List<Attachment> attachments;

  const CardAttachmentsLoaded({required this.attachments});

  @override
  List<Object?> get props => [attachments];
}

class CardAttachmentUploadProgress extends CardState {
  final double progress; // 0.0 - 1.0

  const CardAttachmentUploadProgress({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class CardLoadFailure extends CardState {
  final String error;

  const CardLoadFailure({required this.error});

  String get message => error;

  @override
  List<Object?> get props => [error];
}

class CardOperationFailure extends CardState {
  final String error;
  final CardState previousState;

  const CardOperationFailure({
    required this.error,
    required this.previousState,
  });

  String get message => error;

  @override
  List<Object?> get props => [error, previousState];
}