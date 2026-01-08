// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpapers_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wallpapersRepository)
final wallpapersRepositoryProvider = WallpapersRepositoryProvider._();

final class WallpapersRepositoryProvider
    extends
        $FunctionalProvider<
          WallpapersRepository,
          WallpapersRepository,
          WallpapersRepository
        >
    with $Provider<WallpapersRepository> {
  WallpapersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wallpapersRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wallpapersRepositoryHash();

  @$internal
  @override
  $ProviderElement<WallpapersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WallpapersRepository create(Ref ref) {
    return wallpapersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WallpapersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WallpapersRepository>(value),
    );
  }
}

String _$wallpapersRepositoryHash() =>
    r'ff5eba3984a218286cec428d62d47e132f168812';

@ProviderFor(wallpapersStream)
final wallpapersStreamProvider = WallpapersStreamProvider._();

final class WallpapersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WallpaperModel>>,
          List<WallpaperModel>,
          Stream<List<WallpaperModel>>
        >
    with
        $FutureModifier<List<WallpaperModel>>,
        $StreamProvider<List<WallpaperModel>> {
  WallpapersStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wallpapersStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wallpapersStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<WallpaperModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WallpaperModel>> create(Ref ref) {
    return wallpapersStream(ref);
  }
}

String _$wallpapersStreamHash() => r'1a98482eea6a39371ca2fd0d1b60e7aa5b74acbf';
