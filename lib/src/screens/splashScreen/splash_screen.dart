import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/app.dart';
import 'package:shift/src/mylibs/deep_link_mixin.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/functions/sing_in/sign_in_provider.dart';
import 'package:shift/src/screens/createScreen/add_shift_request.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
 
  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with DeepLinkMixin{
  
  // URL からアクセする場合の画面遷移
  @override
  void onDeepLinkNotify(Uri? uri) {  
    String? parameter = uri!.queryParameters['id'];
    
    if(parameter != null){
      Navigator.push( context, MaterialPageRoute(builder: (context){
        var signInProvider = Provider.of<SignInProvider>(context);
        signInProvider.silentLogin();
        return AddShiftRequestWidget(tableId: parameter);
     }
     ));
    }
    setState(() {});
  }

  splashScreenTimer(){
    Timer(const Duration(seconds: 2), () async{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AppWidget()));
    });
  }

  @override
  void initState() {
    super.initState();
    final user = Provider.of<SignInProvider>(context,listen: false);
    user.silentLogin();
    splashScreenTimer();
  }

  @override
  Widget build(BuildContext context){

    // 画面の向きを縦方向に固定
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    return Material(
      child: Container(
        decoration: MyStyle.gradientDecolation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Image.asset("assets/shifty_logo.png"),
          ),
        ),
      ),
    );
  }
}