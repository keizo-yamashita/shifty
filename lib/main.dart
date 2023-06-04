import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shift/src/screens/splashScreen/splash_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/functions/google_login_provider.dart';
import 'package:shift/src/functions/font.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => GoogleAccountProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var accountProvider = Provider.of<GoogleAccountProvider>(context);
    accountProvider.silentLogin();

    return MaterialApp(
      title: 'Shifty',
      debugShowCheckedModeBanner: false,
      localizationsDelegates:const  [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', ''),],

      home: const SplashScreen(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
    );
  }
}
