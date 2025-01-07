////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider extends ChangeNotifier {
  bool _enableDarkTheme = false;
  bool _defaultShiftView = false;
  bool isEditting = false;
  bool isRotating = false;
  double _screenPaddngTop = 0.0;
  double _screenPaddngBottom = 0.0;
  double _appBarHeight = 0.0;
  double _navigationBarHeight = 0.0;

  bool get enableDarkTheme => _enableDarkTheme;
  bool get defaultShiftView => _defaultShiftView;
  double get screenPaddingTop => _screenPaddngTop;
  double get screenPaddingBottom => _screenPaddngBottom;
  double get appBarHeight => _appBarHeight;
  double get navigationBarHeight => _navigationBarHeight;
  
  set enableDarkTheme(bool result) {
    _enableDarkTheme = result;
    notifyListeners();
  }

  set defaultShiftView(bool result) {
    _defaultShiftView = result;
    notifyListeners();
  }

  set screenPaddingTop(double paddingTop) {
    _screenPaddngTop = paddingTop;
    notifyListeners();
  }

  set screenPaddingBottom(double paddingBottom) {
    _screenPaddngBottom = paddingBottom;
    notifyListeners();
  }

  set appBarHeight(double appBarHeight){
    _appBarHeight = appBarHeight;
    notifyListeners();
  }

  set navigationBarHeight(double navigationBarHeight) {
    _navigationBarHeight = navigationBarHeight;
    notifyListeners();
  }

  Future loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _enableDarkTheme = prefs.getBool('enableDarkTheme') ?? false;
    _defaultShiftView = prefs.getBool('defaultShiftView') ?? false;
    notifyListeners();
  }

  Future storePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enableDarkTheme', _enableDarkTheme);
    prefs.setBool('defaultShiftView', _defaultShiftView);
    notifyListeners();
  }
}
