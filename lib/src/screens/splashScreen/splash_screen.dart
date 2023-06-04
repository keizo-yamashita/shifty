import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shift/src/app.dart';
import 'package:shift/src/functions/font.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
 
  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  splashScreenTimer(){
    Timer(const Duration(seconds: 2), () async{
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
    return Material(
      child: Container(
        decoration: MyFont.gradientDecolation,
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