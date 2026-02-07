import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../../data/models/requests/create_card_request.dart';
import '../../../data/models/requests/update_card_request.dart';
import '../../../data/models/requests/create_comment_request.dart';
import '../../../data/models/requests/update_comment_request.dart';
import '../../../data/models/requests/comment_reaction_request.dart';

abstract class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object?> get props => [];
}

class LoadCards extends CardEvent {
  final String? teamId;
  final String? boardId;
  final String? listId;
  final String? projectId;
  final String? epicId;
  final bool? assignedToMe;
  final String? assignedTo;
  final String? status;
  final bool? archived;
  final int? page;
  final int? limit;

  const LoadCards({
    this.teamId,
    this.boardId,
    this.listId,
    this.projectId,
    this.epicId,
    this.assignedToMe,
    this.assignedTo,
    this.status,
    this.archived,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [
        teamId,
        boardId,
        listId,
        projectId,
        epicId,
        assignedToMe,
        assignedTo,
        status,
        archived,
        page,
        limit,
      ];
}

class CreateCard extends CardEvent {
  final String? teamId;
  final CreateCardRequest? request;
  final String? title;
  final String? description;
  final String? boardId;
  final String? listId;
  final String? assignedTo;
  final List<String>? tags;
  final String? status;

  const CreateCard({
    this.teamId,
    this.request,
    this.title,
    this.description,
    this.boardId,
    this.listId,
    this.assignedTo,
    this.tags,
    this.status,
  });

  @override
  List<Object?> get props => [teamId, request, title, description, boardId, listId, assignedTo, tags, status];
}

class UpdateCard extends CardEvent {
  final String cardId;
  final UpdateCardRequest? request;
  final String? title;
  final String? description;
  final String? listId;
  final String? status;
  final String? assignedTo;
  final List<String>? tags;

  const UpdateCard({
    required this.cardId,
    this.request,
    this.title,
    this.description,
    this.listId,
    this.status,
    this.assignedTo,
    this.tags,
  });

  @override
  List<Object?> get props => [cardId, request, title, description, listId, status, assignedTo, tags];
}

class DeleteCard extends CardEvent {
  final String cardId;

  const DeleteCard({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class MoveCard extends CardEvent {
  final String cardId;
  final String? newListId;
  final int? newPosition;

  const MoveCard({
    required this.cardId,
    this.newListId,
    this.newPosition,
  });

  @override
  List<Object?> get props => [cardId, newListId, newPosition];
}

class GetCardDetails extends CardEvent {
  final String cardId;

  const GetCardDetails({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class AddCardComment extends CardEvent {
  final String cardId;
  final CreateCommentRequest request;

  const AddCardComment({
    required this.cardId,
    required this.request,
  });

  @override
  List<Object?> get props => [cardId, request];
}

class LoadCardComments extends CardEvent {
  final String cardId;

  const LoadCardComments({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class DeleteCardComment extends CardEvent {
  final String cardId;
  final String commentId;

  const DeleteCardComment({required this.cardId, required this.commentId});

  @override
  List<Object?> get props => [cardId, commentId];
}

class UpdateCardComment extends CardEvent {
  final String cardId;
  final String commentId;
  final UpdateCommentRequest request;

  const UpdateCardComment({
    required this.cardId,
    required this.commentId,
    required this.request,
  });

  @override
  List<Object?> get props => [cardId, commentId, request];
}

class ToggleCommentReaction extends CardEvent {
  final String cardId;
  final String commentId;
  final CommentReactionRequest request;

  const ToggleCommentReaction({
    required this.cardId,
    required this.commentId,
    required this.request,
  });

  @override
  List<Object?> get props => [cardId, commentId, request];
}

class ReplyToComment extends CardEvent {
  final String cardId;
  final String parentCommentId;
  final CreateCommentRequest request;

  const ReplyToComment({
    required this.cardId,
    required this.parentCommentId,
    required this.request,
  });

  @override
  List<Object?> get props => [cardId, parentCommentId, request];
}

class LoadCardAttachments extends CardEvent {
  final String cardId;

  const LoadCardAttachments({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class UploadCardAttachment extends CardEvent {
  final String cardId;
  final File file;

  const UploadCardAttachment({
    required this.cardId,
    required this.file,
  });

  @override
  List<Object?> get props => [cardId, file];
}

class DeleteCardAttachment extends CardEvent {
  final String cardId;
  final String attachmentId;

  const DeleteCardAttachment({required this.cardId, required this.attachmentId});

  @override
  List<Object?> get props => [cardId, attachmentId];
}

class DeleteMultipleAttachments extends CardEvent {
  final String cardId;
  final List<String> attachmentIds;

  const DeleteMultipleAttachments({required this.cardId, required this.attachmentIds});

  @override
  List<Object?> get props => [cardId, attachmentIds];
}

class RefreshCards extends CardEvent {
  final String teamId;
  final String? boardId;
  final String? listId;

  const RefreshCards({
    required this.teamId,
    this.boardId,
    this.listId,
  });

  @override
  List<Object?> get props => [teamId, boardId, listId];
}

class ClearCardError extends CardEvent {
  const ClearCardError();
}