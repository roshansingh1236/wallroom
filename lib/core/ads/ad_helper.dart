import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'ad_helper.g.dart';

class AdHelper {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  // Test ID
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (!_isAdLoaded || _rewardedAd == null) {
      debugPrint('Warning: Ad not loaded yet. Attempting to load now.');
      loadRewardedAd();
      // In prod, you might want to wait or fail. For now, let's fail gracefully or skip (if verified by server, skipping is bad).
      // If we MUST show ad, return false.
      // But for UX, maybe we just proceed if ad fails (revenue loss vs user retention).
      // Strict rule from user: "Every AI generation *must show a rewarded ad*"
      return false; 
    }

    bool userEarnedReward = false;
    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        userEarnedReward = true;
      },
    );

    // Dispose and reload
    _rewardedAd = null;
    _isAdLoaded = false;
    loadRewardedAd();

    return userEarnedReward;
  }
}

@riverpod
AdHelper adHelper(Ref ref) {
  final helper = AdHelper();
  helper.loadRewardedAd(); // Preload
  return helper;
}
