/// Configuration for API endpoints, keys, AdMob IDs, and IAP
class Config {
  /// Base URL of your orchestrator API
  static const String baseUrl = 'http://localhost:5000';

  /// AdMob App IDs
  static const String androidAdmobAppId = '<YOUR_ANDROID_ADMOB_APP_ID>';
  static const String iosAdmobAppId = '<YOUR_IOS_ADMOB_APP_ID>';

  /// Ad Unit IDs
  static const String bannerAdUnitId = '<YOUR_BANNER_AD_UNIT_ID>';
  static const String interstitialAdUnitId = '<YOUR_INTERSTITIAL_AD_UNIT_ID>';

  /// IAP product ID for removing ads
  static const String removeAdsProductId = 'remove_ads';
}
