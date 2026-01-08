// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WallpaperModel _$WallpaperModelFromJson(Map<String, dynamic> json) =>
    _WallpaperModel(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      prompt: json['prompt'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      downloads: (json['downloads'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      aspectRatio: json['aspectRatio'] as String? ?? '9:16',
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$WallpaperModelToJson(_WallpaperModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'prompt': instance.prompt,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'downloads': instance.downloads,
      'likes': instance.likes,
      'aspectRatio': instance.aspectRatio,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
