import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wallpaper_model.dart'; // Ensure correct import

part 'wallpapers_repository.g.dart';

class WallpapersRepository {
  final FirebaseFirestore _firestore;

  WallpapersRepository(this._firestore);

  Stream<List<WallpaperModel>> getWallpapers({int limit = 20}) {
    return _firestore
        .collection('wallpapers')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WallpaperModel.fromDocument(doc))
              .toList(),
        );
  }

  Future<List<WallpaperModel>> getWallpapersPaginated({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('wallpapers')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => WallpaperModel.fromDocument(doc))
        .toList();
  }

  Future<List<DocumentSnapshot>> getWallpapersPaginatedWithDocs({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('wallpapers')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<void> addWallpaper(WallpaperModel wallpaper) async {
    await _firestore
        .collection('wallpapers')
        .doc(wallpaper.id)
        .set(
          {...wallpaper.toJson(), 'createdAt': FieldValue.serverTimestamp()}
            ..remove('id'),
        );
  }

  Future<Map<String, dynamic>?> generateWallpaper({
    required String prompt,
    required String aspectRatio,
    required String style,
  }) async {
    final functions = FirebaseFunctions.instance;
    final result = await functions.httpsCallable('generateWallpaper').call({
      'prompt': prompt,
      'aspectRatio': aspectRatio,
      'style': style,
    });
    // The function saves to Firestore, so the stream will update automatically.
    // result.data contains success/url if needed manually.
    return result.data as Map<String, dynamic>?;
  }

  Future<void> downloadWallpaper({
    required String wallpaperId,
    required String creatorId,
  }) async {
    final functions = FirebaseFunctions.instance;
    await functions.httpsCallable('onDownload').call({
      'wallpaperId': wallpaperId,
      'creatorId': creatorId,
    });
  }
}

@riverpod
WallpapersRepository wallpapersRepository(Ref ref) {
  return WallpapersRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<WallpaperModel>> wallpapersStream(Ref ref) {
  return ref.watch(wallpapersRepositoryProvider).getWallpapers();
}
