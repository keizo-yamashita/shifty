////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:shift/components/form/utility/dialog.dart';
import 'package:shift/components/form/utility/snackbar.dart';
import 'package:shift/components/style/style.dart';
import 'package:shift/main.dart';

// my package

final GlobalKey<ScaffoldState> _signInScaffoldKey = GlobalKey<ScaffoldState>();

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends ConsumerState<SignInScreen> {
  
  final inputMailController = TextEditingController(text: "");
  final inputPasswordController = TextEditingController(text: "");
  
  bool isDisabled = false;
  
  @override
  Widget build(BuildContext context) {  

    return Scaffold(
      key: _signInScaffoldKey,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: Styles.gradientDecolation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Shifty', style: Styles.defaultStyleWhite20),
                Text('ダウンロードありがとうございます。', style: Styles.defaultStyleWhite20),
                const SizedBox(height: 10),
                SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: const Divider(color: Colors.white,)),
                const SizedBox(height: 10),
                Text('メールアドレスを用いてログイン', style: Styles.defaultStyleWhite20),
                const SizedBox(height: 10),
                SizedBox(
                  width: min(MediaQuery.of(context).size.width * 0.8, 300),
                  child: TextFormField(
                    controller: inputMailController,
                    cursorColor: Styles.lightBgColor,
                    style: Styles.defaultStyleWhite15,
                    autofillHints: const [AutofillHints.email], 
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      prefixIconColor: Styles.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Styles.lightBgColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Styles.lightBgColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input, color: Colors.white),
                      hintText: 'メールアドレス',
                      hintStyle: Styles.defaultStyleWhite15,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                
                const SizedBox(height: 10),
              
                SizedBox(
                  width: min(MediaQuery.of(context).size.width * 0.8, 300),
                  child: TextFormField(
                    controller: inputPasswordController,
                    cursorColor: Styles.lightBgColor,
                    style: Styles.defaultStyleWhite15,
                    autofillHints: const [AutofillHints.password], 
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      prefixIconColor: Styles.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Styles.lightBgColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Styles.lightBgColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input, color: Colors.white),
                      hintText: 'パスワード',
                      hintStyle: Styles.defaultStyleWhite15,
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    signInButton(context, ref, "mail-create", "", "新規登録", Colors.tealAccent, Styles.defaultStyleBlack18, 75, inputMailController.text, inputPasswordController.text),
                    const SizedBox(width: 20),
                    signInButton(context, ref, "mail-signin", "", "ログイン", Colors.yellow[100]!, Styles.defaultStyleBlack18, 75, inputMailController.text, inputPasswordController.text),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: const Divider(color: Colors.white,)),
                const SizedBox(height: 10),
                Text('プロバイダーを用いてログイン', style: Styles.defaultStyleWhite20),
                const SizedBox(height: 10),
                signInButton(context, ref, "google", "assets/google_logo.png", "sign in with Google", Colors.white, Styles.defaultStyleBlack18),
                const SizedBox(height: 10),
                signInButton(context, ref, "apple", "assets/apple_logo.png",   "sign in with Apple ID", Colors.black, Styles.defaultStyleWhite18),
                
                const SizedBox(height: 10),
                SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: const Divider(color: Colors.white,)),
                const SizedBox(height: 10),
                Text('ゲストユーザとしてログイン', style: Styles.defaultStyleWhite20),
                const SizedBox(height: 10),
                signInButton(context, ref, "guest", "assets/person2.png", "ゲストログイン", Colors.tealAccent, Styles.defaultStyleBlack18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signInButton(BuildContext context, WidgetRef ref, String providerName, String imageUri, String buttonTitle, Color baseColor, TextStyle textStyle, [double? width, String? mail, String? password]){
    
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: Styles.hiddenColor, 
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: baseColor,
          side:const BorderSide(color: Colors.transparent),
        ),
        onPressed: isDisabled ? null : (){
          isDisabled = true;
          
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// メールでログインする場合 (新規登録から)
          ////////////////////////////////////////////////////////////////////////////////////////////
          if(providerName == "mail-create"){
            if(mail == "" || password == ""){
              showAlertDialog(context, ref, "エラー", "メールアドレスとパスワードを\n入力してください。", true);
              isDisabled = false;
            }
            else if(password!.length < 6 ){
              showAlertDialog( context, ref, "エラー", "パスワードは6文字以上で\n入力してください。", true);
              isDisabled = false;
            }
            else{
              showConfirmDialog(
                context: context,
                ref : ref,
                title: "確認",
                message1: "このメールアドレスとパスワードで\n新規登録しますか？",
                message2: "",
                onAccept: (){
                  ref.read(signInProvider).login(providerName, false, mail, password).then(
                    (message){
                      if(message != ""){
                        showAlertDialog(context, ref, "エラー", message, true);
                        isDisabled = false;
                      }
                      else{
                        showSnackBar(context: context, message: "新規登録しました。", type: SnackBarType.info);
                        context.go('/home');
                        isDisabled = false;
                      }
                    }
                  ).catchError(
                    (onError){
                      isDisabled = false;
                    }
                  );
                },
                confirm: false,
              );
            }
          }
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// メールでログインする場合 (新規登録済み)
          ////////////////////////////////////////////////////////////////////////////////////////////
          if(providerName == "mail-signin"){
            if(mail == "" || password == ""){
              showAlertDialog(context, ref, "エラー", "メールアドレスとパスワードを\n入力してください。", true);
              isDisabled = false;
            }
            else if(password!.length < 6 ){
              showAlertDialog(context, ref, "エラー", "パスワードは6文字以上で\n入力してください。", true);
              isDisabled = false;
            }
            else{
              ref.read(signInProvider).login(providerName, false, mail, password).then(
                (message){
                  if(message != ""){
                    showAlertDialog(context, ref, "エラー", message, true);
                    isDisabled = false;
                  }
                  else{
                    showSnackBar(context: context, message: "ログインしました。", type: SnackBarType.info);
                    context.go('/home');
                    isDisabled = false;
                  }
                }
              ).catchError(
                (onError){
                  isDisabled = false;
                }
              );
            }
          }
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// ゲストユーザとしてログインする場合
          ////////////////////////////////////////////////////////////////////////////////////////////
          else if(providerName == 'guest'){
            showConfirmDialog(
              context: context,
              ref : ref,
              title: "確認",
              message1: "ゲストユーザとして\nログインしますか？\n\n注意 : ゲストアカウントでは\n複数の端末でアカウントを\n共有することができません。",
              message2: "",
              onAccept: (){
                ref.read(signInProvider).login(providerName, false).then(
                  (message){
                    showSnackBar(context: context, message: "ゲストユーザとして\nログインしました。", type: SnackBarType.info);
                    context.go('/home');
                    isDisabled = false;
                  }
                ).catchError(
                  (onError){
                    isDisabled = false;
                  }
                );
              },
              confirm: false
            );
          }
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// その他の方法でログインする場合
          ////////////////////////////////////////////////////////////////////////////////////////////
          else{
            ref.read(signInProvider).login(providerName, false).then(
              (message){
                if(message != ""){
                  showAlertDialog(context, ref, "エラー", message, true);
                  isDisabled = false;
                }
                else{
                  showSnackBar(context: context, message: "ログインしました。", type: SnackBarType.info);
                  context.go('/home');
                  isDisabled = false;
                }
              }
            ).catchError(
              (onError){
                isDisabled = false;
              }
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if(imageUri != "")
              Image(
                image: AssetImage(imageUri),
                height: 25.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(width: width ?? 200, child: Text(buttonTitle, style: textStyle, textAlign: TextAlign.center)),
              )
            ],
          ),
        )
      ),
    );
  }
}
