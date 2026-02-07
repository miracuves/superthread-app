// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Card _$CardFromJson(Map<String, dynamic> json) => Card(
      id: json['id'] as String,
      title: json['title'] as String,
      description: const SafeStringConverter().fromJson(json['description']),
      boardId: json['board_id'] as String,
      boardTitle: const SafeStringConverter().fromJson(json['board_title']),
      listId: const SafeStringConverter().fromJson(json['list_id']),
      listTitle: const SafeStringConverter().fromJson(json['list_title']),
      listColor: const SafeStringConverter().fromJson(json['list_color']),
      teamId: const SafeStringConverter().fromJson(json['team_id']),
      projectId: const SafeStringConverter().fromJson(json['project_id']),
      userId: const SafeStringConverter().fromJson(json['user_id']),
      assignedTo: const SafeStringConverter().fromJson(json['assigned_to']),
      assignedToName:
          const SafeStringConverter().fromJson(json['assigned_to_name']),
      tags: const SafeStringListConverter().fromJson(json['tags']),
      status: const SafeStringConverter().fromJson(json['status']),
      position: const SafeIntConverter().fromJson(json['position']),
      coverImageUrl:
          const SafeStringConverter().fromJson(json['cover_image_url']),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      childCardIds:
          const SafeStringListConverter().fromJson(json['child_card_order']),
      linkedCardIds:
          const SafeStringListConverter().fromJson(json['linked_card_order']),
      parentCardId:
          const SafeStringConverter().fromJson(json['parent_card_id']),
      checklistItems: (json['checklist_items'] as List<dynamic>?)
          ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalComments: const SafeIntConverter().fromJson(json['total_comments']),
      dueDate: const TimestampConverter().fromJson(json['due_date']),
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CardToJson(Card instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'title': instance.title,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'description', const SafeStringConverter().toJson(instance.description));
  val['board_id'] = instance.boardId;
  writeNotNull(
      'board_title', const SafeStringConverter().toJson(instance.boardTitle));
  writeNotNull('list_id', const SafeStringConverter().toJson(instance.listId));
  writeNotNull(
      'list_title', const SafeStringConverter().toJson(instance.listTitle));
  writeNotNull(
      'list_color', const SafeStringConverter().toJson(instance.listColor));
  writeNotNull('team_id', const SafeStringConverter().toJson(instance.teamId));
  writeNotNull(
      'project_id', const SafeStringConverter().toJson(instance.projectId));
  writeNotNull('user_id', const SafeStringConverter().toJson(instance.userId));
  writeNotNull(
      'assigned_to', const SafeStringConverter().toJson(instance.assignedTo));
  writeNotNull('assigned_to_name',
      const SafeStringConverter().toJson(instance.assignedToName));
  writeNotNull('tags', const SafeStringListConverter().toJson(instance.tags));
  writeNotNull('status', const SafeStringConverter().toJson(instance.status));
  writeNotNull('position', const SafeIntConverter().toJson(instance.position));
  writeNotNull('cover_image_url',
      const SafeStringConverter().toJson(instance.coverImageUrl));
  writeNotNull('comments', instance.comments?.map((e) => e.toJson()).toList());
  writeNotNull(
      'attachments', instance.attachments?.map((e) => e.toJson()).toList());
  writeNotNull('child_card_order',
      const SafeStringListConverter().toJson(instance.childCardIds));
  writeNotNull('linked_card_order',
      const SafeStringListConverter().toJson(instance.linkedCardIds));
  writeNotNull('parent_card_id',
      const SafeStringConverter().toJson(instance.parentCardId));
  writeNotNull('checklist_items',
      instance.checklistItems?.map((e) => e.toJson()).toList());
  writeNotNull('total_comments',
      const SafeIntConverter().toJson(instance.totalComments));
  writeNotNull('due_date', const TimestampConverter().toJson(instance.dueDate));
  val['is_archived'] = instance.isArchived;
  val['time_created'] = instance.createdAt.toIso8601String();
  writeNotNull(
      'time_updated', const TimestampConverter().toJson(instance.updatedAt));
  writeNotNull('metadata', instance.metadata);
  return val;
}

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      content: json['content'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatar: const SafeStringConverter().fromJson(json['author_avatar']),
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      parentCommentId:
          const SafeStringConverter().fromJson(json['parent_comment_id']),
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      likeCount: (json['like_count'] as num?)?.toInt(),
      likedByMe: json['liked_by_me'] as bool?,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'card_id': instance.cardId,
    'content': instance.content,
    'author_id': instance.authorId,
    'author_name': instance.authorName,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('author_avatar',
      const SafeStringConverter().toJson(instance.authorAvatar));
  val['time_created'] = instance.createdAt.toIso8601String();
  writeNotNull(
      'time_updated', const TimestampConverter().toJson(instance.updatedAt));
  writeNotNull('parent_comment_id',
      const SafeStringConverter().toJson(instance.parentCommentId));
  writeNotNull('replies', instance.replies?.map((e) => e.toJson()).toList());
  writeNotNull('reactions', instance.reactions);
  writeNotNull('like_count', instance.likeCount);
  writeNotNull('liked_by_me', instance.likedByMe);
  return val;
}

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      mimeType: const SafeStringConverter().fromJson(json['mime_type']),
      fileSize: const SafeIntConverter().fromJson(json['file_size']),
      createdAt: DateTime.parse(json['time_created'] as String),
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'card_id': instance.cardId,
    'file_name': instance.fileName,
    'file_url': instance.fileUrl,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'mime_type', const SafeStringConverter().toJson(instance.mimeType));
  writeNotNull('file_size', const SafeIntConverter().toJson(instance.fileSize));
  val['time_created'] = instance.createdAt.toIso8601String();
  return val;
}

ChecklistItem _$ChecklistItemFromJson(Map<String, dynamic> json) =>
    ChecklistItem(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      text: json['text'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      position: const SafeIntConverter().fromJson(json['position']),
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
    );

Map<String, dynamic> _$ChecklistItemToJson(ChecklistItem instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'card_id': instance.cardId,
    'text': instance.text,
    'is_completed': instance.isCompleted,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('position', const SafeIntConverter().toJson(instance.position));
  val['time_created'] = instance.createdAt.toIso8601String();
  writeNotNull(
      'time_updated', const TimestampConverter().toJson(instance.updatedAt));
  return val;
}
