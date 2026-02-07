import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../data/models/card.dart';
import '../../../data/models/board.dart';
import '../../../data/models/note.dart';
import '../../../data/models/epic.dart';
export '../../../data/models/epic.dart';
import 'converters.dart';

part 'api_models.g.dart';

// Core user models
@JsonSerializable(fieldRename: FieldRename.snake)
class User extends Equatable {
  @SafeStringConverter()
  final String id;
  @SafeStringConverter()
  @JsonKey(name: 'display_name')
  final String name;
  @SafeStringConverter()
  final String email;
  @SafeStringConverter()
  final String? role; // User role in workspace (admin, member, etc.)
  @SafeStringConverter()
  final String? avatarUrl;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime? createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final timeConverter = const TimestampConverter();
    return User(
      id: strConverter.fromJson(json['id']) ?? '',
      name: strConverter.fromJson(json['display_name'] ?? json['name']) ?? '',
      email: strConverter.fromJson(json['email']) ?? '',
      role: strConverter.fromJson(json['role']),
      avatarUrl: strConverter.fromJson(json['avatar_url']),
      createdAt: timeConverter.fromJson(json['time_created']),
      updatedAt: timeConverter.fromJson(json['time_updated']),
    );
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, name, email, role, avatarUrl, createdAt, updatedAt];
}

// Project model
@JsonSerializable(fieldRename: FieldRename.snake)
class Project extends Equatable {
  @SafeStringConverter()
  final String id;
  @SafeStringConverter()
  final String name;
  @SafeStringConverter()
  final String? description;
  @SafeStringConverter()
  final String teamId;
  @SafeStringConverter()
  final String? status;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;

  final List<Board>? boards;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.teamId,
    this.status,
    required this.createdAt,
    this.updatedAt,
    this.boards,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final timeConverter = const TimestampConverter();
    return Project(
      id: strConverter.fromJson(json['id']) ?? '',
      name: strConverter.fromJson(json['title'] ?? json['name']) ?? '',
      description: strConverter.fromJson(json['content'] ?? json['description']),
      teamId: strConverter.fromJson(json['team_id']) ?? '',
      status: strConverter.fromJson(json['status']),
      createdAt: timeConverter.fromJson(json['time_created'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: timeConverter.fromJson(json['time_updated'] ?? json['updated_at']),
      boards: (json['boards'] as List?)?.map((e) {
        final board = Board.fromJson(e as Map<String, dynamic>);
        // Propagate teamId if missing in board JSON
        if (board.teamId.isEmpty) {
          final parentTeamId = strConverter.fromJson(json['team_id']) ?? '';
          return board.copyWith(teamId: parentTeamId);
        }
        return board;
      }).toList(),
    );
  }
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  @override
  List<Object?> get props => [id, name, description, teamId, status, createdAt, updatedAt, boards];
}

class UserResponse extends Equatable {
  final User user;
  final String? teamId; // Extract team ID from teams array

  UserResponse({required this.user, this.teamId});

  /// Custom factory for Superthread `/users/me` envelope shape.
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final user = User.fromJson(userJson);
    
    // Extract team ID from user.teams[0].id if available
    String? teamId;
    final teams = userJson['teams'] as List<dynamic>?;
    if (teams != null && teams.isNotEmpty) {
      final firstTeam = teams[0] as Map<String, dynamic>;
      teamId = firstTeam['id'] as String?;
    }
    
    return UserResponse(
      user: user,
      teamId: teamId,
    );
  }

  Map<String, dynamic> toJson() => {'user': user.toJson()};

  @override
  List<Object?> get props => [user, teamId];
}

// Users list response
@JsonSerializable(fieldRename: FieldRename.snake)
class UsersResponse extends Equatable {
  final List<User> users;
  @SafeIntConverter()
  final int? total;
  @SafeIntConverter()
  final int? page;
  @SafeIntConverter()
  final int? limit;

