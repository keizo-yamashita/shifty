
////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shift/main.dart';
import 'package:shift/src/app.dart';
import 'package:shift/src/components/deep_link_mixin.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/screens/createScreen/add_shift_request.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
 
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> with DeepLinkMixin{
  
  // URL からアクセする場合の画面遷移
  @override
  void onDeepLinkNotify(Uri? uri) {  
    String? parameter = uri!.queryParameters['id'];
    
    if(parameter != null){
      Navigator.push( context, MaterialPageRoute(builder: (context){
        ref.read(signInProvider).silentLogin();
        return AddShiftRequestWidget(tableId: parameter);
     }
     ));
    }
    setState(() {});
  }

  splashScreenTimer(){
    Timer(const Duration(seconds: 2), () async{
      ref.read(signInProvider).silentLogin();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AppWidget()));
    });
  }

  @override
  void initState() {
    super.initState();
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