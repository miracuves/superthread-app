// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'imageUrl': instance.imageUrl,
    };

NotificationPreferences _$NotificationPreferencesFromJson(
        Map<String, dynamic> json) =>
    NotificationPreferences(
      enabled: json['enabled'] as bool? ?? true,
      cardNotifications: json['cardNotifications'] as bool? ?? true,
      noteNotifications: json['noteNotifications'] as bool? ?? true,
      projectNotifications: json['projectNotifications'] as bool? ?? true,
      commentNotifications: json['commentNotifications'] as bool? ?? true,
      assignmentNotifications: json['assignmentNotifications'] as bool? ?? true,
      deadlineNotifications: json['deadlineNotifications'] as bool? ?? true,
      pollingInterval: (json['pollingInterval'] as num?)?.toInt() ?? 5,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      quietHours: (json['quietHours'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['22', '23', '0', '1', '2', '3', '4', '5', '6'],
    );

Map<String, dynamic> _$NotificationPreferencesToJson(
        NotificationPreferences instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'cardNotifications': instance.cardNotifications,
      'noteNotifications': instance.noteNotifications,
      'projectNotifications': instance.projectNotifications,
      'commentNotifications': instance.commentNotifications,
      'assignmentNotifications': instance.assignmentNotifications,
      'deadlineNotifications': instance.deadlineNotifications,
      'pollingInterval': instance.pollingInterval,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'quietHours': instance.quietHours,
    };

UpdateCheckResult _$UpdateCheckResultFromJson(Map<String, dynamic> json) =>
    UpdateCheckResult(
      hasNewCards: json['hasNewCards'] as bool? ?? false,
      hasNewNotes: json['hasNewNotes'] as bool? ?? false,
      hasNewComments: json['hasNewComments'] as bool? ?? false,
      hasNewAssignments: json['hasNewAssignments'] as bool? ?? false,
      newCardsCount: (json['newCardsCount'] as num?)?.toInt() ?? 0,
      newNotesCount: (json['newNotesCount'] as num?)?.toInt() ?? 0,
      newCommentsCount: (json['newCommentsCount'] as num?)?.toInt() ?? 0,
      newAssignmentsCount: (json['newAssignmentsCount'] as num?)?.toInt() ?? 0,
      lastChecked: DateTime.parse(json['lastChecked'] as String),
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UpdateCheckResultToJson(UpdateCheckResult instance) =>
    <String, dynamic>{
      'hasNewCards': instance.hasNewCards,
      'hasNewNotes': instance.hasNewNotes,
      'hasNewComments': instance.hasNewComments,
      'hasNewAssignments': instance.hasNewAssignments,
      'newCardsCount': instance.newCardsCount,
      'newNotesCount': instance.newNotesCount,
      'newCommentsCount': instance.newCommentsCount,
      'newAssignmentsCount': instance.newAssignmentsCount,
      'lastChecked': instance.lastChecked.toIso8601String(),
      'notifications': instance.notifications,
    };
