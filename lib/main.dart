import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart'; // Ensure this file exists via flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // If firebase_options.dart is missing, run `flutterfire configure`
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization failed (Check firebase_options.dart): $e");
  }

  // Initialize App Check
  try {
    await FirebaseAppCheck.instance.activate(
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. AndroidProvider.debug
      // 2. AndroidProvider.playIntegrity
      // 3. AndroidProvider.playIntegrity (legacy)
      androidProvider: kReleaseMode
          ? AndroidProvider.playIntegrity
          : AndroidProvider.debug,
      // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. AppleProvider.appAttest
      // 2. AppleProvider.deviceCheck
      // 3. AppleProvider.debug
      appleProvider: kReleaseMode
          ? AppleProvider.deviceCheck
          : AppleProvider.debug,
    );
  } catch (e) {
    print("Firebase App Check initialization failed: $e");
  }

  // Initialize AdMob
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ["2E0082FCB8F24C42915854384B2E1856"]),
  );
  MobileAds.instance.initialize();

  runApp(const ProviderScope(child: WallroomApp()));
}

class WallroomApp extends ConsumerWidget {
  const WallroomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'AI Wallpapers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
