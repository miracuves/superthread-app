import 'package:equatable/equatable.dart';
import '../../../data/models/note.dart';
import '../../../core/services/api/api_service.dart';
import '../../../core/services/api/api_models.dart';
import '../../../data/models/requests/create_note_request.dart';
import '../../../data/models/requests/update_note_request.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {
  final String? teamId;
  final int? page;
  final int? limit;

  const LoadNotes({
    this.teamId,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [teamId, page, limit];
}

class CreateNote extends NoteEvent {
  final String? teamId;
  final CreateNoteRequest? request;
  final String? title;
  final String? content;
  final List<String>? tags;
  final bool isPinned;

  const CreateNote({
    this.teamId,
    this.request,
    this.title,
    this.content,
    this.tags,
    this.isPinned = false,
  });

  @override
  List<Object?> get props => [teamId, request, title, content, tags, isPinned];
}

class UpdateNote extends NoteEvent {
  final String noteId;
  final UpdateNoteRequest? request;
  final String? title;
  final String? content;
  final List<String>? tags;
  final bool? isPinned;
  final bool? isArchived;

  const UpdateNote({
    required this.noteId,
    this.request,
    this.title,
    this.content,
    this.tags,
    this.isPinned,
    this.isArchived,
  });

  @override
  List<Object?> get props => [noteId, request, title, content, tags, isPinned, isArchived];
}

class DeleteNote extends NoteEvent {
  final String noteId;

  const DeleteNote({required this.noteId});

  @override
  List<Object?> get props => [noteId];
}

class GetNoteDetails extends NoteEvent {
  final String noteId;

  const GetNoteDetails({required this.noteId});

  @override
  List<Object?> get props => [noteId];
}

class RefreshNotes extends NoteEvent {
  final String teamId;

  const RefreshNotes({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}

class ClearNoteError extends NoteEvent {
  const ClearNoteError();
}