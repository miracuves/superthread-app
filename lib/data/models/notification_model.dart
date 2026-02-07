import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

@JsonSerializable()
class NotificationPreferences {
  final bool enabled;
  final bool cardNotifications;
  final bool noteNotifications;
  final bool projectNotifications;
  final bool commentNotifications;
  final bool assignmentNotifications;
  final bool deadlineNotifications;
  final int pollingInterval; // in minutes
  final bool soundEnabled;
  final bool vibrationEnabled;
  final List<String> quietHours; // List of hours when notifications are muted

  const NotificationPreferences({
    this.enabled = true,
    this.cardNotifications = true,
    this.noteNotifications = true,
    this.projectNotifications = true,
    this.commentNotifications = true,
    this.assignmentNotifications = true,
    this.deadlineNotifications = true,
    this.pollingInterval = 5,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHours = const ['22', '23', '0', '1', '2', '3', '4', '5', '6'], // 10 PM to 6 AM
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);

  NotificationPreferences copyWith({
    bool? enabled,
    bool? cardNotifications,
    bool? noteNotifications,
    bool? projectNotifications,
    bool? commentNotifications,
    bool? assignmentNotifications,
    bool? deadlineNotifications,
    int? pollingInterval,
    bool? soundEnabled,
    bool? vibrationEnabled,
    List<String>? quietHours,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      cardNotifications: cardNotifications ?? this.cardNotifications,
      noteNotifications: noteNotifications ?? this.noteNotifications,
      projectNotifications: projectNotifications ?? this.projectNotifications,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      assignmentNotifications: assignmentNotifications ?? this.assignmentNotifications,
      deadlineNotifications: deadlineNotifications ?? this.deadlineNotifications,
      pollingInterval: pollingInterval ?? this.pollingInterval,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHours: quietHours ?? this.quietHours,
    );
  }
}

@JsonSerializable()
class UpdateCheckResult {
  final bool hasNewCards;
  final bool hasNewNotes;
  final bool hasNewComments;
  final bool hasNewAssignments;
  final int newCardsCount;
  final int newNotesCount;
  final int newCommentsCount;
  final int newAssignmentsCount;
  final DateTime lastChecked;
  final List<NotificationItem> notifications;

  const UpdateCheckResult({
    this.hasNewCards = false,
    this.hasNewNotes = false,
    this.hasNewComments = false,
    this.hasNewAssignments = false,
    this.newCardsCount = 0,
    this.newNotesCount = 0,
    this.newCommentsCount = 0,
    this.newAssignmentsCount = 0,
    required this.lastChecked,
    this.notifications = const [],
  });

  factory UpdateCheckResult.fromJson(Map<String, dynamic> json) =>
      _$UpdateCheckResultFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCheckResultToJson(this);

  bool get hasAnyNewItems =>
      hasNewCards || hasNewNotes || hasNewComments || hasNewAssignments;

  int get totalNewItems =>
      newCardsCount + newNotesCount + newCommentsCount + newAssignmentsCount;
}

enum NotificationType {
  card,
  note,
  project,
  comment,
  assignment,
  deadline,
  system,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}