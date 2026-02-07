import 'dart:io';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../constants/api_constants.dart';
import '../../../data/models/board.dart';
import '../../../data/models/card.dart';
import '../../../data/models/note.dart';
import '../../../data/models/requests/create_comment_request.dart';
import '../../../data/models/requests/update_comment_request.dart';
import '../../../data/models/requests/comment_reaction_request.dart';
import '../../../data/models/requests/create_board_request.dart';
import '../../../data/models/requests/create_card_request.dart';
import '../../../data/models/requests/update_card_request.dart';
import '../../../data/models/requests/create_note_request.dart';
import '../../../data/models/requests/update_note_request.dart';
import '../../../data/models/requests/create_page_request.dart';
import '../../../data/models/requests/update_page_request.dart';
import '../../../data/models/requests/create_epic_request.dart';
import '../../../data/models/requests/update_epic_request.dart';
import '../../../data/models/responses/page_list_response.dart';
import '../../../data/models/responses/page_response.dart';
import 'api_models.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ApiService {
  factory ApiService(DioClient dioClient) => _ApiService(dioClient.dio);

  // Auth endpoints - Updated for PAT authentication
  @GET('/users/me')
  Future<UserResponse> getCurrentUser();

  @POST('/auth/validate')
  @Deprecated('Use getCurrentUser() instead. PAT authentication does not have a dedicated validation endpoint.')
  Future<ValidateTokenResponse> validateToken(@Body() ValidateTokenRequest request);
  @POST('/auth/logout')
  Future<void> logout();

  // User endpoints
  @PUT('/users/me')
  Future<UserResponse> updateProfile(@Body() UpdateProfileRequest request);

  @MultiPart()
  @POST('/users/me/avatar')
  Future<UserResponse> uploadAvatar(@Part() File file);

  // Team members endpoint
  @GET('/teams/{teamId}/members')
  Future<UsersResponse> getTeamUsers(
    @Path('teamId') String teamId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  // Boards endpoints (team-scoped)
  // API requires at least one of: bookmarked, archived, or project_id
  @GET('/{teamId}/boards')
  Future<BoardsResponse> getBoards(
    @Path('teamId') String teamId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('bookmarked') String? bookmarked,
    @Query('archived') String? archived,
    @Query('project_id') String? projectId,
  });

  @GET('/{teamId}/boards/{id}')
  Future<BoardResponse> getBoard(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  @POST('/{teamId}/boards')
  Future<BoardResponse> createBoard(
    @Path('teamId') String teamId,
    @Body() CreateBoardRequest request,
  );

  @PUT('/{teamId}/boards/{id}')
  Future<BoardResponse> updateBoard(
    @Path('teamId') String teamId,
    @Path('id') String id,
    @Body() UpdateBoardRequest request,
  );

  @DELETE('/{teamId}/boards/{id}')
  Future<void> deleteBoard(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  // Cards endpoints (team-scoped)
  // Note: When no boardId/listId is provided, archived parameter is required
  @GET('/{teamId}/cards')
  Future<CardsResponse> getCards(
    @Path('teamId') String teamId, {
    @Query('board_id') String? boardId,
    @Query('list_id') String? listId,
    @Query('owner_id') String? ownerId,
    @Query('project_id') String? projectId,
    @Query('epic_id') String? epicId,
    @Query('tags') List<String>? tags,
    @Query('status') String? status,
    @Query('archived') String? archived,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @POST('/{teamId}/views/preview')
  Future<CardsResponse> getAssignedCards(
    @Path('teamId') String teamId,
    @Body() ViewPreviewRequest request,
  );

  @GET('/{teamId}/cards/{id}')
  Future<CardResponse> getCard(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  @POST('/{teamId}/cards')
  Future<CardResponse> createCard(
    @Path('teamId') String teamId,
    @Body() CreateCardRequest request,
  );

  @PUT('/{teamId}/cards/{id}')
  Future<CardResponse> updateCard(
    @Path('teamId') String teamId,
    @Path('id') String id,
    @Body() UpdateCardRequest request,
  );

  @DELETE('/{teamId}/cards/{id}')
  Future<void> deleteCard(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  // Card comments
  @GET('/{teamId}/comments')
  Future<CommentsResponse> getCardComments(
    @Path('teamId') String teamId,
    @Query('card_id') String cardId,
  );

  @POST('/{teamId}/comments')
  Future<CommentResponse> addCardComment(
    @Path('teamId') String teamId,
    @Body() CreateCommentRequest request,
  );
  @POST('/{teamId}/comments/{commentId}/children')
  Future<CommentResponse> addCommentReply(
    @Path('teamId') String teamId,
    @Path('commentId') String commentId,
    @Body() CreateCommentRequest request,
  );

  @PATCH('/{teamId}/comments/{commentId}')
  Future<CommentResponse> updateCardComment(
    @Path('teamId') String teamId,
    @Path('commentId') String commentId,
    @Body() UpdateCommentRequest request,
  );

  @POST('/{teamId}/comments/{commentId}/reactions')
  Future<CommentResponse> toggleCommentReaction(
    @Path('teamId') String teamId,
    @Path('commentId') String commentId,
    @Body() CommentReactionRequest request,
  );

  @DELETE('/{teamId}/comments/{commentId}')
  Future<void> deleteCardComment(
    @Path('teamId') String teamId,
    @Path('commentId') String commentId,
  );

  // Card attachments
  @GET('/{teamId}/cards/{cardId}/attachments')
  Future<AttachmentsResponse> getCardAttachments(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
  );
  
  @MultiPart()
  @POST('/{teamId}/cards/{cardId}/attachments')
  Future<AttachmentResponse> uploadCardAttachment(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Part(name: 'file') File file,
  );

  @DELETE('/{teamId}/cards/{cardId}/attachments/{attachmentId}')
  Future<void> deleteCardAttachment(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Path('attachmentId') String attachmentId,
  );

  // Notes endpoints (team-scoped)
  @GET('/{teamId}/notes')
  Future<NotesResponse> getNotes({
    @Path('teamId') required String teamId,
    @Query('project_id') String? projectId,
    @Query('tags') List<String>? tags,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/{teamId}/notes/{id}')
  Future<NoteResponse> getNote(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  @POST('/{teamId}/notes')
  Future<NoteResponse> createNote(
    @Path('teamId') String teamId,
    @Body() CreateNoteRequest request,
  );

  @PATCH('/{teamId}/notes/{id}')
  Future<NoteResponse> updateNote(
    @Path('teamId') String teamId,
    @Path('id') String id,
    @Body() UpdateNoteRequest request,
  );

  @DELETE('/{teamId}/notes/{id}')
  Future<void> deleteNote(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  // Pages endpoints (team-scoped)
  @GET('/{teamId}/pages')
  Future<PageListResponse> getPages(
    @Path('teamId') String teamId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/{teamId}/pages/{id}')
  Future<PageResponse> getPage(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  @POST('/{teamId}/pages')
  Future<PageResponse> createPage(
    @Path('teamId') String teamId,
    @Body() CreatePageRequest request,
  );

  @PATCH('/{teamId}/pages/{id}')
  Future<PageResponse> updatePage(
    @Path('teamId') String teamId,
    @Path('id') String id,
    @Body() UpdatePageRequest request,
  );

  @DELETE('/{teamId}/pages/{id}')
  Future<void> deletePage(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  // Epics endpoints (Projects are called Epics in the API)
  @GET('/{teamId}/epics')
  Future<EpicsResponse> getEpics(
    @Path('teamId') String teamId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/{teamId}/epics/{id}')
  Future<EpicResponse> getEpic(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  @POST('/{teamId}/epics')
  Future<EpicResponse> createEpic(
    @Path('teamId') String teamId,
    @Body() CreateEpicRequest request,
  );

  @PATCH('/{teamId}/epics/{id}')
  Future<EpicResponse> updateEpic(
    @Path('teamId') String teamId,
    @Path('id') String id,
    @Body() UpdateEpicRequest request,
  );

  @PATCH('/{teamId}/epics/{id}/archive')
  Future<EpicResponse> archiveEpic(
    @Path('teamId') String teamId,
    @Path('id') String id,
  );

  // Projects endpoints (legacy - keeping for backward compatibility)
  @GET('/{teamId}/projects')
  Future<ProjectsResponse> getProjects(
    @Path('teamId') String teamId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/projects/{id}')
  Future<ProjectResponse> getProject(@Path('id') String id);

  // Sprints endpoints
  @GET('/{teamId}/sprints')
  Future<SprintsResponse> getSprints(
    @Path('teamId') String teamId, {
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('project_id') String? projectId,
  });

  @POST('/{teamId}/sprints')
  Future<SprintResponse> createSprint(
    @Path('teamId') String teamId,
    @Body() CreateSprintRequest request,
  );

  @GET('/{teamId}/sprints/{sprintId}')
  Future<SprintResponse> getSprint(
    @Path('teamId') String teamId,
    @Path('sprintId') String sprintId,
  );

  @PUT('/{teamId}/sprints/{sprintId}')
  Future<SprintResponse> updateSprint(
    @Path('teamId') String teamId,
    @Path('sprintId') String sprintId,
    @Body() UpdateSprintRequest request,
  );

  @POST('/{teamId}/sprints/{sprintId}/complete')
  Future<SprintResponse> completeSprint(
    @Path('teamId') String teamId,
    @Path('sprintId') String sprintId,
  );

  @DELETE('/{teamId}/sprints/{sprintId}')
  Future<void> deleteSprint(
    @Path('teamId') String teamId,
    @Path('sprintId') String sprintId,
  );

  @POST('/{teamId}/sprints/{sprintId}/cards')
  Future<void> addCardsToSprint(
    @Path('teamId') String teamId,
    @Path('sprintId') String sprintId,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/{teamId}/sprints/{sprintId}/cards')
  Future<void> removeCardsFromSprint(
    @Path('teamId') String teamId,
    @Path('sprintId') String sprintId,
    @Body() Map<String, dynamic> request,
  );

  // Lists endpoints
  @POST('/{teamId}/lists')
  Future<ListResponse> createList(
    @Path('teamId') String teamId,
    @Body() CreateListRequest request,
  );



  @PUT('/{teamId}/lists/{listId}')
  Future<ListResponse> updateList(
    @Path('teamId') String teamId,
    @Path('listId') String listId,
    @Body() UpdateListRequest request,
  );

  @DELETE('/{teamId}/lists/{listId}')
  Future<void> deleteList(
    @Path('teamId') String teamId,
    @Path('listId') String listId,
  );

  // Templates endpoints
  @GET('/{teamId}/templates')
  Future<TemplatesResponse> getTemplates(
    @Path('teamId') String teamId, {
    @Query('type') String? type,
  });

  @POST('/{teamId}/templates')
  Future<TemplateResponse> createTemplate(
    @Path('teamId') String teamId,
    @Body() CreateTemplateRequest request,
  );

  // Webhooks for real-time updates
  @POST('/{teamId}/webhooks')
  Future<WebhookResponse> createWebhook(
    @Path('teamId') String teamId,
    @Body() CreateWebhookRequest request,
  );

  // Advanced Search endpoints
  @GET('/{teamId}/search')
  Future<SearchResponse> search(
      @Path('teamId') String teamId,
      @Query('query') String query,
      @Query('type') String? type, // 'cards', 'boards', 'notes', 'all'
      @Query('project_id') String? projectId,
      @Query('board_id') String? boardId,
      @Query('list_id') String? listId,
      @Query('assigned_to') String? assignedTo,
      @Query('status') String? status,
      @Query('tags') List<String>? tags,
      @Query('date_from') String? dateFrom,
      @Query('date_to') String? dateTo,
      @Query('page') int? page,
      @Query('limit') int? limit,
      );

  @GET('/{teamId}/search/suggestions')
  Future<SearchSuggestionsResponse> getSearchSuggestions(
      @Path('teamId') String teamId,
      @Query('q') String query,
      @Query('type') String? type,
      @Query('limit') int? limit,
      );

  @POST('/{teamId}/search/save')
  Future<SavedSearchResponse> saveSearch(
      @Path('teamId') String teamId,
      @Body() SaveSearchRequest request,
      );

  @GET('/{teamId}/search/saved')
  Future<SavedSearchesResponse> getSavedSearches(
      @Path('teamId') String teamId,
      );


  // Card relationships endpoints
  @POST('/{teamId}/cards/{cardId}/child-cards')
  Future<CardResponse> addChildCard(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Body() AddChildCardRequest request,
  );

  @DELETE('/{teamId}/cards/{cardId}/child-cards/{childCardId}')
  Future<void> removeChildCard(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Path('childCardId') String childCardId,
  );

  @POST('/{teamId}/cards/{cardId}/linked-cards')
  Future<CardResponse> addLinkedCard(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Body() AddLinkedCardRequest request,
  );

  @DELETE('/{teamId}/cards/{cardId}/linked-cards/{linkedCardId}')
  Future<void> removeLinkedCard(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Path('linkedCardId') String linkedCardId,
  );

  // Checklist endpoints
  @POST('/{teamId}/cards/{cardId}/checklist-items')
  Future<ChecklistItemResponse> createChecklistItem(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Body() CreateChecklistItemRequest request,
  );

  @PUT('/{teamId}/cards/{cardId}/checklist-items/{itemId}')
  Future<ChecklistItemResponse> updateChecklistItem(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Path('itemId') String itemId,
    @Body() UpdateChecklistItemRequest request,
  );

  @DELETE('/{teamId}/cards/{cardId}/checklist-items/{itemId}')
  Future<void> deleteChecklistItem(
    @Path('teamId') String teamId,
    @Path('cardId') String cardId,
    @Path('itemId') String itemId,
  );
}










