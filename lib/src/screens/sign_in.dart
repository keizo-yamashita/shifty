import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/google_login_provider.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: MyFont.gradientDecolation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Welcome to Shifty !!', style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              const Text('Please, Sign In following Buttons', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),

              const SizedBox(height: 50),
              signInButton(context, "assets/google_logo.png", "Sign In with Google", Colors.white, MyFont.headlineStyleBlack20),
              const SizedBox(height: 20),
              signInButton(context, "assets/apple_logo.png",  "Sign In with Apple  ", Colors.black, MyFont.headlineStyleWhite20),
            ],
          ),
        ),
      ),
    );
  }

    Widget signInButton(BuildContext context, String imageUri, String buttonTitle, Color baseColor, TextStyle textStyle){
    
    var accountProvider = Provider.of<GoogleAccountProvider>(context);

    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(baseColor),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      onPressed: () async {
        accountProvider.login(); 
      },
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
