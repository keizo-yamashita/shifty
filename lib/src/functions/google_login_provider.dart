// google_account_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAccountProvider extends ChangeNotifier {
  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;

  Future login() async {
    var googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    _user = user;
    notifyListeners();
  }

  Future silentLogin() async {
    var user = await GoogleSignIn().signInSilently();
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }

  Future logout() async {
    await GoogleSignIn().signOut();
    _user = null;
    notifyListeners();
  }
}
