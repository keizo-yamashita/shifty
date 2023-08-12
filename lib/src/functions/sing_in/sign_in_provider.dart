////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInProvider extends ChangeNotifier {

  User? _user;
  User? get user => _user;

  Future<String> login(String  providerName, [String? email, String? password]) async {

    String message = "";

    if(providerName == "google"){
      var googleSignIn = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleSignIn?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken
      );
      var userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      _user = userCredential.user;
    }
    else if(providerName == 'apple'){
      // AuthorizationCredentialAppleIDのインスタンスを取得
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
      // OAthCredentialのインスタンスを作成
      OAuthProvider oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      var userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      _user = userCredential.user;
    }

    else if(providerName == "mail-create"){
      try {
        final User? user = (
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email!, password: password!
        )).user;
        
        if (user != null){
          message = "登録しました。サインインしてください。";
        }
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "ERROR_EMAIL_ALREADY_IN_USE":
          case "account-exists-with-different-credential":
          case "email-already-in-use":
            message = "このメールアドレスはすでに登録されているようです。";
            break;
          case "ERROR_WRONG_PASSWORD":
          case "wrong-password":
            message = "メールアドレスまたはパスワードに誤りがあるようです。";
            break;
          case "ERROR_USER_NOT_FOUND":
          case "user-not-found":
            message = "このメールアドレスは見つかりません。";
            break;
          case "ERROR_USER_DISABLED":
          case "user-disabled":
            message = "このユーザーは見つかりません。";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
          case "operation-not-allowed":
            message = "このアカウントでのログインが多すぎるようです。";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
          case "operation-not-allowed":
            message = "サーバーエラー。しばらくしてからお試しください。";
            break;
          case "ERROR_INVALID_EMAIL":
          case "invalid-email":
            message = "正しいメールアドレスを入力してください。";
            break;
          case "ERROR_USER_NOT_FOUND":
          case "user-not-found":
            message = "このメールアドレスに対応するユーザーが見つかりません。サインアップしてください。";
            break;
          default:
            message = "ログインに失敗しました。もう一度お試しください。";
            break;
        }
        print(message);
      }
    }
    else if(providerName == "mail-signin"){
      try {
        final User? user = (
          await FirebaseAuth.instance.signInWithEmailAndPassword( email: email!, password: password!)
        ).user;
        
        if (user != null){
          print("ログインしました　${user.email} , ${user.uid}");
          _user = user;
        }
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "ERROR_EMAIL_ALREADY_IN_USE":
          case "account-exists-with-different-credential":
          case "email-already-in-use":
            message = "このメールアドレスはすでに登録されているようです。";
            break;
          case "ERROR_WRONG_PASSWORD":
          case "wrong-password":
            message = "メールアドレスまたはパスワードに誤りがあるようです。";
            break;
          case "ERROR_USER_NOT_FOUND":
          case "user-not-found":
            message = "このメールアドレスは見つかりません。";
            break;
          case "ERROR_USER_DISABLED":
          case "user-disabled":
            message = "このユーザーは見つかりません。";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
          case "operation-not-allowed":
            message = "このアカウントでのログインが多すぎるようです。";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
          case "operation-not-allowed":
            message = "サーバーエラー。しばらくしてからお試しください。";
            break;
          case "ERROR_INVALID_EMAIL":
          case "invalid-email":
            message = "正しいメールアドレスを入力してください。";
            break;
          case "ERROR_USER_NOT_FOUND":
          case "user-not-found":
            message = "このメールアドレスに対応するユーザーが見つかりません。サインアップしてください。";
            break;
          default:
            message = "ログインに失敗しました。もう一度お試しください。";
            break;
        }
        print(message);
      }
    }
    notifyListeners();
    return message;
  }

  Future silentLogin() async {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future logout() async {
    _user = null;
    FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  Future deleteUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    final uid = user?.uid;
    
    // このユーザーが登録したシフトリクエストを削除する
    firestore.collection('shift-follower').where('user-id', isEqualTo: uid).get().then(
      (querySnapshot) {
        // 各ドキュメントに対して削除操作を行う
        for(var doc in querySnapshot.docs){
          doc.reference.delete().then((_) {
            print("Document successfully deleted!");
          }).catchError((error) {
            print("Error removing document: $error");
          });
        }
      }
    ).catchError(
      (error) {
        print("Error getting documents: $error");
      }
   );

    // このユーザが作成したシフト表とそれに基づくシフトリクエストを削除する
    print(user?.uid);
    firestore.collection('shift-leader').where('user-id', isEqualTo: user?.uid).get().then(
      (querySnapshot) {
        print(querySnapshot.docs.length);
        // 各ドキュメントに対して削除操作を行う
        for(var doc in querySnapshot.docs){
          var tableId = doc.id;
          doc.reference.delete().then((_) {
            print("Document successfully deleted!");
            firestore.collection('shift-follower').where('reference', isEqualTo: firestore.collection('shift-leader').doc(tableId)).get().then(
              (querySnapshot) {
                // 各ドキュメントに対して削除操作を行う
                for(var doc in querySnapshot.docs){
                  doc.reference.delete().then((_) {
                    print("Document successfully deleted!");
                  }).catchError((error) {
                    print("Error removing document: $error");
                  });
                }
              }
            ).catchError(
              (error) {
                print("Error getting documents: $error");
              }
            );
          }).catchError((error) {
            print("Error removing document: $error");
          });
        }
      }
    ).catchError(
      (error) {
        print("Error getting documents: $error");
      }
   );
  }

  Future deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    // ユーザーを削除
    await user?.delete();
    await FirebaseAuth.instance.signOut();
    print('ユーザーを削除しました!');
    _user = null;
    notifyListeners();
  }
}
