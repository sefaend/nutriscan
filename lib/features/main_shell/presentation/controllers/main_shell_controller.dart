import 'package:flutter/material.dart';

import '../../../../core/utils/app_navigator.dart';

/// Alt menünün mantığı: hangi sekme açık, kamera butonuna basınca ne olur.
class MainShellController extends ChangeNotifier {
  static const int homeTab = 0;
  static const int profileTab = 1;

  int currentIndex = homeTab;

  void onTabSelected(int index) {
    if (index == currentIndex) return;
    currentIndex = index;
    notifyListeners();
  }

  void onScanPressed(BuildContext context) {
    AppNavigator.openScanner(context);
  }
}
