////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shift/src/app_navigation_bar.dart';
import 'package:shift/src/screens/createScreen/add_shift_request.dart';
import 'package:shift/src/screens/createScreen/create_shift_frame.dart';
import 'package:shift/src/screens/homeSCreen/setting.dart';
import 'package:shift/src/screens/homeScreen/home.dart';
import 'package:shift/src/screens/homeScreen/suggest.dart';
import 'package:shift/src/screens/inputScreen/input_shift_request.dart';
import 'package:shift/src/screens/manageScreen/manage_shift_table.dart';
import 'package:shift/src/screens/signInScreen/sign_in.dart';
import 'package:shift/src/screens/splashScreen/splash_screen.dart';
import 'firebase_options.dart';

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

final routerProvider = Provider<GoRouter>((ref) {

  final logedInState = ref.read(signInProvider);
  var isStarted = false;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: logedInState,
    redirect: (BuildContext context, GoRouterState state) {
      if (state.uri.path == '/splash') {
        return null;
      }
      if(isStarted){
        return null; 
      }else{
        if(logedInState.user != null){
          isStarted = true;
          return '/home';
        }
        else{
          isStarted = true;
          return '/signin';
        }
      }
    },
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
                name: 'home',
                path: '/home',
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
                  ),
                  GoRoute(
                    name: 'create_shift_frame',
                    path: 'create_shift_frame',
                    pageBuilder: (context, state) {
                      return MaterialPage(
                        key: state.pageKey,
                        child: const CreateShiftFramePage()
                      );
                    },
                  ),
                  GoRoute(
                    name: 'add_shift_request',
                    path: 'add_shift_request',
                    pageBuilder: (context, state) {
                      return MaterialPage(
                        key: state.pageKey,
                        child: const AddShiftRequestPage()
                      );
                    },
                  ),
                  GoRoute(
                    name: 'manage_shift_table',
                    path: 'manage_shift_table',
                    pageBuilder: (context, state) {
                      return MaterialPage(
                        key: state.pageKey,
                        child: const ManageShiftTablePage()
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
      GoRoute(
      name: 'spalash',
      path: '/splash',
      pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        name: 'signin',
        path: '/signin',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SignInScreen(),
        ),
      ),
    ],
  );
},);


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
      ref.read(signInProvider).silentLogin();
    },);
  }

  @override
  Widget build(BuildContext context) {

    ref.read(settingProvider).loadPreferences();

    final router = ref.watch(routerProvider);

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

      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
    );
  }
}