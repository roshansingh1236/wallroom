import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallpapers/data/wallpaper_model.dart';
import '../../auth/data/auth_repository.dart';

part 'admin_repository.g.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository(this._firestore);

  // Fetch wallpapers waiting for moderation
  Stream<List<WallpaperModel>> getPendingWallpapers() {
    return _firestore
        .collection('wallpapers')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false) // Oldest first
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => WallpaperModel.fromDocument(doc)).toList());
  }

  Future<void> approveWallpaper(String wallpaperId) async {
    await _firestore.collection('wallpapers').doc(wallpaperId).update({
      'status': 'approved',
    });
  }

  Future<void> rejectWallpaper(String wallpaperId) async {
    await _firestore.collection('wallpapers').doc(wallpaperId).update({
      'status': 'rejected',
    });
  }
}

@riverpod
AdminRepository adminRepository(Ref ref) {
  return AdminRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<WallpaperModel>> pendingWallpapers(Ref ref) {
  return ref.watch(adminRepositoryProvider).getPendingWallpapers();
}

// Simple MVP Gatekeeper: Check if user email is admin
// In prod, use Custom Claims
@riverpod
Future<bool> isAdminUser(Ref ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return false;
  
  // TODO: Add your admin emails here
  const adminEmails = ['admin@wallroom.com', 'roshan@example.com']; 
  return adminEmails.contains(user.email);
}
