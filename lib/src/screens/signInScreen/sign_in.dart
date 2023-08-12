import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/functions/style.dart';
import 'package:shift/src/functions/dialog.dart';
import 'package:shift/src/functions/sing_in/sign_in_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  
  final inputMailController = TextEditingController(text: "");
  final inputPasswordController = TextEditingController(text: "");
  
  @override
  Widget build(BuildContext context) {  

    if( Provider.of<SignInProvider>(context).user != null){
      Navigator.pop(context);
    }

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
                Text('Shifty へようこそ', style: MyStyle.headlineStyleWhite20),
                const SizedBox(height: 10),
                Text('下記より、サインインして下さい', style: MyStyle.headlineStyleWhite20),
                
                const SizedBox(height: 50),
              
                SizedBox(
                  width: min(MediaQuery.of(context).size.width * 0.8, 300),
                  child: TextFormField(
                    controller: inputMailController,
                    cursorColor: MyStyle.backgroundColor,
                    style: MyStyle.defaultStyleWhite15,
                    autofillHints: const [AutofillHints.email], 
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
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
                
                const SizedBox(height: 20),
              
                SizedBox(
                  width: min(MediaQuery.of(context).size.width * 0.8, 300),
                  child: TextFormField(
                    controller: inputPasswordController,
                    cursorColor: MyStyle.backgroundColor,
                    style: MyStyle.defaultStyleWhite15,
                    autofillHints: const [AutofillHints.password], 
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
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
                const SizedBox(height: 20),
                signInButton(context, "mail-signin", "assets/person1.png", " メールでサインイン  ", Colors.yellow[100]!, MyStyle.headlineStyleBlack20, inputMailController.text, inputPasswordController.text),
                const SizedBox(height: 20),
                signInButton(context, "mail-create", "assets/person2.png", " メールでサインアップ", Colors.tealAccent, MyStyle.headlineStyleBlack20, inputMailController.text, inputPasswordController.text),
                const SizedBox(height: 20),
                signInButton(context, "google", "assets/google_logo.png", " Googleでサインイン ", Colors.white, MyStyle.headlineStyleBlack20),
                const SizedBox(height: 20),
                signInButton(context, "apple", "assets/apple_logo.png",   " Appleでサインイン  ", Colors.black, MyStyle.headlineStyleWhite20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signInButton(BuildContext context, String providerName, String imageUri, String buttonTitle, Color baseColor, TextStyle textStyle, [String? mail, String? password]){
    
    var accountProvider = Provider.of<SignInProvider>(context);
    
    return OutlinedButton(
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
      onPressed: () async {
        if(providerName.contains("mail")){
          if(mail == "" || password == ""){
            showAlertDialog(context, "エラー", "メールアドレスとパスワードを\n入力してください。", true);
          }
          else if(password!.length < 6 ){
            showAlertDialog(context, "エラー", "パスワードは6文字以上で\n入力してください。", true);
          }
          else{
            accountProvider.login(providerName, mail, password).then(
              (message){
                if(message != "" && message != "登録しました。サインインしてください。"){
                  showAlertDialog(context, "エラー", message, true);
                }
                else if(message == "登録しました。\nサインインしてください。"){
                  showAlertDialog(context, "登録", message, false);
                }
              }
            );
          }
        }
        else{
          accountProvider.login(providerName).then((value) => null);
        }
      },
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage(imageUri),
                  height: 35.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(buttonTitle, style: textStyle),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}
