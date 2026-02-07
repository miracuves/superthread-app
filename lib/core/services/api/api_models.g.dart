// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['display_name'] as String,
      email: json['email'] as String,
      role: const SafeStringConverter().fromJson(json['role']),
      avatarUrl: const SafeStringConverter().fromJson(json['avatar_url']),
      createdAt: const TimestampConverter().fromJson(json['time_created']),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'display_name': instance.name,
      'email': instance.email,
      'role': const SafeStringConverter().toJson(instance.role),
      'avatar_url': const SafeStringConverter().toJson(instance.avatarUrl),
      'time_created': const TimestampConverter().toJson(instance.createdAt),
      'time_updated': const TimestampConverter().toJson(instance.updatedAt),
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: const SafeStringConverter().fromJson(json['description']),
      teamId: json['team_id'] as String,
      status: const SafeStringConverter().fromJson(json['status']),
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      boards: (json['boards'] as List<dynamic>?)
          ?.map((e) => Board.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': const SafeStringConverter().toJson(instance.description),
      'team_id': instance.teamId,
      'status': const SafeStringConverter().toJson(instance.status),
      'time_created': instance.createdAt.toIso8601String(),
      'time_updated': const TimestampConverter().toJson(instance.updatedAt),
      'boards': instance.boards,
    };

