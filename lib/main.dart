////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// myh package
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/components/deep_link_mixin.dart';
import 'package:shift/src/screens/splashScreen/splash_screen.dart';
import 'package:shift/src/components/sign_in/sign_in_provider.dart';
import 'package:shift/src/components/shift/shift_provider.dart';
import 'package:shift/src/components/setting_provider.dart';

final signInProvider       = ChangeNotifierProvider((ref) => SignInProvider());
final settingProvider      = ChangeNotifierProvider((ref) => SettingProvider());
final shiftFrameProvider   = ChangeNotifierProvider((ref) => ShiftFrameProvider());
final shiftRequestProvider = ChangeNotifierProvider((ref) => ShiftRequestProvider());
final shiftTableProvider   = ChangeNotifierProvider((ref) => ShiftTableProvider());
final deepLinkProvider     = ChangeNotifierProvider((ref) => DeepLinkProvider());


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseDatabase.instance.setPersistenceEnabled(true);

  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp>{

  @override
  Widget build(BuildContext context) {

    ref.read(settingProvider).loadPreferences();
    
    return MaterialApp(
      title: 'Shifty',
      theme: ThemeData(
        primaryColor: Styles.primaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Styles.bgColor.withOpacity(0.9),
          foregroundColor: Styles.primaryColor,
          elevation: 2.0
        ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.black,
          brightness: Brightness.light,
        ),
        datePickerTheme: const DatePickerThemeData(
          rangePickerBackgroundColor: Colors.white,
          rangePickerHeaderForegroundColor: Styles.primaryColor,
        ),
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        primaryColor: Styles.primaryColor,
        scaffoldBackgroundColor: Colors.grey[800],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900]?.withOpacity(0.9),
          foregroundColor: Styles.primaryColor,
          elevation: 2.0
        ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.white,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        
      ),
      
      themeMode: (ref.watch(settingProvider).enableDarkTheme) ? ThemeMode.dark : ThemeMode.light,

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