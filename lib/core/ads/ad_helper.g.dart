// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_helper.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adHelper)
final adHelperProvider = AdHelperProvider._();

final class AdHelperProvider
    extends $FunctionalProvider<AdHelper, AdHelper, AdHelper>
    with $Provider<AdHelper> {
  AdHelperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adHelperProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adHelperHash();

  @$internal
  @override
  $ProviderElement<AdHelper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdHelper create(Ref ref) {
    return adHelper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdHelper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdHelper>(value),
    );
  }
}

String _$adHelperHash() => r'881c581b160937b6b33dda508d96d215a75f374e';
