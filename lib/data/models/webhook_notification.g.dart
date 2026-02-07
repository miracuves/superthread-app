// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebhookNotification _$WebhookNotificationFromJson(Map<String, dynamic> json) =>
    WebhookNotification(
      url: json['url'] as String?,
      eventType: json['event_type'] as String?,
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$WebhookNotificationToJson(
        WebhookNotification instance) =>
    <String, dynamic>{
      'url': instance.url,
      'event_type': instance.eventType,
      'is_active': instance.isActive,
    };
