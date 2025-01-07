
////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:shift/components/style/style.dart';
import 'package:shift/main.dart';
import 'package:shift/providers/deep_link_mixin.dart';
import 'package:shift/screens/shiftScreen/follow_shift_frame.dart';

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
        return FollowShiftFramePage(tableId: parameter);
     }
     ),);
    }
    setState(() {});
  }

  splashScreenTimer(){
    Timer(const Duration(milliseconds: 500), () async{
      ref.read(signInProvider).silentLogin().then((value){
        if(ref.read(signInProvider).user != null){
          context.go('/home');
        }else{
          context.go('/signin');
        }
      });
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
        decoration: Styles.gradientDecolation,
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
