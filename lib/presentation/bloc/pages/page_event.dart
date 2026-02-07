import 'package:equatable/equatable.dart';
import '../../../data/models/requests/create_page_request.dart';
import '../../../data/models/requests/update_page_request.dart';

abstract class PageEvent extends Equatable {
  const PageEvent();

  @override
  List<Object?> get props => [];
}

class LoadPages extends PageEvent {
  final String? teamId;
  final int? page;
  final int? limit;

  const LoadPages({this.teamId, this.page, this.limit});

  @override
  List<Object?> get props => [teamId, page, limit];
}

class RefreshPages extends PageEvent {
  final String? teamId;

  const RefreshPages({this.teamId});

  @override
  List<Object?> get props => [teamId];
}

class GetPageDetails extends PageEvent {
  final String pageId;
  final String? teamId;

  const GetPageDetails({required this.pageId, this.teamId});

  @override
  List<Object?> get props => [pageId, teamId];
}

class CreatePage extends PageEvent {
  final String? teamId;
  final CreatePageRequest? request;
  final String? title;
  final String? content;
  final String? projectId;
  final List<String>? tags;
  final bool? isPinned;

  const CreatePage({
    this.teamId,
    this.request,
    this.title,
    this.content,
    this.projectId,
    this.tags,
    this.isPinned,
  });

  @override
  List<Object?> get props => [
        teamId,
        request,
        title,
        content,
        projectId,
        tags,
        isPinned,
      ];
}

class UpdatePage extends PageEvent {
  final String pageId;
  final String? teamId;
  final UpdatePageRequest? request;
  final String? title;
  final String? content;
  final String? projectId;
  final List<String>? tags;
  final bool? isArchived;
  final bool? isPinned;

  const UpdatePage({
    required this.pageId,
    this.teamId,
    this.request,
    this.title,
    this.content,
    this.projectId,
    this.tags,
    this.isArchived,
    this.isPinned,
  });

  @override
  List<Object?> get props => [
        pageId,
        teamId,
        request,
        title,
        content,
        projectId,
        tags,
        isArchived,
        isPinned,
      ];
}

class DeletePage extends PageEvent {
  final String pageId;
  final String? teamId;

  const DeletePage({required this.pageId, this.teamId});

  @override
  List<Object?> get props => [pageId, teamId];
}

class ClearPageError extends PageEvent {
  const ClearPageError();
}

