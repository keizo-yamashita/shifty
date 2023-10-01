////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';


// myh package
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/deep_link_mixin.dart';
import 'package:shift/src/screens/splashScreen/splash_screen.dart';
import 'package:shift/src/mylibs/sign_in/sign_in_provider.dart';
import 'package:shift/src/mylibs/shift/shift_provider.dart';
import 'package:shift/src/mylibs/setting_provider.dart';
// import 'package:dart_openai/dart_openai.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context) => SignInProvider()),
        ChangeNotifierProvider(create: (context) => SettingProvider()),
        ChangeNotifierProvider(create: (context) => ShiftFrameProvider()),
        ChangeNotifierProvider(create: (context) => ShiftRequestProvider()),
        ChangeNotifierProvider(create: (context) => ShiftTableProvider()),
        ChangeNotifierProvider(create: (context) => DeepLinkProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp>{

  @override
  Widget build(BuildContext context) {

    var settingProvider = Provider.of<SettingProvider>(context);
    settingProvider.loadPreferences();
    
    return MaterialApp(
      title: 'Shifty',
      theme: ThemeData(
        primaryColor: MyStyle.primaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: MyStyle.backgroundColor.withOpacity(0.9),
          foregroundColor: MyStyle.primaryColor,
          elevation: 2.0
        ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.black,
          brightness: Brightness.light,
        ),
        datePickerTheme: const DatePickerThemeData(
          rangePickerBackgroundColor: Colors.white,
          rangePickerHeaderForegroundColor: MyStyle.primaryColor,
        ),
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        primaryColor: MyStyle.primaryColor,
        // scaffoldBackgroundColor: Colors.grey[800],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900]?.withOpacity(0.9),
          foregroundColor: MyStyle.primaryColor,
          elevation: 2.0
        ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.white,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        
      ),
      
      themeMode: (settingProvider.enableDarkTheme) ? ThemeMode.dark : ThemeMode.light,

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

