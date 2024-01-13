import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/components/form/utility/dialog.dart';

class LinkAccountScreen extends ConsumerStatefulWidget {
  const LinkAccountScreen({Key? key}) : super(key: key);

  @override
  LinkAccountScreenState createState() => LinkAccountScreenState();
}

class LinkAccountScreenState extends ConsumerState<LinkAccountScreen> {
  
  final inputMailController = TextEditingController(text: "");
  final inputPasswordController = TextEditingController(text: "");

  Size  screenSize = const Size(0, 0);
  
  bool isDisabled = false;
  
  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - appBarHeight);

    return Scaffold(
      appBar: AppBar(
        title: Text("アカウント連携", style: Styles.headlineStyleGreen20),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: Styles.gradientDecolation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screenSize.height * 0.04 + appBarHeight),
                SizedBox(
                  width: screenSize.width*0.8,
                  child: Text('下記のいづれかの方法でログインすることで、ゲストアカウントを通常アカウントと連携します。連携後は、他端末への移行や複数端末でのログインが可能になります。', style: Styles.headlineStyleWhite15),
                ),
                const SizedBox(height: 20),
                SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: const Divider(color: Colors.white,)),
                const SizedBox(height: 10),
                Text('メールアドレスを用いてログイン', style: Styles.headlineStyleWhite20),
                const SizedBox(height: 10),
                SizedBox(
                  width: min(MediaQuery.of(context).size.width * 0.8, 300),
                  child: TextFormField(
                    controller: inputMailController,
                    cursorColor: Styles.bgColor,
                    style: Styles.headlineStyleWhite15,
                    autofillHints: const [AutofillHints.email], 
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      prefixIconColor: Styles.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Styles.bgColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Styles.bgColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input, color: Colors.white),
                      hintText: 'メールアドレス',
                      hintStyle: Styles.headlineStyleWhite15,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                
                const SizedBox(height: 10),
              
                SizedBox(
                  width: min(MediaQuery.of(context).size.width * 0.8, 300),
                  child: TextFormField(
                    controller: inputPasswordController,
                    cursorColor: Styles.bgColor,
                    style: Styles.headlineStyleWhite15,
                    autofillHints: const [AutofillHints.password], 
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      prefixIconColor: Styles.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Styles.bgColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Styles.bgColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input, color: Colors.white),
                      hintText: 'パスワード',
                      hintStyle: Styles.headlineStyleWhite15,
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),
                linkButton(context, ref, "mail-signin", "assets/mail.png", "新規登録 & ログイン", Colors.yellow[100]!, Styles.headlineStyleBlack18, 180, inputMailController.text, inputPasswordController.text),
                const SizedBox(height: 10),
                SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: const Divider(color: Colors.white,)),
                const SizedBox(height: 10),
                Text('プロバイダーを用いてログイン', style: Styles.headlineStyleWhite20),
                const SizedBox(height: 20),
                linkButton(context, ref, "google", "assets/google_logo.png", "sign in with Google", Colors.white, Styles.headlineStyleBlack18),
                const SizedBox(height: 10),
                linkButton(context, ref, "apple", "assets/apple_logo.png",   "sign in with Apple ID", Colors.black, Styles.headlineStyleWhite18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget linkButton(BuildContext context, WidgetRef ref, String providerName, String imageUri, String buttonTitle, Color baseColor, TextStyle textStyle, [double? width, String? mail, String? password]){
    
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
              showConfirmDialog(context, ref, "確認",
                "このメールアドレスとパスワードで\n新規登録しますか？", "",
                (){
                  ref.read(signInProvider).login(providerName, true, mail, password).then(
                    (message){
                      if(message != ""){
                        showAlertDialog(context, ref, "エラー", message, true);
                        isDisabled = false;
                      }
                      else{
                        Navigator.pop(context);
                        showAlertDialog(context, ref, "確認", "新規登録後、連携しました。", false);
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
          /// その他の方法でログインする場合
          ////////////////////////////////////////////////////////////////////////////////////////////
          else{
            ref.read(signInProvider).login(providerName, true).then(
              (message){
                if(message != ""){
                  showAlertDialog(context, ref, "エラー", message, true);
                  isDisabled = false;
                }
                else{
                  Navigator.pop(context);
                  showAlertDialog(context, ref, "確認", "連携しました。", false);
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
