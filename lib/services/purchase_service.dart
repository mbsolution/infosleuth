import 'package:flutter/material.dart';

/// Stubbed Purchase service – no in_app_purchase dependency.
class PurchaseService with ChangeNotifier {
  bool adsRemoved = false;

  /// Immediately “buy” remove-ads (no real purchase)
  void buyRemoveAds() {
    adsRemoved = true;
    notifyListeners();
  }
}