  const UsersResponse({
    required this.users,
    this.total,
    this.page,
    this.limit,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    // API returns 'members' array, not 'users'
    final membersData = json['members'] ?? json['users'];
    
    return UsersResponse(
      users: (membersData as List?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      total: const SafeIntConverter().fromJson(json['total']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );
  }
  Map<String, dynamic> toJson() => _$UsersResponseToJson(this);

  @override
  List<Object?> get props => [users, total, page, limit];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateProfileRequest extends Equatable {
  final String? name;
  final String? email;
  final String? avatarUrl;

  UpdateProfileRequest({this.name, this.email, this.avatarUrl});

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);

  @override
  List<Object?> get props => [name, email, avatarUrl];
}

// Token validation models
@JsonSerializable(fieldRename: FieldRename.snake)
class ValidateTokenRequest extends Equatable {
  final String patToken;

  const ValidateTokenRequest({required this.patToken});

  factory ValidateTokenRequest.fromJson(Map<String, dynamic> json) => _$ValidateTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ValidateTokenRequestToJson(this);

  @override
  List<Object> get props => [patToken];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ValidateTokenResponse extends Equatable {
  final bool isValid;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final User? user;
  final String? teamId;
  final String? message;

  static User? _userFromJson(dynamic json) => json != null ? User.fromJson(json as Map<String, dynamic>) : null;
  static Map<String, dynamic>? _userToJson(User? user) => user?.toJson();

  const ValidateTokenResponse({
    required this.isValid,
    this.user,
    this.teamId,
    this.message,
  });

  factory ValidateTokenResponse.fromJson(Map<String, dynamic> json) => _$ValidateTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ValidateTokenResponseToJson(this);

  @override
  List<Object?> get props => [isValid, user, teamId, message];
}

// Board response models
@JsonSerializable(fieldRename: FieldRename.snake)
class BoardResponse extends Equatable {
  final Board board;

  const BoardResponse({
    required this.board,
  });

  factory BoardResponse.fromJson(Map<String, dynamic> json) => _$BoardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BoardResponseToJson(this);

  @override
  List<Object?> get props => [board];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BoardsResponse extends Equatable {
  final List<Board> boards;
  @JsonKey(name: 'count')
  @SafeIntConverter()
  final int? total;
  @SafeIntConverter()
  final int? page;
  @SafeIntConverter()
  final int? limit;

  const BoardsResponse({
    required this.boards,
    this.total,
    this.page,
    this.limit,
  });

  factory BoardsResponse.fromJson(Map<String, dynamic> json) {
    return BoardsResponse(
      boards: (json['boards'] as List?)
          ?.map((e) => Board.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      total: const SafeIntConverter().fromJson(json['count'] ?? json['total']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );
  }
  Map<String, dynamic> toJson() => _$BoardsResponseToJson(this);

  @override
  List<Object?> get props => [boards, total, page, limit];
}

// Card response models
@JsonSerializable(fieldRename: FieldRename.snake)
class CardsResponse extends Equatable {
  final List<Card> cards;
  @JsonKey(name: 'count')
  @SafeIntConverter()
  final int? total;
  @SafeIntConverter()
  final int? page;
  @SafeIntConverter()
  final int? limit;

  const CardsResponse({
    required this.cards,
    this.total,
    this.page,
    this.limit,
  });

  factory CardsResponse.fromJson(Map<String, dynamic> json) {
    return CardsResponse(
      cards: (() {
        final allCards = <dynamic>[];
        
        // 1. Top-level 'cards'
        final topCards = json['cards'] as List?;
        if (topCards != null) allCards.addAll(topCards);
        
        // 2. 'lists' -> 'cards' or 'child_cards'
        final lists = json['lists'] as List?;
        if (lists != null) {
          for (final list in lists) {
            if (list is Map<String, dynamic>) {
              final nestedCards = (list['cards'] ?? list['child_cards']) as List?;
              if (nestedCards != null) allCards.addAll(nestedCards);
              
              // Also check nested epics for child_cards
              final nestedEpics = list['epics'] as List?;
              if (nestedEpics != null) {
                for (final epic in nestedEpics) {
                  if (epic is Map<String, dynamic>) {
                    final childCards = epic['child_cards'] as List?;
                    if (childCards != null) allCards.addAll(childCards);
                  }
                }
              }
            }
          }
        }

        // 3. Top-level 'epics' -> 'child_cards'
        final epics = json['epics'] as List?;
        if (epics != null) {
          for (final epic in epics) {
            if (epic is Map<String, dynamic>) {
              final childCards = epic['child_cards'] as List?;
              if (childCards != null) allCards.addAll(childCards);
            }
          }
        }

        // Use a Set to avoid duplicates
        final seenIds = <String>{};
        final uniqueCards = <Map<String, dynamic>>[];
        
        for (final c in allCards) {
          if (c is Map<String, dynamic>) {
            final id = (c['id'] ?? c['card_id'])?.toString();
            if (id != null && !seenIds.contains(id)) {
              seenIds.add(id);
              uniqueCards.add(c);
            }
          }
        }

        return uniqueCards;
      })()
          .map((e) => Card.fromJson(e))
          .toList(),
      total: const SafeIntConverter().fromJson(json['count'] ?? json['total']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );
  }
  Map<String, dynamic> toJson() => _$CardsResponseToJson(this);

  @override
  List<Object?> get props => [cards, total, page, limit];
}

// Note response models
@JsonSerializable(fieldRename: FieldRename.snake)
class NoteResponse extends Equatable {
  final Note note;

  const NoteResponse({
    required this.note,
  });

  factory NoteResponse.fromJson(Map<String, dynamic> json) => _$NoteResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NoteResponseToJson(this);

  @override
  List<Object?> get props => [note];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotesResponse extends Equatable {
  final List<Note> notes;
  @SafeIntConverter()
  final int? total;
  @SafeIntConverter()
  final int? page;
  @SafeIntConverter()
  final int? limit;

  const NotesResponse({
    required this.notes,
    this.total,
    this.page,
    this.limit,
  });

  factory NotesResponse.fromJson(Map<String, dynamic> json) {
    return NotesResponse(
      notes: (json['notes'] as List?)
          ?.map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      total: const SafeIntConverter().fromJson(json['total']),
      page: const SafeIntConverter().fromJson(json['page']),
      limit: const SafeIntConverter().fromJson(json['limit']),
    );
  }
  Map<String, dynamic> toJson() => _$NotesResponseToJson(this);

  @override
  List<Object?> get props => [notes, total, page, limit];
}

// Project response models
@JsonSerializable(fieldRename: FieldRename.snake)
class ProjectResponse extends Equatable {
  final Project project;

  const ProjectResponse({
    required this.project,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      project: Project.fromJson(json['project'] as Map<String, dynamic>? ?? json),
    );
  }
  Map<String, dynamic> toJson() => _$ProjectResponseToJson(this);

  @override
  List<Object?> get props => [project];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ProjectsResponse extends Equatable {
  final List<Project> projects;
  @SafeIntConverter()
  final int? total;
  @SafeIntConverter()
  final int? page;
  @SafeIntConverter()
  final int? limit;

  const ProjectsResponse({
    required this.projects,
    this.total,
    this.page,
    this.limit,
  });

  factory ProjectsResponse.fromJson(Map<String, dynamic> json) {
    final intConverter = const SafeIntConverter();
    return ProjectsResponse(
      projects: (() {
        final projects = json['projects'] as List?;
        if (projects != null && projects.isNotEmpty) return projects;
        final epics = json['epics'] as List?;
        if (epics != null && epics.isNotEmpty) return epics;
        return (projects ?? epics ?? []);
      })()
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: intConverter.fromJson(json['total_projects_count'] ?? json['total_epics_count'] ?? json['total']),
      page: intConverter.fromJson(json['page']),
      limit: intConverter.fromJson(json['limit']),
    );
  }
  Map<String, dynamic> toJson() => _$ProjectsResponseToJson(this);

  @override
  List<Object?> get props => [projects, total, page, limit];
}

// Epic response models
@JsonSerializable(fieldRename: FieldRename.snake)
class EpicResponse extends Equatable {
  final Epic epic;

  const EpicResponse({required this.epic});

  factory EpicResponse.fromJson(Map<String, dynamic> json) {
    return EpicResponse(
      epic: Epic.fromJson(json['epic'] as Map<String, dynamic>? ?? json),
    );
  }
  Map<String, dynamic> toJson() => _$EpicResponseToJson(this);

  @override
  List<Object?> get props => [epic];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EpicsResponse extends Equatable {
  final List<Epic> epics;
  @SafeIntConverter()
  final int? total;
  @SafeIntConverter()
  final int? page;
  @SafeIntConverter()
  final int? limit;

  const EpicsResponse({
    required this.epics,
    this.total,
    this.page,
    this.limit,
  });

  factory EpicsResponse.fromJson(Map<String, dynamic> json) {
    final intConverter = const SafeIntConverter();
    return EpicsResponse(
      epics: (() {
        final allEpics = <dynamic>[];
        
        // 1. Top-level 'epics'
        final topEpics = json['epics'] as List?;
        if (topEpics != null) allEpics.addAll(topEpics);
        
        // 2. 'lists' -> 'epics' (Deep extraction)
        final lists = json['lists'] as List?;
        if (lists != null) {
          for (final list in lists) {
            if (list is Map<String, dynamic>) {
              final nestedEpics = list['epics'] as List?;
              if (nestedEpics != null) allEpics.addAll(nestedEpics);
            }
          }
        }

        // 3. Top-level 'projects'
        final projects = json['projects'] as List?;
        if (projects != null) allEpics.addAll(projects);
        
        // 4. Top-level 'boards'
        final boards = json['boards'] as List?;
        if (boards != null) allEpics.addAll(boards);
        
        // Use a Set to avoid duplicates if same epic is in multiple places
        final seenIds = <String>{};
        final uniqueEpics = <Map<String, dynamic>>[];
        
        for (final e in allEpics) {
          if (e is Map<String, dynamic>) {
            final id = e['id']?.toString();
            if (id != null && !seenIds.contains(id)) {
              seenIds.add(id);
              uniqueEpics.add(e);
            }
          }
        }

        return uniqueEpics;
      })()
          .map((e) => Epic.fromJson(e))
          .toList(),
      total: intConverter.fromJson(json['total_epics_count'] ?? json['total_projects_count'] ?? json['total']),
      page: intConverter.fromJson(json['page']),
      limit: intConverter.fromJson(json['limit']),
    );
  }
  Map<String, dynamic> toJson() => _$EpicsResponseToJson(this);

  @override
  List<Object?> get props => [epics, total, page, limit];
}


// Sprint model classes
@JsonSerializable(fieldRename: FieldRename.snake)
class Sprint extends Equatable {
  @SafeStringConverter()
  final String id;
  @SafeStringConverter()
  final String name;
  @SafeStringConverter()
  final String? description;
  @SafeStringConverter()
  final String teamId;
  @SafeStringConverter()
  final String? projectId;
  final String status; // 'active', 'completed', 'planned'
  @TimestampConverter()
  final DateTime startDate;
  @TimestampConverter()
  final DateTime? endDate;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime updatedAt;
  @SafeStringListConverter()
  final List<String> cardIds;
  @SafeIntConverter()
  final int? goalCount;
  @SafeIntConverter()
  final int? completedCount;
  final Map<String, dynamic>? metadata;

  const Sprint({
    required this.id,
    required this.name,
    this.description,
    required this.teamId,
    this.projectId,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.cardIds = const [],
    this.goalCount,
    this.completedCount,
    this.metadata,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final intConverter = const SafeIntConverter();
    final timeConverter = const TimestampConverter();
    return Sprint(
      id: strConverter.fromJson(json['id']) ?? '',
      name: strConverter.fromJson(json['name']) ?? '',
      description: strConverter.fromJson(json['description']),
      teamId: strConverter.fromJson(json['team_id']) ?? '',
      projectId: strConverter.fromJson(json['project_id']),
      status: strConverter.fromJson(json['status']) ?? '',
      startDate: timeConverter.fromJson(json['start_date']) ?? DateTime.now(),
      endDate: timeConverter.fromJson(json['end_date']),
      createdAt: timeConverter.fromJson(json['time_created']) ?? DateTime.now(),
      updatedAt: timeConverter.fromJson(json['time_updated']) ?? DateTime.now(),
      cardIds: (json['card_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      goalCount: intConverter.fromJson(json['goal_count']),
      completedCount: intConverter.fromJson(json['completed_count']),
      metadata: (json['metadata'] is Map) ? Map<String, dynamic>.from(json['metadata'] as Map) : null,
    );
  }
  Map<String, dynamic> toJson() => _$SprintToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        teamId,
        projectId,
        status,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        cardIds,
        goalCount,
        completedCount,
        metadata,
      ];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateSprintRequest extends Equatable {
  final String name;
  final String? description;
  final String? projectId;
  @TimestampConverter()
  final DateTime startDate;
  @TimestampConverter()
  final DateTime? endDate;
  final List<String>? cardIds;
  final Map<String, dynamic>? metadata;

  const CreateSprintRequest({
    required this.name,
    this.description,
    this.projectId,
    required this.startDate,
    this.endDate,
    this.cardIds,
    this.metadata,
  });

  factory CreateSprintRequest.fromJson(Map<String, dynamic> json) => _$CreateSprintRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSprintRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        description,
        projectId,
        startDate,
        endDate,
        cardIds,
        metadata,
      ];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateSprintRequest extends Equatable {
  final String? name;
  final String? description;
  final String? status;
  @TimestampConverter()
  final DateTime? startDate;
  @TimestampConverter()
  final DateTime? endDate;
  final List<String>? cardIds;
  final Map<String, dynamic>? metadata;

  const UpdateSprintRequest({
    this.name,
    this.description,
    this.status,
    this.startDate,
    this.endDate,
    this.cardIds,
    this.metadata,
  });

  factory UpdateSprintRequest.fromJson(Map<String, dynamic> json) => _$UpdateSprintRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateSprintRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        description,
        status,
        startDate,
        endDate,
        cardIds,
        metadata,
      ];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SprintResponse extends Equatable {
  final Sprint sprint;

  const SprintResponse({required this.sprint});

  factory SprintResponse.fromJson(Map<String, dynamic> json) => _$SprintResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SprintResponseToJson(this);

  @override
  List<Object> get props => [sprint];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SprintsResponse extends Equatable {
  final List<Sprint> sprints;
  final int totalCount;
  final int? currentPage;
  final int? totalPages;

  const SprintsResponse({
    required this.sprints,
    required this.totalCount,
    this.currentPage,
    this.totalPages,
  });

  factory SprintsResponse.fromJson(Map<String, dynamic> json) {
    return SprintsResponse(
      sprints: (json['sprints'] as List?)
          ?.map((e) => Sprint.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalCount: const SafeIntConverter().fromJson(json['total_count']) ?? 0,
      currentPage: const SafeIntConverter().fromJson(json['current_page']),
      totalPages: const SafeIntConverter().fromJson(json['total_pages']),
    );
  }
  Map<String, dynamic> toJson() => _$SprintsResponseToJson(this);

  @override
  List<Object?> get props => [sprints, totalCount, currentPage, totalPages];
}

// List model classes
@JsonSerializable(fieldRename: FieldRename.snake)
class SuperthreadList {
  final String id;
  final String teamId;
  final String title;
  final String? content;
  final String? behavior; // 'backlog', 'normal', etc.
  final String boardId;
  final String? projectId;
  final String? icon;
  final String? color;
  final Map<String, dynamic> cardOrder;
  final int totalCards;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final User user;
  @JsonKey(fromJson: _userFromJsonNullable, toJson: _userToJsonNullable)
  final User? userUpdated;
  final int timeCreated;
  final int timeUpdated;

  static User _userFromJson(dynamic json) => User.fromJson(json as Map<String, dynamic>);
  static Map<String, dynamic> _userToJson(User user) => user.toJson();
  static User? _userFromJsonNullable(dynamic json) => json != null ? User.fromJson(json as Map<String, dynamic>) : null;
  static Map<String, dynamic>? _userToJsonNullable(User? user) => user?.toJson();

  SuperthreadList({
    required this.id,
    required this.teamId,
    required this.title,
    this.content,
    this.behavior,
    required this.boardId,
    this.projectId,
    this.icon,
    this.color,
    required this.cardOrder,
    required this.totalCards,
    required this.user,
    this.userUpdated,
    required this.timeCreated,
    required this.timeUpdated,
  });

  factory SuperthreadList.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final intConverter = const SafeIntConverter();
    return SuperthreadList(
      id: strConverter.fromJson(json['id']) ?? '',
      teamId: strConverter.fromJson(json['team_id']) ?? '',
      title: strConverter.fromJson(json['title']) ?? '',
      content: strConverter.fromJson(json['content']),
      behavior: strConverter.fromJson(json['behavior']),
      boardId: strConverter.fromJson(json['board_id']) ?? '',
      projectId: strConverter.fromJson(json['project_id']),
      icon: strConverter.fromJson(json['icon']),
      color: strConverter.fromJson(json['color']),
      cardOrder: (json['card_order'] is Map) ? Map<String, dynamic>.from(json['card_order'] as Map) : {},
      totalCards: intConverter.fromJson(json['total_cards']) ?? 0,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : User(id: '', name: 'Unknown', email: ''),
      userUpdated: json['user_updated'] != null ? User.fromJson(json['user_updated'] as Map<String, dynamic>) : null,
      timeCreated: intConverter.fromJson(json['time_created']) ?? 0,
      timeUpdated: intConverter.fromJson(json['time_updated']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$SuperthreadListToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ListResponse {
  final SuperthreadList list;

  ListResponse({required this.list});

  factory ListResponse.fromJson(Map<String, dynamic> json) =>
      _$ListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateListRequest {
  final String title;
  final String? content;
  final String boardId;
  final String? icon;
  final String? color;
  final String? behavior;
  final String? projectId;

  CreateListRequest({
    required this.title,
    this.content,
    required this.boardId,
    this.icon,
    this.color,
    this.behavior,
    this.projectId,
  });

  factory CreateListRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateListRequest {
  final String? title;
  final String? content;
  final String? icon;
  final String? color;
  final String? behavior;
  final Map<String, dynamic>? cardOrder;

  UpdateListRequest({
    this.title,
    this.content,
    this.icon,
    this.color,
    this.behavior,
    this.cardOrder,
  });

  factory UpdateListRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateListRequestToJson(this);
}

// Template model classes
@JsonSerializable(fieldRename: FieldRename.snake)
class Template {
  final String id;
  final String teamId;
  final String title;
  final String? icon;
  final String type; // 'note', 'card', 'board', 'sprint'
  final String? meetingContext;
  final List<TemplateSection> sections;
  final bool isPublic;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final User createdBy;
  final int timeCreated;
  final int timeUpdated;

  static User _userFromJson(dynamic json) => User.fromJson(json as Map<String, dynamic>);
  static Map<String, dynamic> _userToJson(User user) => user.toJson();

  Template({
    required this.id,
    required this.teamId,
    required this.title,
    this.icon,
    required this.type,
    this.meetingContext,
    required this.sections,
    required this.isPublic,
    required this.createdBy,
    required this.timeCreated,
    required this.timeUpdated,
  });

  factory Template.fromJson(Map<String, dynamic> json) =>
      _$TemplateFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TemplateSection {
  final String id;
  final String title;
  final String? instructions;
  final int order;

  TemplateSection({
    required this.id,
    required this.title,
    this.instructions,
    required this.order,
  });

  factory TemplateSection.fromJson(Map<String, dynamic> json) =>
      _$TemplateSectionFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateSectionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TemplatesResponse {
  final List<Template> templates;

  TemplatesResponse({required this.templates});

  factory TemplatesResponse.fromJson(Map<String, dynamic> json) =>
      _$TemplatesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TemplatesResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TemplateResponse {
  final Template template;

  TemplateResponse({required this.template});

  factory TemplateResponse.fromJson(Map<String, dynamic> json) =>
      _$TemplateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateTemplateRequest {
  final String title;
  final String? icon;
  final String type;
  final String? meetingContext;
  final List<TemplateSection> sections;
  final bool isPublic;

  CreateTemplateRequest({
    required this.title,
    this.icon,
    required this.type,
    this.meetingContext,
    required this.sections,
    required this.isPublic,
  });

  factory CreateTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTemplateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTemplateRequestToJson(this);
}

// Webhook model classes
@JsonSerializable(fieldRename: FieldRename.snake)
class Webhook {
  final String id;
  final String teamId;
  final String url;
  final List<String> events;
  final String? secret;
  final bool active;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final User createdBy;
  final int timeCreated;
  final int timeUpdated;

  static User _userFromJson(dynamic json) => User.fromJson(json as Map<String, dynamic>);
  static Map<String, dynamic> _userToJson(User user) => user.toJson();

  Webhook({
    required this.id,
    required this.teamId,
    required this.url,
    required this.events,
    this.secret,
    required this.active,
    required this.createdBy,
    required this.timeCreated,
    required this.timeUpdated,
  });

  factory Webhook.fromJson(Map<String, dynamic> json) =>
      _$WebhookFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class WebhookResponse {
  final Webhook webhook;

  WebhookResponse({required this.webhook});

  factory WebhookResponse.fromJson(Map<String, dynamic> json) =>
      _$WebhookResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateWebhookRequest {
  final String url;
  final List<String> events;
  final String? secret;

  CreateWebhookRequest({
    required this.url,
    required this.events,
    this.secret,
  });

  factory CreateWebhookRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWebhookRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateWebhookRequestToJson(this);
}

// Enhanced Card models with relationships
@JsonSerializable(fieldRename: FieldRename.snake)
class CardRelationship {
  final String cardId;
  final String title;
  final String? boardId;
  final String? boardTitle;
  final String? listId;
  final String? listTitle;
  final String? listColor;
  final String status;
  final bool? archived;

  CardRelationship({
    required this.cardId,
    required this.title,
    this.boardId,
    this.boardTitle,
    this.listId,
    this.listTitle,
    this.listColor,
    required this.status,
    this.archived,
  });

  factory CardRelationship.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    return CardRelationship(
      cardId: strConverter.fromJson(json['card_id']) ?? '',
      title: strConverter.fromJson(json['title']) ?? '',
      boardId: strConverter.fromJson(json['board_id']),
      boardTitle: strConverter.fromJson(json['board_title']),
      listId: strConverter.fromJson(json['list_id']),
      listTitle: strConverter.fromJson(json['list_title']),
      listColor: strConverter.fromJson(json['list_color']),
      status: strConverter.fromJson(json['status']) ?? '',
      archived: json['archived'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => _$CardRelationshipToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ChecklistItem {
  final String id;
  final String title;
  final String? content;
  final String checklistId;
  final String userId;
  final bool checked;
  final int timeCreated;
  final int timeUpdated;

  ChecklistItem({
    required this.id,
    required this.title,
    this.content,
    required this.checklistId,
    required this.userId,
    required this.checked,
    required this.timeCreated,
    required this.timeUpdated,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final intConverter = const SafeIntConverter();
    return ChecklistItem(
      id: strConverter.fromJson(json['id']) ?? '',
      title: strConverter.fromJson(json['title']) ?? '',
      content: strConverter.fromJson(json['content']),
      checklistId: strConverter.fromJson(json['checklist_id']) ?? '',
      userId: strConverter.fromJson(json['user_id']) ?? '',
      checked: json['checked'] as bool? ?? false,
      timeCreated: intConverter.fromJson(json['time_created']) ?? 0,
      timeUpdated: intConverter.fromJson(json['time_updated']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$ChecklistItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Checklist {
  final String id;
  final String title;
  final String? content;
  final String cardId;
  final String userId;
  final List<ChecklistItem> items;
  final int timeCreated;
  final int timeUpdated;

  Checklist({
    required this.id,
    required this.title,
    this.content,
    required this.cardId,
    required this.userId,
    required this.items,
    required this.timeCreated,
    required this.timeUpdated,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final intConverter = const SafeIntConverter();
    return Checklist(
      id: strConverter.fromJson(json['id']) ?? '',
      title: strConverter.fromJson(json['title']) ?? '',
      content: strConverter.fromJson(json['content']),
      cardId: strConverter.fromJson(json['card_id']) ?? '',
      userId: strConverter.fromJson(json['user_id']) ?? '',
      items: (json['items'] as List?)
          ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      timeCreated: intConverter.fromJson(json['time_created']) ?? 0,
      timeUpdated: intConverter.fromJson(json['time_updated']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$ChecklistToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CardMember {
  final String userId;
  final String? assignedDate;
  final String role; // 'admin', 'member', 'viewer'

  CardMember({
    required this.userId,
    this.assignedDate,
    required this.role,
  });

  factory CardMember.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    return CardMember(
      userId: strConverter.fromJson(json['user_id']) ?? '',
      assignedDate: strConverter.fromJson(json['assigned_date']),
      role: strConverter.fromJson(json['role']) ?? 'member',
    );
  }

  Map<String, dynamic> toJson() => _$CardMemberToJson(this);
}

// Real-time event models
@JsonSerializable(fieldRename: FieldRename.snake)
class RealtimeEvent {
  final String type;
  final String teamId;
  final String? userId;
  final Map<String, dynamic> data;
  final int timestamp;

  RealtimeEvent({
    required this.type,
    required this.teamId,
    this.userId,
    required this.data,
    required this.timestamp,
  });

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) =>
      _$RealtimeEventFromJson(json);

  Map<String, dynamic> toJson() => _$RealtimeEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserPresence {
  final String userId;
  final String? cardId;
  final String? boardId;
  final String status; // 'online', 'away', 'offline'
  final int lastSeen;

  UserPresence({
    required this.userId,
    this.cardId,
    this.boardId,
    required this.status,
    required this.lastSeen,
  });

  factory UserPresence.fromJson(Map<String, dynamic> json) =>
      _$UserPresenceFromJson(json);

  Map<String, dynamic> toJson() => _$UserPresenceToJson(this);
}

// Search models
// Search models
@JsonSerializable(fieldRename: FieldRename.snake)
class SearchResult extends Equatable {
  final String id;
  final String type; // 'card', 'board', 'note', 'list'
  final String title;
  final String? content;
  final String? teamId;
  final String? projectId;
  final String? boardId;
  final String? listId;
  final String? assignedTo;
  final List<String>? tags;
  final String? status;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime? createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;
  final double? relevanceScore;
  final Map<String, dynamic>? metadata;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.content,
    this.teamId,
    this.projectId,
    this.boardId,
    this.listId,
    this.assignedTo,
    this.tags,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.relevanceScore,
    this.metadata,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final timeConverter = const TimestampConverter();
    final strListConverter = const SafeStringListConverter();

    return SearchResult(
      id: strConverter.fromJson(json['id']) ?? '',
      type: strConverter.fromJson(json['type']) ?? '',
      title: strConverter.fromJson(json['title']) ?? '',
      content: strConverter.fromJson(json['content']),
      teamId: strConverter.fromJson(json['team_id']),
      projectId: strConverter.fromJson(json['project_id']),
      boardId: strConverter.fromJson(json['board_id']),
      listId: strConverter.fromJson(json['list_id']),
      assignedTo: strConverter.fromJson(json['assigned_to']),
      tags: strListConverter.fromJson(json['tags']),
      status: strConverter.fromJson(json['status']),
      createdAt: timeConverter.fromJson(json['time_created']),
      updatedAt: timeConverter.fromJson(json['time_updated']),
      relevanceScore: (json['relevance_score'] as num?)?.toDouble(),
      metadata: (json['metadata'] is Map) ? Map<String, dynamic>.from(json['metadata'] as Map) : null,
    );
  }

  Map<String, dynamic> toJson() => _$SearchResultToJson(this);

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    content,
    teamId,
    projectId,
    boardId,
    listId,
    assignedTo,
    tags,
    status,
    createdAt,
    updatedAt,
    relevanceScore,
    metadata,
  ];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SearchResponse extends Equatable {
  final List<SearchResult> results;
  final int totalCount;
  final int? currentPage;
  final int? totalPages;
  final String? query;
  final Map<String, dynamic>? filters;
  final int searchTime;

  const SearchResponse({
    required this.results,
    required this.totalCount,
    this.currentPage,
    this.totalPages,
    this.query,
    this.filters,
    required this.searchTime,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final List<SearchResult> allResults = [];

    // Helper to add items with specific type
    void addItems(String key, String type) {
      if (json[key] is List) {
        try {
          allResults.addAll((json[key] as List).map((e) {
            if (e is! Map) return null;
            final map = Map<String, dynamic>.from(e as Map);
            // In case the item doesn't have a type, inject it
            if (!map.containsKey('type')) {
              map['type'] = type;
            }
            return SearchResult.fromJson(map);
          }).whereType<SearchResult>());
        } catch (e) {
          // Ignore parsing errors for individual lists
        }
      }
    }

    addItems('cards', 'card');
    addItems('boards', 'board');
    addItems('projects', 'project');
    addItems('notes', 'note');
    addItems('epics', 'epic');
    addItems('pages', 'page');

    // Also include 'results' if present (backward compatibility)
    if (json['results'] is List) {
      allResults.addAll((json['results'] as List)
          .where((e) => e is Map)
          .map((e) => SearchResult.fromJson(e as Map<String, dynamic>)));
    }

    return SearchResponse(
      results: allResults,
      totalCount: const SafeIntConverter().fromJson(json['count'] ?? json['total_count']) ?? 0,
      currentPage: const SafeIntConverter().fromJson(json['current_page']),
      totalPages: const SafeIntConverter().fromJson(json['total_pages']),
      query: json['query'] as String?,
      filters: json['filters'] as Map<String, dynamic>?,
      searchTime: const SafeIntConverter().fromJson(json['search_time']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);

  @override
  List<Object?> get props => [
    results,
    totalCount,
    currentPage,
    totalPages,
    query,
    filters,
    searchTime,
  ];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SearchSuggestion extends Equatable {
  final String text;
  final String type;
  final int frequency;
  final Map<String, dynamic>? metadata;

  SearchSuggestion({
    required this.text,
    required this.type,
    required this.frequency,
    this.metadata,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$SearchSuggestionToJson(this);

  @override
  List<Object?> get props => [text, type, frequency, metadata];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SearchSuggestionsResponse extends Equatable {
  final List<SearchSuggestion> suggestions;
  final String query;

  const SearchSuggestionsResponse({
    required this.suggestions,
    required this.query,
  });

  factory SearchSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionsResponse(
      suggestions: (json['suggestions'] as List?)
          ?.map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      query: json['query'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$SearchSuggestionsResponseToJson(this);

  @override
  List<Object> get props => [suggestions, query];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SavedSearch extends Equatable {
  final String id;
  final String name;
  final String query;
  final Map<String, dynamic>? filters;
  final String userId;
  final DateTime createdAt;
  final DateTime? lastUsed;

  SavedSearch({
    required this.id,
    required this.name,
    required this.query,
    this.filters,
    required this.userId,
    required this.createdAt,
    this.lastUsed,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) =>
      _$SavedSearchFromJson(json);

  Map<String, dynamic> toJson() => _$SavedSearchToJson(this);

  @override
  List<Object?> get props => [id, name, query, filters, userId, createdAt, lastUsed];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SaveSearchRequest extends Equatable {
  final String name;
  final String query;
  final Map<String, dynamic>? filters;

  const SaveSearchRequest({
    required this.name,
    required this.query,
    this.filters,
  });

  factory SaveSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveSearchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveSearchRequestToJson(this);

  @override
  List<Object?> get props => [name, query, filters];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SavedSearchResponse extends Equatable {
  final SavedSearch savedSearch;

  const SavedSearchResponse({required this.savedSearch});

  factory SavedSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SavedSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SavedSearchResponseToJson(this);

  @override
  List<Object> get props => [savedSearch];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SavedSearchesResponse extends Equatable {
  final List<SavedSearch> savedSearches;

  const SavedSearchesResponse({required this.savedSearches});

  factory SavedSearchesResponse.fromJson(Map<String, dynamic> json) {
    return SavedSearchesResponse(
      savedSearches: (json['saved_searches'] as List?)
          ?.map((e) => SavedSearch.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => _$SavedSearchesResponseToJson(this);

  @override
  List<Object> get props => [savedSearches];
}


// Card relationship models
@JsonSerializable(fieldRename: FieldRename.snake)
class AddChildCardRequest extends Equatable {
  final String childCardId;

  const AddChildCardRequest({required this.childCardId});

  factory AddChildCardRequest.fromJson(Map<String, dynamic> json) => _$AddChildCardRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddChildCardRequestToJson(this);

  @override
  List<Object?> get props => [childCardId];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AddLinkedCardRequest extends Equatable {
  final String linkedCardId;

  const AddLinkedCardRequest({required this.linkedCardId});

  factory AddLinkedCardRequest.fromJson(Map<String, dynamic> json) => _$AddLinkedCardRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddLinkedCardRequestToJson(this);

  @override
  List<Object?> get props => [linkedCardId];
}

// Checklist models
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateChecklistItemRequest extends Equatable {
  final String text;
  final int? position;

  const CreateChecklistItemRequest({
    required this.text,
    this.position,
  });

  factory CreateChecklistItemRequest.fromJson(Map<String, dynamic> json) => _$CreateChecklistItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChecklistItemRequestToJson(this);

  @override
  List<Object?> get props => [text, position];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateChecklistItemRequest extends Equatable {
  final String? text;
  final bool? isCompleted;
  final int? position;

  const UpdateChecklistItemRequest({
    this.text,
    this.isCompleted,
    this.position,
  });

  factory UpdateChecklistItemRequest.fromJson(Map<String, dynamic> json) => _$UpdateChecklistItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateChecklistItemRequestToJson(this);

  @override
  List<Object?> get props => [text, isCompleted, position];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CardResponse extends Equatable {
  final Card card;

  const CardResponse({required this.card});

  factory CardResponse.fromJson(Map<String, dynamic> json) => _$CardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CardResponseToJson(this);

  @override
  List<Object> get props => [card];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CommentsResponse extends Equatable {
  final List<Comment> comments;

  const CommentsResponse({required this.comments});

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    return CommentsResponse(
      comments: (json['comments'] as List?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  Map<String, dynamic> toJson() => _$CommentsResponseToJson(this);

  @override
  List<Object?> get props => [comments];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CommentResponse extends Equatable {
  final Comment comment;

  const CommentResponse({required this.comment});

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    // Some endpoints return the comment wrapped in {"comment": {...}}
    // Reply endpoints return {"child_comment": {...}}
    // others might return it directly.
    if (json.containsKey('comment') && json['comment'] is Map) {
      return CommentResponse(
        comment: Comment.fromJson(json['comment'] as Map<String, dynamic>),
      );
    }
    if (json.containsKey('child_comment') && json['child_comment'] is Map) {
      return CommentResponse(
        comment: Comment.fromJson(json['child_comment'] as Map<String, dynamic>),
      );
    }
    // Fallback: treat the entire body as the comment if it looks like one
    return CommentResponse(comment: Comment.fromJson(json));
  }
  Map<String, dynamic> toJson() => _$CommentResponseToJson(this);

  @override
  List<Object?> get props => [comment];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AttachmentsResponse extends Equatable {
  final List<Attachment> attachments;

  const AttachmentsResponse({required this.attachments});

  factory AttachmentsResponse.fromJson(Map<String, dynamic> json) {
    return AttachmentsResponse(
      attachments: (json['attachments'] as List?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  Map<String, dynamic> toJson() => _$AttachmentsResponseToJson(this);

  @override
  List<Object?> get props => [attachments];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AttachmentResponse extends Equatable {
  final Attachment attachment;

  const AttachmentResponse({required this.attachment});

  factory AttachmentResponse.fromJson(Map<String, dynamic> json) => _$AttachmentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentResponseToJson(this);

  @override
  List<Object?> get props => [attachment];
}



@JsonSerializable(fieldRename: FieldRename.snake)
class ChecklistItemResponse extends Equatable {
  final ChecklistItem checklistItem;

  const ChecklistItemResponse({required this.checklistItem});

  factory ChecklistItemResponse.fromJson(Map<String, dynamic> json) => _$ChecklistItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChecklistItemResponseToJson(this);

  @override
  List<Object?> get props => [checklistItem];
}
// View Preview models for filtering cards
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ViewPreviewRequest extends Equatable {
  final String type;
  final ViewCardFilters? cardFilters;
  final Map<String, dynamic>? boardFilters;
  final Map<String, dynamic>? pageFilters;

  const ViewPreviewRequest({
    required this.type,
    this.cardFilters,
    this.boardFilters,
    this.pageFilters,
  });

  factory ViewPreviewRequest.fromJson(Map<String, dynamic> json) =>
      _$ViewPreviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ViewPreviewRequestToJson(this);
  
  @override
  List<Object?> get props => [type, cardFilters, boardFilters, pageFilters];
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ViewCardFilters extends Equatable {
  final ViewIncludeFilters? include;
  final bool? hasStatus;
  final bool? archived; // support archived=false

  const ViewCardFilters({
    this.include,
    this.hasStatus,
    this.archived,
  });

  factory ViewCardFilters.fromJson(Map<String, dynamic> json) =>
      _$ViewCardFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$ViewCardFiltersToJson(this);

    @override
  List<Object?> get props => [include, hasStatus, archived];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ViewIncludeFilters extends Equatable {
  final List<String>? members;

  const ViewIncludeFilters({this.members});

  factory ViewIncludeFilters.fromJson(Map<String, dynamic> json) =>
      _$ViewIncludeFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$ViewIncludeFiltersToJson(this);

    @override
  List<Object?> get props => [members];
}