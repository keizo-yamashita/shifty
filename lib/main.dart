////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shift/src/app_navigation_bar.dart';
import 'package:shift/src/screens/homeSCreen/setting.dart';
import 'package:shift/src/screens/homeScreen/home.dart';
import 'package:shift/src/screens/homeScreen/suggest.dart';
import 'package:shift/src/screens/inputScreen/input_shift_request.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// myh package
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/components/deep_link_mixin.dart';
import 'package:shift/src/components/sign_in/sign_in_provider.dart';
import 'package:shift/src/components/shift/shift_provider.dart';
import 'package:shift/src/components/setting_provider.dart';

final signInProvider       = ChangeNotifierProvider((ref) => SignInProvider());
final settingProvider      = ChangeNotifierProvider((ref) => SettingProvider());
final shiftFrameProvider   = ChangeNotifierProvider((ref) => ShiftFrameProvider());
final shiftRequestProvider = ChangeNotifierProvider((ref) => ShiftRequestProvider());
final shiftTableProvider   = ChangeNotifierProvider((ref) => ShiftTableProvider());
final deepLinkProvider     = ChangeNotifierProvider((ref) => DeepLinkProvider());

final rootNavigatorKey = GlobalKey<NavigatorState>();
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final likeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');
final cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'suggestion');

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder:(context, state, navigationShell){
        return AppNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes:[
            GoRoute(
              name: 'home',
              path: '/',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const HomeScreen(),
              ),
              routes: [
                GoRoute(
                  name: 'input_shift_request',
                  path: 'input_shift_request',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                      key: state.pageKey,
                      child: const InputShiftRequestPage()
                    );
                  },
                )
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes:[
            GoRoute(
              name: 'settings',
              path: '/settings',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const SettingScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes:[
            GoRoute(
              name: 'suggestion',
              path: '/suggestion',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const SuggestionBoxScreen(),
              ),
            ),
          ],
        ),
      ]
    ),
  ],
);


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingProvider).appBarHeight = AppBar().preferredSize.height;
      ref.read(settingProvider).navigationBarHeight = 56.0;
      ref.read(settingProvider).screenPaddingTop = MediaQuery.of(context).padding.top;
      ref.read(settingProvider).screenPaddingBottom = MediaQuery.of(context).padding.bottom;
      // デバッグログの出力
      print('AppBar Height: ${ref.read(settingProvider).appBarHeight}');
    },);
  }

  @override
  Widget build(BuildContext context) {

    ref.read(settingProvider).loadPreferences();

    return MaterialApp.router(
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

      // home: const SplashScreen(),
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
    );
  }
}