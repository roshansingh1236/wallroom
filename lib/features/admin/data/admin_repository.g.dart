// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminRepository)
final adminRepositoryProvider = AdminRepositoryProvider._();

final class AdminRepositoryProvider
    extends
        $FunctionalProvider<AdminRepository, AdminRepository, AdminRepository>
    with $Provider<AdminRepository> {
  AdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminRepository create(Ref ref) {
    return adminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRepository>(value),
    );
  }
}

String _$adminRepositoryHash() => r'7e609444f4edb1412cd53f642b5ca2a67bf0bbf4';

@ProviderFor(pendingWallpapers)
final pendingWallpapersProvider = PendingWallpapersProvider._();

final class PendingWallpapersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WallpaperModel>>,
          List<WallpaperModel>,
          Stream<List<WallpaperModel>>
        >
    with
        $FutureModifier<List<WallpaperModel>>,
        $StreamProvider<List<WallpaperModel>> {
  PendingWallpapersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingWallpapersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingWallpapersHash();

  @$internal
  @override
  $StreamProviderElement<List<WallpaperModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WallpaperModel>> create(Ref ref) {
    return pendingWallpapers(ref);
  }
}

String _$pendingWallpapersHash() => r'40595b29476b9f9f49855abe20c3d8d29d87501b';

@ProviderFor(isAdminUser)
final isAdminUserProvider = IsAdminUserProvider._();

final class IsAdminUserProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsAdminUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAdminUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAdminUserHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isAdminUser(ref);
  }
}

String _$isAdminUserHash() => r'5c2eb1c8a59936ab204667b92b69b3b38e3d9bd5';