UsersResponse _$UsersResponseFromJson(Map<String, dynamic> json) =>
    UsersResponse(
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: const SafeIntConverter().fromJson(json['total']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );

Map<String, dynamic> _$UsersResponseToJson(UsersResponse instance) =>
    <String, dynamic>{
      'users': instance.users,
      'total': const SafeIntConverter().toJson(instance.total),
      'page': const SafeIntConverter().toJson(instance.page),
      'limit': const SafeIntConverter().toJson(instance.limit),
    };

UpdateProfileRequest _$UpdateProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileRequest(
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$UpdateProfileRequestToJson(
        UpdateProfileRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
    };

ValidateTokenRequest _$ValidateTokenRequestFromJson(
        Map<String, dynamic> json) =>
    ValidateTokenRequest(
      patToken: json['pat_token'] as String,
    );

Map<String, dynamic> _$ValidateTokenRequestToJson(
        ValidateTokenRequest instance) =>
    <String, dynamic>{
      'pat_token': instance.patToken,
    };

ValidateTokenResponse _$ValidateTokenResponseFromJson(
        Map<String, dynamic> json) =>
    ValidateTokenResponse(
      isValid: json['is_valid'] as bool,
      user: ValidateTokenResponse._userFromJson(json['user']),
      teamId: json['team_id'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ValidateTokenResponseToJson(
        ValidateTokenResponse instance) =>
    <String, dynamic>{
      'is_valid': instance.isValid,
      'user': ValidateTokenResponse._userToJson(instance.user),
      'team_id': instance.teamId,
      'message': instance.message,
    };

BoardResponse _$BoardResponseFromJson(Map<String, dynamic> json) =>
    BoardResponse(
      board: Board.fromJson(json['board'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BoardResponseToJson(BoardResponse instance) =>
    <String, dynamic>{
      'board': instance.board,
    };

BoardsResponse _$BoardsResponseFromJson(Map<String, dynamic> json) =>
    BoardsResponse(
      boards: (json['boards'] as List<dynamic>)
          .map((e) => Board.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: const SafeIntConverter().fromJson(json['count']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );

Map<String, dynamic> _$BoardsResponseToJson(BoardsResponse instance) =>
    <String, dynamic>{
      'boards': instance.boards,
      'count': const SafeIntConverter().toJson(instance.total),
      'page': const SafeIntConverter().toJson(instance.page),
      'limit': const SafeIntConverter().toJson(instance.limit),
    };

CardsResponse _$CardsResponseFromJson(Map<String, dynamic> json) =>
    CardsResponse(
      cards: (json['cards'] as List<dynamic>)
          .map((e) => Card.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: const SafeIntConverter().fromJson(json['count']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );

Map<String, dynamic> _$CardsResponseToJson(CardsResponse instance) =>
    <String, dynamic>{
      'cards': instance.cards,
      'count': const SafeIntConverter().toJson(instance.total),
      'page': const SafeIntConverter().toJson(instance.page),
      'limit': const SafeIntConverter().toJson(instance.limit),
    };

NoteResponse _$NoteResponseFromJson(Map<String, dynamic> json) => NoteResponse(
      note: Note.fromJson(json['note'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NoteResponseToJson(NoteResponse instance) =>
    <String, dynamic>{
      'note': instance.note,
    };

NotesResponse _$NotesResponseFromJson(Map<String, dynamic> json) =>
    NotesResponse(
      notes: (json['notes'] as List<dynamic>)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: const SafeIntConverter().fromJson(json['total']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );

Map<String, dynamic> _$NotesResponseToJson(NotesResponse instance) =>
    <String, dynamic>{
      'notes': instance.notes,
      'total': const SafeIntConverter().toJson(instance.total),
      'page': const SafeIntConverter().toJson(instance.page),
      'limit': const SafeIntConverter().toJson(instance.limit),
    };

ProjectResponse _$ProjectResponseFromJson(Map<String, dynamic> json) =>
    ProjectResponse(
      project: Project.fromJson(json['project'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectResponseToJson(ProjectResponse instance) =>
    <String, dynamic>{
      'project': instance.project,
    };

ProjectsResponse _$ProjectsResponseFromJson(Map<String, dynamic> json) =>
    ProjectsResponse(
      projects: (json['projects'] as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: const SafeIntConverter().fromJson(json['total']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );

Map<String, dynamic> _$ProjectsResponseToJson(ProjectsResponse instance) =>
    <String, dynamic>{
      'projects': instance.projects,
      'total': const SafeIntConverter().toJson(instance.total),
      'page': const SafeIntConverter().toJson(instance.page),
      'limit': const SafeIntConverter().toJson(instance.limit),
    };

EpicResponse _$EpicResponseFromJson(Map<String, dynamic> json) => EpicResponse(
      epic: Epic.fromJson(json['epic'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EpicResponseToJson(EpicResponse instance) =>
    <String, dynamic>{
      'epic': instance.epic,
    };

EpicsResponse _$EpicsResponseFromJson(Map<String, dynamic> json) =>
    EpicsResponse(
      epics: (json['epics'] as List<dynamic>)
          .map((e) => Epic.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: const SafeIntConverter().fromJson(json['total']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );

Map<String, dynamic> _$EpicsResponseToJson(EpicsResponse instance) =>
    <String, dynamic>{
      'epics': instance.epics,
      'total': const SafeIntConverter().toJson(instance.total),
      'page': const SafeIntConverter().toJson(instance.page),
      'limit': const SafeIntConverter().toJson(instance.limit),
    };

Sprint _$SprintFromJson(Map<String, dynamic> json) => Sprint(
      id: json['id'] as String,
      name: json['name'] as String,
      description: const SafeStringConverter().fromJson(json['description']),
      teamId: json['team_id'] as String,
      projectId: const SafeStringConverter().fromJson(json['project_id']),
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: const TimestampConverter().fromJson(json['end_date']),
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: DateTime.parse(json['time_updated'] as String),
      cardIds: (json['card_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      goalCount: const SafeIntConverter().fromJson(json['goal_count']),
      completedCount:
          const SafeIntConverter().fromJson(json['completed_count']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SprintToJson(Sprint instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': const SafeStringConverter().toJson(instance.description),
      'team_id': instance.teamId,
      'project_id': const SafeStringConverter().toJson(instance.projectId),
      'status': instance.status,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': const TimestampConverter().toJson(instance.endDate),
      'time_created': instance.createdAt.toIso8601String(),
      'time_updated': instance.updatedAt.toIso8601String(),
      'card_ids': instance.cardIds,
      'goal_count': const SafeIntConverter().toJson(instance.goalCount),
      'completed_count':
          const SafeIntConverter().toJson(instance.completedCount),
      'metadata': instance.metadata,
    };

CreateSprintRequest _$CreateSprintRequestFromJson(Map<String, dynamic> json) =>
    CreateSprintRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      projectId: json['project_id'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: const TimestampConverter().fromJson(json['end_date']),
      cardIds: (json['card_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreateSprintRequestToJson(
        CreateSprintRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'project_id': instance.projectId,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': const TimestampConverter().toJson(instance.endDate),
      'card_ids': instance.cardIds,
      'metadata': instance.metadata,
    };

UpdateSprintRequest _$UpdateSprintRequestFromJson(Map<String, dynamic> json) =>
    UpdateSprintRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      startDate: const TimestampConverter().fromJson(json['start_date']),
      endDate: const TimestampConverter().fromJson(json['end_date']),
      cardIds: (json['card_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateSprintRequestToJson(
        UpdateSprintRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'start_date': const TimestampConverter().toJson(instance.startDate),
      'end_date': const TimestampConverter().toJson(instance.endDate),
      'card_ids': instance.cardIds,
      'metadata': instance.metadata,
    };

SprintResponse _$SprintResponseFromJson(Map<String, dynamic> json) =>
    SprintResponse(
      sprint: Sprint.fromJson(json['sprint'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SprintResponseToJson(SprintResponse instance) =>
    <String, dynamic>{
      'sprint': instance.sprint,
    };

SprintsResponse _$SprintsResponseFromJson(Map<String, dynamic> json) =>
    SprintsResponse(
      sprints: (json['sprints'] as List<dynamic>)
          .map((e) => Sprint.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
      currentPage: (json['current_page'] as num?)?.toInt(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SprintsResponseToJson(SprintsResponse instance) =>
    <String, dynamic>{
      'sprints': instance.sprints,
      'total_count': instance.totalCount,
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
    };

SuperthreadList _$SuperthreadListFromJson(Map<String, dynamic> json) =>
    SuperthreadList(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      behavior: json['behavior'] as String?,
      boardId: json['board_id'] as String,
      projectId: json['project_id'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      cardOrder: json['card_order'] as Map<String, dynamic>,
      totalCards: (json['total_cards'] as num).toInt(),
      user: SuperthreadList._userFromJson(json['user']),
      userUpdated: SuperthreadList._userFromJsonNullable(json['user_updated']),
      timeCreated: (json['time_created'] as num).toInt(),
      timeUpdated: (json['time_updated'] as num).toInt(),
    );

Map<String, dynamic> _$SuperthreadListToJson(SuperthreadList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'team_id': instance.teamId,
      'title': instance.title,
      'content': instance.content,
      'behavior': instance.behavior,
      'board_id': instance.boardId,
      'project_id': instance.projectId,
      'icon': instance.icon,
      'color': instance.color,
      'card_order': instance.cardOrder,
      'total_cards': instance.totalCards,
      'user': SuperthreadList._userToJson(instance.user),
      'user_updated': SuperthreadList._userToJsonNullable(instance.userUpdated),
      'time_created': instance.timeCreated,
      'time_updated': instance.timeUpdated,
    };

ListResponse _$ListResponseFromJson(Map<String, dynamic> json) => ListResponse(
      list: SuperthreadList.fromJson(json['list'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListResponseToJson(ListResponse instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

CreateListRequest _$CreateListRequestFromJson(Map<String, dynamic> json) =>
    CreateListRequest(
      title: json['title'] as String,
      content: json['content'] as String?,
      boardId: json['board_id'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      behavior: json['behavior'] as String?,
      projectId: json['project_id'] as String?,
    );

Map<String, dynamic> _$CreateListRequestToJson(CreateListRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'board_id': instance.boardId,
      'icon': instance.icon,
      'color': instance.color,
      'behavior': instance.behavior,
      'project_id': instance.projectId,
    };

UpdateListRequest _$UpdateListRequestFromJson(Map<String, dynamic> json) =>
    UpdateListRequest(
      title: json['title'] as String?,
      content: json['content'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      behavior: json['behavior'] as String?,
      cardOrder: json['card_order'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateListRequestToJson(UpdateListRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'icon': instance.icon,
      'color': instance.color,
      'behavior': instance.behavior,
      'card_order': instance.cardOrder,
    };

Template _$TemplateFromJson(Map<String, dynamic> json) => Template(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
      meetingContext: json['meeting_context'] as String?,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => TemplateSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPublic: json['is_public'] as bool,
      createdBy: Template._userFromJson(json['created_by']),
      timeCreated: (json['time_created'] as num).toInt(),
      timeUpdated: (json['time_updated'] as num).toInt(),
    );

Map<String, dynamic> _$TemplateToJson(Template instance) => <String, dynamic>{
      'id': instance.id,
      'team_id': instance.teamId,
      'title': instance.title,
      'icon': instance.icon,
      'type': instance.type,
      'meeting_context': instance.meetingContext,
      'sections': instance.sections,
      'is_public': instance.isPublic,
      'created_by': Template._userToJson(instance.createdBy),
      'time_created': instance.timeCreated,
      'time_updated': instance.timeUpdated,
    };

TemplateSection _$TemplateSectionFromJson(Map<String, dynamic> json) =>
    TemplateSection(
      id: json['id'] as String,
      title: json['title'] as String,
      instructions: json['instructions'] as String?,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$TemplateSectionToJson(TemplateSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'instructions': instance.instructions,
      'order': instance.order,
    };

TemplatesResponse _$TemplatesResponseFromJson(Map<String, dynamic> json) =>
    TemplatesResponse(
      templates: (json['templates'] as List<dynamic>)
          .map((e) => Template.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TemplatesResponseToJson(TemplatesResponse instance) =>
    <String, dynamic>{
      'templates': instance.templates,
    };

TemplateResponse _$TemplateResponseFromJson(Map<String, dynamic> json) =>
    TemplateResponse(
      template: Template.fromJson(json['template'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TemplateResponseToJson(TemplateResponse instance) =>
    <String, dynamic>{
      'template': instance.template,
    };

CreateTemplateRequest _$CreateTemplateRequestFromJson(
        Map<String, dynamic> json) =>
    CreateTemplateRequest(
      title: json['title'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
      meetingContext: json['meeting_context'] as String?,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => TemplateSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPublic: json['is_public'] as bool,
    );

Map<String, dynamic> _$CreateTemplateRequestToJson(
        CreateTemplateRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'icon': instance.icon,
      'type': instance.type,
      'meeting_context': instance.meetingContext,
      'sections': instance.sections,
      'is_public': instance.isPublic,
    };

Webhook _$WebhookFromJson(Map<String, dynamic> json) => Webhook(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      url: json['url'] as String,
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
      secret: json['secret'] as String?,
      active: json['active'] as bool,
      createdBy: Webhook._userFromJson(json['created_by']),
      timeCreated: (json['time_created'] as num).toInt(),
      timeUpdated: (json['time_updated'] as num).toInt(),
    );

Map<String, dynamic> _$WebhookToJson(Webhook instance) => <String, dynamic>{
      'id': instance.id,
      'team_id': instance.teamId,
      'url': instance.url,
      'events': instance.events,
      'secret': instance.secret,
      'active': instance.active,
      'created_by': Webhook._userToJson(instance.createdBy),
      'time_created': instance.timeCreated,
      'time_updated': instance.timeUpdated,
    };

WebhookResponse _$WebhookResponseFromJson(Map<String, dynamic> json) =>
    WebhookResponse(
      webhook: Webhook.fromJson(json['webhook'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WebhookResponseToJson(WebhookResponse instance) =>
    <String, dynamic>{
      'webhook': instance.webhook,
    };

CreateWebhookRequest _$CreateWebhookRequestFromJson(
        Map<String, dynamic> json) =>
    CreateWebhookRequest(
      url: json['url'] as String,
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
      secret: json['secret'] as String?,
    );

Map<String, dynamic> _$CreateWebhookRequestToJson(
        CreateWebhookRequest instance) =>
    <String, dynamic>{
      'url': instance.url,
      'events': instance.events,
      'secret': instance.secret,
    };

CardRelationship _$CardRelationshipFromJson(Map<String, dynamic> json) =>
    CardRelationship(
      cardId: json['card_id'] as String,
      title: json['title'] as String,
      boardId: json['board_id'] as String?,
      boardTitle: json['board_title'] as String?,
      listId: json['list_id'] as String?,
      listTitle: json['list_title'] as String?,
      listColor: json['list_color'] as String?,
      status: json['status'] as String,
      archived: json['archived'] as bool?,
    );

Map<String, dynamic> _$CardRelationshipToJson(CardRelationship instance) =>
    <String, dynamic>{
      'card_id': instance.cardId,
      'title': instance.title,
      'board_id': instance.boardId,
      'board_title': instance.boardTitle,
      'list_id': instance.listId,
      'list_title': instance.listTitle,
      'list_color': instance.listColor,
      'status': instance.status,
      'archived': instance.archived,
    };

ChecklistItem _$ChecklistItemFromJson(Map<String, dynamic> json) =>
    ChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      checklistId: json['checklist_id'] as String,
      userId: json['user_id'] as String,
      checked: json['checked'] as bool,
      timeCreated: (json['time_created'] as num).toInt(),
      timeUpdated: (json['time_updated'] as num).toInt(),
    );

Map<String, dynamic> _$ChecklistItemToJson(ChecklistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'checklist_id': instance.checklistId,
      'user_id': instance.userId,
      'checked': instance.checked,
      'time_created': instance.timeCreated,
      'time_updated': instance.timeUpdated,
    };

Checklist _$ChecklistFromJson(Map<String, dynamic> json) => Checklist(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      cardId: json['card_id'] as String,
      userId: json['user_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeCreated: (json['time_created'] as num).toInt(),
      timeUpdated: (json['time_updated'] as num).toInt(),
    );

Map<String, dynamic> _$ChecklistToJson(Checklist instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'card_id': instance.cardId,
      'user_id': instance.userId,
      'items': instance.items,
      'time_created': instance.timeCreated,
      'time_updated': instance.timeUpdated,
    };

CardMember _$CardMemberFromJson(Map<String, dynamic> json) => CardMember(
      userId: json['user_id'] as String,
      assignedDate: json['assigned_date'] as String?,
      role: json['role'] as String,
    );

Map<String, dynamic> _$CardMemberToJson(CardMember instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'assigned_date': instance.assignedDate,
      'role': instance.role,
    };

RealtimeEvent _$RealtimeEventFromJson(Map<String, dynamic> json) =>
    RealtimeEvent(
      type: json['type'] as String,
      teamId: json['team_id'] as String,
      userId: json['user_id'] as String?,
      data: json['data'] as Map<String, dynamic>,
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$RealtimeEventToJson(RealtimeEvent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'team_id': instance.teamId,
      'user_id': instance.userId,
      'data': instance.data,
      'timestamp': instance.timestamp,
    };

UserPresence _$UserPresenceFromJson(Map<String, dynamic> json) => UserPresence(
      userId: json['user_id'] as String,
      cardId: json['card_id'] as String?,
      boardId: json['board_id'] as String?,
      status: json['status'] as String,
      lastSeen: (json['last_seen'] as num).toInt(),
    );

Map<String, dynamic> _$UserPresenceToJson(UserPresence instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'card_id': instance.cardId,
      'board_id': instance.boardId,
      'status': instance.status,
      'last_seen': instance.lastSeen,
    };

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      teamId: json['team_id'] as String?,
      projectId: json['project_id'] as String?,
      boardId: json['board_id'] as String?,
      listId: json['list_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: json['status'] as String?,
      createdAt: const TimestampConverter().fromJson(json['time_created']),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      relevanceScore: (json['relevance_score'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
      'team_id': instance.teamId,
      'project_id': instance.projectId,
      'board_id': instance.boardId,
      'list_id': instance.listId,
      'assigned_to': instance.assignedTo,
      'tags': instance.tags,
      'status': instance.status,
      'time_created': const TimestampConverter().toJson(instance.createdAt),
      'time_updated': const TimestampConverter().toJson(instance.updatedAt),
      'relevance_score': instance.relevanceScore,
      'metadata': instance.metadata,
    };

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    SearchResponse(
      results: (json['results'] as List<dynamic>)
          .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
      currentPage: (json['current_page'] as num?)?.toInt(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
      query: json['query'] as String?,
      filters: json['filters'] as Map<String, dynamic>?,
      searchTime: (json['search_time'] as num).toInt(),
    );

Map<String, dynamic> _$SearchResponseToJson(SearchResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
      'total_count': instance.totalCount,
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
      'query': instance.query,
      'filters': instance.filters,
      'search_time': instance.searchTime,
    };

SearchSuggestion _$SearchSuggestionFromJson(Map<String, dynamic> json) =>
    SearchSuggestion(
      text: json['text'] as String,
      type: json['type'] as String,
      frequency: (json['frequency'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SearchSuggestionToJson(SearchSuggestion instance) =>
    <String, dynamic>{
      'text': instance.text,
      'type': instance.type,
      'frequency': instance.frequency,
      'metadata': instance.metadata,
    };

SearchSuggestionsResponse _$SearchSuggestionsResponseFromJson(
        Map<String, dynamic> json) =>
    SearchSuggestionsResponse(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      query: json['query'] as String,
    );

Map<String, dynamic> _$SearchSuggestionsResponseToJson(
        SearchSuggestionsResponse instance) =>
    <String, dynamic>{
      'suggestions': instance.suggestions,
      'query': instance.query,
    };

SavedSearch _$SavedSearchFromJson(Map<String, dynamic> json) => SavedSearch(
      id: json['id'] as String,
      name: json['name'] as String,
      query: json['query'] as String,
      filters: json['filters'] as Map<String, dynamic>?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUsed: json['last_used'] == null
          ? null
          : DateTime.parse(json['last_used'] as String),
    );

Map<String, dynamic> _$SavedSearchToJson(SavedSearch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'query': instance.query,
      'filters': instance.filters,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
      'last_used': instance.lastUsed?.toIso8601String(),
    };

SaveSearchRequest _$SaveSearchRequestFromJson(Map<String, dynamic> json) =>
    SaveSearchRequest(
      name: json['name'] as String,
      query: json['query'] as String,
      filters: json['filters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SaveSearchRequestToJson(SaveSearchRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'query': instance.query,
      'filters': instance.filters,
    };

SavedSearchResponse _$SavedSearchResponseFromJson(Map<String, dynamic> json) =>
    SavedSearchResponse(
      savedSearch:
          SavedSearch.fromJson(json['saved_search'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SavedSearchResponseToJson(
        SavedSearchResponse instance) =>
    <String, dynamic>{
      'saved_search': instance.savedSearch,
    };

SavedSearchesResponse _$SavedSearchesResponseFromJson(
        Map<String, dynamic> json) =>
    SavedSearchesResponse(
      savedSearches: (json['saved_searches'] as List<dynamic>)
          .map((e) => SavedSearch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SavedSearchesResponseToJson(
        SavedSearchesResponse instance) =>
    <String, dynamic>{
      'saved_searches': instance.savedSearches,
    };

AddChildCardRequest _$AddChildCardRequestFromJson(Map<String, dynamic> json) =>
    AddChildCardRequest(
      childCardId: json['child_card_id'] as String,
    );

Map<String, dynamic> _$AddChildCardRequestToJson(
        AddChildCardRequest instance) =>
    <String, dynamic>{
      'child_card_id': instance.childCardId,
    };

AddLinkedCardRequest _$AddLinkedCardRequestFromJson(
        Map<String, dynamic> json) =>
    AddLinkedCardRequest(
      linkedCardId: json['linked_card_id'] as String,
    );

Map<String, dynamic> _$AddLinkedCardRequestToJson(
        AddLinkedCardRequest instance) =>
    <String, dynamic>{
      'linked_card_id': instance.linkedCardId,
    };

CreateChecklistItemRequest _$CreateChecklistItemRequestFromJson(
        Map<String, dynamic> json) =>
    CreateChecklistItemRequest(
      text: json['text'] as String,
      position: (json['position'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateChecklistItemRequestToJson(
        CreateChecklistItemRequest instance) =>
    <String, dynamic>{
      'text': instance.text,
      'position': instance.position,
    };

UpdateChecklistItemRequest _$UpdateChecklistItemRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateChecklistItemRequest(
      text: json['text'] as String?,
      isCompleted: json['is_completed'] as bool?,
      position: (json['position'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateChecklistItemRequestToJson(
        UpdateChecklistItemRequest instance) =>
    <String, dynamic>{
      'text': instance.text,
      'is_completed': instance.isCompleted,
      'position': instance.position,
    };

CardResponse _$CardResponseFromJson(Map<String, dynamic> json) => CardResponse(
      card: Card.fromJson(json['card'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CardResponseToJson(CardResponse instance) =>
    <String, dynamic>{
      'card': instance.card,
    };

CommentsResponse _$CommentsResponseFromJson(Map<String, dynamic> json) =>
    CommentsResponse(
      comments: (json['comments'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommentsResponseToJson(CommentsResponse instance) =>
    <String, dynamic>{
      'comments': instance.comments,
    };

CommentResponse _$CommentResponseFromJson(Map<String, dynamic> json) =>
    CommentResponse(
      comment: Comment.fromJson(json['comment'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentResponseToJson(CommentResponse instance) =>
    <String, dynamic>{
      'comment': instance.comment,
    };

AttachmentsResponse _$AttachmentsResponseFromJson(Map<String, dynamic> json) =>
    AttachmentsResponse(
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AttachmentsResponseToJson(
        AttachmentsResponse instance) =>
    <String, dynamic>{
      'attachments': instance.attachments,
    };

AttachmentResponse _$AttachmentResponseFromJson(Map<String, dynamic> json) =>
    AttachmentResponse(
      attachment:
          Attachment.fromJson(json['attachment'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttachmentResponseToJson(AttachmentResponse instance) =>
    <String, dynamic>{
      'attachment': instance.attachment,
    };

ChecklistItemResponse _$ChecklistItemResponseFromJson(
        Map<String, dynamic> json) =>
    ChecklistItemResponse(
      checklistItem: ChecklistItem.fromJson(
          json['checklist_item'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChecklistItemResponseToJson(
        ChecklistItemResponse instance) =>
    <String, dynamic>{
      'checklist_item': instance.checklistItem,
    };

ViewPreviewRequest _$ViewPreviewRequestFromJson(Map<String, dynamic> json) =>
    ViewPreviewRequest(
      type: json['type'] as String,
      cardFilters: json['card_filters'] == null
          ? null
          : ViewCardFilters.fromJson(
              json['card_filters'] as Map<String, dynamic>),
      boardFilters: json['board_filters'] as Map<String, dynamic>?,
      pageFilters: json['page_filters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ViewPreviewRequestToJson(ViewPreviewRequest instance) {
  final val = <String, dynamic>{
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('card_filters', instance.cardFilters);
  writeNotNull('board_filters', instance.boardFilters);
  writeNotNull('page_filters', instance.pageFilters);
  return val;
}

ViewCardFilters _$ViewCardFiltersFromJson(Map<String, dynamic> json) =>
    ViewCardFilters(
      include: json['include'] == null
          ? null
          : ViewIncludeFilters.fromJson(
              json['include'] as Map<String, dynamic>),
      hasStatus: json['has_status'] as bool?,
      archived: json['archived'] as bool?,
    );

Map<String, dynamic> _$ViewCardFiltersToJson(ViewCardFilters instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('include', instance.include);
  writeNotNull('has_status', instance.hasStatus);
  writeNotNull('archived', instance.archived);
  return val;
}

ViewIncludeFilters _$ViewIncludeFiltersFromJson(Map<String, dynamic> json) =>
    ViewIncludeFilters(
      members:
          (json['members'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ViewIncludeFiltersToJson(ViewIncludeFilters instance) =>
    <String, dynamic>{
      'members': instance.members,
    };
