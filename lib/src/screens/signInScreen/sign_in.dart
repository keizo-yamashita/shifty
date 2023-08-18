////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/dialog.dart';
import 'package:shift/src/mylibs/sign_in/sign_in_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  
  final inputMailController = TextEditingController(text: "");
  final inputPasswordController = TextEditingController(text: "");
  
  bool isDisabled = false;
  
  @override
  Widget build(BuildContext context) {  

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: MyStyle.gradientDecolation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Shifty へようこそ', style: MyStyle.headlineStyleWhite25),
                const SizedBox(height: 10),
                SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: const Divider(color: Colors.white,)),
                const SizedBox(height: 10),
                Text('メールアドレスを用いてログイン', style: MyStyle.headlineStyleWhite20),
                const SizedBox(height: 10),
                SizedBox(
                  width: min(MediaQuery.of(context).size.width * 0.8, 300),
                  child: TextFormField(
                    controller: inputMailController,
                    cursorColor: MyStyle.backgroundColor,
                    style: MyStyle.defaultStyleWhite15,
                    autofillHints: const [AutofillHints.email], 
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      prefixIconColor: MyStyle.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyStyle.backgroundColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyStyle.backgroundColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input, color: Colors.white),
                      hintText: 'メールアドレス',
                      hintStyle: MyStyle.defaultStyleWhite15,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                
                const SizedBox(height: 10),
              
                SizedBox(
                  width: min(MediaQuery.of(context).size.width * 0.8, 300),
                  child: TextFormField(
                    controller: inputPasswordController,
                    cursorColor: MyStyle.backgroundColor,
                    style: MyStyle.defaultStyleWhite15,
                    autofillHints: const [AutofillHints.password], 
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      prefixIconColor: MyStyle.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyStyle.backgroundColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyStyle.backgroundColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input, color: Colors.white),
                      hintText: 'パスワード',
                      hintStyle: MyStyle.defaultStyleWhite15,
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    signInButton(context, "mail-create", "", "新規登録", Colors.tealAccent, MyStyle.headlineStyleBlack18, 75, inputMailController.text, inputPasswordController.text),
                    const SizedBox(width: 20),
                    signInButton(context, "mail-signin", "", "ログイン", Colors.yellow[100]!, MyStyle.headlineStyleBlack18, 75, inputMailController.text, inputPasswordController.text),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: const Divider(color: Colors.white,)),
                const SizedBox(height: 10),
                Text('プロバイダーを用いてログイン', style: MyStyle.headlineStyleWhite20),
                const SizedBox(height: 10),
                signInButton(context, "google", "assets/google_logo.png", "sign in with Google", Colors.white, MyStyle.headlineStyleBlack18),
                const SizedBox(height: 10),
                signInButton(context, "apple", "assets/apple_logo.png",   "sign in with Apple ID", Colors.black, MyStyle.headlineStyleWhite18),
                
                const SizedBox(height: 10),
                SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: const Divider(color: Colors.white,)),
                const SizedBox(height: 10),
                Text('ゲストユーザとしてログイン', style: MyStyle.headlineStyleWhite20),
                const SizedBox(height: 10),
                signInButton(context, "guest", "assets/person2.png", "ゲストログイン", Colors.tealAccent, MyStyle.headlineStyleBlack18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signInButton(BuildContext context, String providerName, String imageUri, String buttonTitle, Color baseColor, TextStyle textStyle, [double? width, String? mail, String? password]){
    
    var accountProvider = Provider.of<SignInProvider>(context);
    
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: MyStyle.hiddenColor, 
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
              showAlertDialog(context, "エラー", "メールアドレスとパスワードを\n入力してください。", true);
              isDisabled = false;
            }
            else if(password!.length < 6 ){
              showAlertDialog(context, "エラー", "パスワードは6文字以上で\n入力してください。", true);
              isDisabled = false;
            }
            else{
              showConfirmDialog(context, "確認",
                "このメールアドレスとパスワードで\n新規登録しますか？", "",
                (){
                  accountProvider.login(providerName, false, mail, password).then(
                    (message){
                      if(message != ""){
                        showAlertDialog(context, "エラー", message, true);
                        isDisabled = false;
                      }
                      else{
                        showAlertDialog(context, "確認", "新規登録しました。", false);
                        isDisabled = false;
                      }
                    }
                  ).catchError(
                    (onError){
                      isDisabled = false;
                    }
                  );
                },
                false
              );
            }
          }
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// メールでログインする場合 (新規登録済み)
          ////////////////////////////////////////////////////////////////////////////////////////////
          if(providerName == "mail-signin"){
            if(mail == "" || password == ""){
              showAlertDialog(context, "エラー", "メールアドレスとパスワードを\n入力してください。", true);
              isDisabled = false;
            }
            else if(password!.length < 6 ){
              showAlertDialog(context, "エラー", "パスワードは6文字以上で\n入力してください。", true);
              isDisabled = false;
            }
            else{
              accountProvider.login(providerName, false, mail, password).then(
                (message){
                  if(message != ""){
                    showAlertDialog(context, "エラー", message, true);
                    isDisabled = false;
                  }
                  else{
                    showAlertDialog(context, "確認", "ログインしました。", false);
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
              context, "確認",
              "ゲストユーザとして\nログインしますか？\n\n注意 : ゲストアカウントでは\n複数の端末でアカウントを\n共有することができません。", "",
              (){
                accountProvider.login(providerName, false).then(
                  (message){
                    showAlertDialog(context, "確認", "ゲストユーザとして\nログインしました。", false);
                    isDisabled = false;
                  }
                ).catchError(
                  (onError){
                    isDisabled = false;
                  }
                );
              },
              false
            );
          }
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// その他の方法でログインする場合
          ////////////////////////////////////////////////////////////////////////////////////////////
          else{
            accountProvider.login(providerName, false).then(
              (message){
                if(message != ""){
                  showAlertDialog(context, "エラー", message, true);
                  isDisabled = false;
                }
                else{
                  // showAlertDialog(context, "確認", "ログインしました。", false);
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
