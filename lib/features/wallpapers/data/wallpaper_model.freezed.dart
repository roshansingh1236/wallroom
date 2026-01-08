// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallpaper_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WallpaperModel {

 String get id; String get creatorId; String get prompt; String get imageUrl; String get thumbnailUrl; int get downloads; int get likes; String get aspectRatio;@TimestampConverter() DateTime get createdAt;
/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallpaperModelCopyWith<WallpaperModel> get copyWith => _$WallpaperModelCopyWithImpl<WallpaperModel>(this as WallpaperModel, _$identity);

  /// Serializes this WallpaperModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallpaperModel&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.downloads, downloads) || other.downloads == downloads)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,prompt,imageUrl,thumbnailUrl,downloads,likes,aspectRatio,createdAt);

@override
String toString() {
  return 'WallpaperModel(id: $id, creatorId: $creatorId, prompt: $prompt, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, downloads: $downloads, likes: $likes, aspectRatio: $aspectRatio, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WallpaperModelCopyWith<$Res>  {
  factory $WallpaperModelCopyWith(WallpaperModel value, $Res Function(WallpaperModel) _then) = _$WallpaperModelCopyWithImpl;
@useResult
$Res call({
 String id, String creatorId, String prompt, String imageUrl, String thumbnailUrl, int downloads, int likes, String aspectRatio,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$WallpaperModelCopyWithImpl<$Res>
    implements $WallpaperModelCopyWith<$Res> {
  _$WallpaperModelCopyWithImpl(this._self, this._then);

  final WallpaperModel _self;
  final $Res Function(WallpaperModel) _then;

/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? prompt = null,Object? imageUrl = null,Object? thumbnailUrl = null,Object? downloads = null,Object? likes = null,Object? aspectRatio = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,downloads: null == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as int,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WallpaperModel].
extension WallpaperModelPatterns on WallpaperModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WallpaperModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WallpaperModel value)  $default,){
final _that = this;
switch (_that) {
case _WallpaperModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WallpaperModel value)?  $default,){
final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creatorId,  String prompt,  String imageUrl,  String thumbnailUrl,  int downloads,  int likes,  String aspectRatio, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
return $default(_that.id,_that.creatorId,_that.prompt,_that.imageUrl,_that.thumbnailUrl,_that.downloads,_that.likes,_that.aspectRatio,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creatorId,  String prompt,  String imageUrl,  String thumbnailUrl,  int downloads,  int likes,  String aspectRatio, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _WallpaperModel():
return $default(_that.id,_that.creatorId,_that.prompt,_that.imageUrl,_that.thumbnailUrl,_that.downloads,_that.likes,_that.aspectRatio,_that.createdAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creatorId,  String prompt,  String imageUrl,  String thumbnailUrl,  int downloads,  int likes,  String aspectRatio, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
return $default(_that.id,_that.creatorId,_that.prompt,_that.imageUrl,_that.thumbnailUrl,_that.downloads,_that.likes,_that.aspectRatio,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WallpaperModel implements WallpaperModel {
  const _WallpaperModel({required this.id, required this.creatorId, required this.prompt, required this.imageUrl, required this.thumbnailUrl, this.downloads = 0, this.likes = 0, this.aspectRatio = '9:16', @TimestampConverter() required this.createdAt});
  factory _WallpaperModel.fromJson(Map<String, dynamic> json) => _$WallpaperModelFromJson(json);

@override final  String id;
@override final  String creatorId;
@override final  String prompt;
@override final  String imageUrl;
@override final  String thumbnailUrl;
@override@JsonKey() final  int downloads;
@override@JsonKey() final  int likes;
@override@JsonKey() final  String aspectRatio;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WallpaperModelCopyWith<_WallpaperModel> get copyWith => __$WallpaperModelCopyWithImpl<_WallpaperModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WallpaperModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallpaperModel&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.downloads, downloads) || other.downloads == downloads)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,prompt,imageUrl,thumbnailUrl,downloads,likes,aspectRatio,createdAt);

@override
String toString() {
  return 'WallpaperModel(id: $id, creatorId: $creatorId, prompt: $prompt, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, downloads: $downloads, likes: $likes, aspectRatio: $aspectRatio, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WallpaperModelCopyWith<$Res> implements $WallpaperModelCopyWith<$Res> {
  factory _$WallpaperModelCopyWith(_WallpaperModel value, $Res Function(_WallpaperModel) _then) = __$WallpaperModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String creatorId, String prompt, String imageUrl, String thumbnailUrl, int downloads, int likes, String aspectRatio,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$WallpaperModelCopyWithImpl<$Res>
    implements _$WallpaperModelCopyWith<$Res> {
  __$WallpaperModelCopyWithImpl(this._self, this._then);

  final _WallpaperModel _self;
  final $Res Function(_WallpaperModel) _then;

/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? prompt = null,Object? imageUrl = null,Object? thumbnailUrl = null,Object? downloads = null,Object? likes = null,Object? aspectRatio = null,Object? createdAt = null,}) {
  return _then(_WallpaperModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,downloads: null == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as int,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
