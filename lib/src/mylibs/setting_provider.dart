////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider extends ChangeNotifier {

  bool _enableDarkTheme = false;
  bool _defaultShiftView = false;

  bool get enableDarkTheme => _enableDarkTheme;
  bool get defaultShiftView => _defaultShiftView;

  set enableDarkTheme(bool result){
    _enableDarkTheme = result;
    notifyListeners();
  }

  set defaultShiftView(bool result){
    _defaultShiftView = result;
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
