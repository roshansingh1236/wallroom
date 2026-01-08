import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'wallpaper_model.freezed.dart';
part 'wallpaper_model.g.dart';

// Helper for Firestore Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
sealed class WallpaperModel with _$WallpaperModel {
  const factory WallpaperModel({
    required String id,
    required String creatorId,
    required String prompt,
    required String imageUrl,
    required String thumbnailUrl,
    @Default(0) int downloads,
    @Default(0) int likes,
    @Default('9:16') String aspectRatio,
    @TimestampConverter() required DateTime createdAt,
  }) = _WallpaperModel;

  factory WallpaperModel.fromJson(Map<String, dynamic> json) => _$WallpaperModelFromJson(json);
  
  // Factory for Firestore
  factory WallpaperModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WallpaperModel.fromJson({...data, 'id': doc.id});
  }
}
