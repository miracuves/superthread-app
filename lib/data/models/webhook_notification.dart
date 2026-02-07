import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'webhook_notification.g.dart';
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class WebhookNotification extends Equatable {
  final String? url;
  final String? eventType;
  final bool? isActive;
  const WebhookNotification({this.url, this.eventType, this.isActive});
  factory WebhookNotification.fromJson(Map<String, dynamic> json) => _$WebhookNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$WebhookNotificationToJson(this);
  @override
  List<Object?> get props => [url, eventType, isActive];
}
