import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:shift/src/app.dart';
import 'package:shift/src/functions/google_login_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  sleep(const Duration(seconds: 1));
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => GoogleAccountProvider(),
      child: const MyApp(),
    )
  );
}
