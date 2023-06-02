// google_account_provider.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAccountProvider extends ChangeNotifier {
  GoogleSignInAccount? _user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  GoogleSignInAccount? get user => _user;

  Future login() async {
    var user = await _googleSignIn.signIn();
    _user = user;
    notifyListeners();
  }

  Future silentLogin() async {
    var user = await _googleSignIn.signInSilently();
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }

  Future logout() async {
    await _googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }
}
