////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// ログインメソッド
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<String> login(
    String providerName,
    bool fromGuest, [
    String? email,
    String? password,
  ]) async {
    String message = "";

    ////////////////////////////////////////////////////////////////////////////////////////////
    /// Google でログイン
    ////////////////////////////////////////////////////////////////////////////////////////////

    if (providerName == "google") {
      await GoogleSignIn().signIn().then((googleSignIn) async {
        final GoogleSignInAuthentication? googleAuth =
            await googleSignIn?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        try {
          if (fromGuest) {
            await _user
                ?.linkWithCredential(credential)
                .then((value) => _user = value.user);
          } else {
            await FirebaseAuth.instance
                .signInWithCredential(credential)
                .then((value) => _user = value.user);
            notifyListeners();
          }
        } on FirebaseAuthException catch (e) {
          message = encodeFirebaseAuthException(e);
        }
      });
    }
    ////////////////////////////////////////////////////////////////////////////////////////////
    /// Apple でログイン
    ////////////////////////////////////////////////////////////////////////////////////////////

    else if (providerName == 'apple') {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      OAuthProvider oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      try {
        if (fromGuest) {
          await _user
              ?.linkWithCredential(credential)
              .then((value) => _user = value.user);
        } else {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) => _user = value.user);
        }
      } on FirebaseAuthException catch (e) {
        message = encodeFirebaseAuthException(e);
      }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////
    /// ゲストアカウントでログイン
    ////////////////////////////////////////////////////////////////////////////////////////////
    else if (providerName == "guest") {
      await FirebaseAuth.instance.signInAnonymously().then(
        (credential) {
          _user = credential.user;
        },
      );
    }
    ////////////////////////////////////////////////////////////////////////////////////////////
    /// メールでサインアップ
    ////////////////////////////////////////////////////////////////////////////////////////////
    else if (providerName == "mail-create") {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email!, password: password!)
            .then((value) => _user = value.user);
      } on FirebaseAuthException catch (e) {
        message = encodeFirebaseAuthException(e);
      }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////
    /// メールでログイン
    ////////////////////////////////////////////////////////////////////////////////////////////
    else if (providerName == "mail-signin") {
      final credential =
          EmailAuthProvider.credential(email: email!, password: password!);
      try {
        if (fromGuest) {
          await _user
              ?.linkWithCredential(credential)
              .then((value) => _user = value.user);
        } else {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) => _user = value.user);
        }
      } on FirebaseAuthException catch (e) {
        message = encodeFirebaseAuthException(e);
      }
    }
    notifyListeners();
    return message;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// アプリ起動時に呼び出すサイレントログインメソッド
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future silentLogin() async {
    final firebase = FirebaseAuth.instance;
    _user = firebase.currentUser;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// ログアウトメソッド
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future logout() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// ユーザーのデータを全て削除するメソッド
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future deleteUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    final uid = user?.uid;

    // このユーザーが登録したシフトリクエストを削除する
    firestore
        .collection('shift-follower')
        .where('user-id', isEqualTo: uid)
        .get()
        .then((querySnapshot) {
      // 各ドキュメントに対して削除操作を行う
      for (var doc in querySnapshot.docs) {
        doc.reference.delete().then((_) {
          print("Document successfully deleted!");
        }).catchError((error) {
          print("Error removing document: $error");
        });
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });

    // このユーザが作成したシフト表とそれに基づくシフトリクエストを削除する
    print(user?.uid);
    firestore
        .collection('shift-leader')
        .where('user-id', isEqualTo: user?.uid)
        .get()
        .then(
      (querySnapshot) {
        print(querySnapshot.docs.length);
        // 各ドキュメントに対して削除操作を行う
        for (var doc in querySnapshot.docs) {
          var tableId = doc.id;
          doc.reference.delete().then(
            (_) {
              print("Document successfully deleted!");
              firestore
                  .collection('shift-follower')
                  .where(
                    'reference',
                    isEqualTo:
                        firestore.collection('shift-leader').doc(tableId),
                  )
                  .get()
                  .then(
                (querySnapshot) {
                  // 各ドキュメントに対して削除操作を行う
                  for (var doc in querySnapshot.docs) {
                    doc.reference.delete().then(
                      (_) {
                        print("Document successfully deleted!");
                      },
                    ).catchError(
                      (error) {
                        print("Error removing document: $error");
                      },
                    );
                  }
                },
              ).catchError(
                (error) {
                  print("Error getting documents: $error");
                },
              );
            },
          ).catchError(
            (error) {
              print("Error removing document: $error");
            },
          );
        }
      },
    ).catchError(
      (error) {
        print("Error getting documents: $error");
      },
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// 現在ログインしているユーザを削除する
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<bool> deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    bool result = false;
    // ユーザーを削除
    user?.delete().then(
      (value) {
        FirebaseAuth.instance.signOut().then(
          (value) async {
            _user = null;
            result = false;
          },
        ).catchError(
          (onError) {
            result = true;
          },
        );
        notifyListeners();
      },
    );
    return result;
  }

  String encodeFirebaseAuthException(FirebaseAuthException error) {
    var message = "success";

    switch (error.code) {
      // for linkWithCredential
      case "credential-already-in-use":
      case "provider-already-linked":
        message = "このアカウントは既に使用されているため連携できません。他のアカウントをお試しください。";
        break;
      case "invalid-credential":
        message = "このアカウントは連携できません。他のアカウント(ログイン方法)をお試しください。";
        break;
      case "email-already-in-use":
        message = "このメールアドレスは既に使用されているため登録できません。他のメールアドレスをお試しください。";
        break;
      case "operation-not-allowed":
        message = "このプロバイダ及びアカウントは使用できません。他のプロバイダ・アカウントをお試しください。";
        break;
      case "invalid-email":
        message = "有効なメールアドレスと入力してください。";
        break;
      case "invalid-verification-code":
        message = "アカウントのパスワードが正しくありません。正しいパスワードを使用してください。";
        break;
      case "invalid-verification-id":
        message = "アカウントのIDが正しくありません。正しいIDを使用してください。";
        break;
      case "account-exists-with-different-credential":
        message = "このメールアドレス(アカウント)はすでに登録されているようです。";
        break;
      case "wrong-password":
        message = "メールアドレスまたはパスワードに誤りがあるようです。";
        break;
      case "user-not-found":
        message = "このメールアドレスに対応する\nユーザが見つかりません。\n新規登録するか別のメールアドレスと使用してください。";
        break;
      case "user-disabled":
        message = "このユーザーは無効になっているようです。";
        break;
      default:
        message = "失敗しました。もう一度お試しください。";
        break;
    }
    return message;
  }
}
