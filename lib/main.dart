// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:shift/app_navigation_bar.dart';
import 'package:shift/components/style/style.dart';
import 'package:shift/firebase_options.dart';
import 'package:shift/providers/deep_link_mixin.dart';
import 'package:shift/providers/setting_provider.dart';
import 'package:shift/providers/shift_provider.dart';
import 'package:shift/providers/sign_in_provider.dart';
import 'package:shift/screens/homeScreen/home.dart';
import 'package:shift/screens/homeScreen/notification.dart';
import 'package:shift/screens/settingsScreen/contact.dart';
import 'package:shift/screens/settingsScreen/link_account.dart';
import 'package:shift/screens/settingsScreen/privacy_policy.dart';
import 'package:shift/screens/settingsScreen/setting.dart';
import 'package:shift/screens/settingsScreen/user_info.dart';
import 'package:shift/screens/shiftScreen/create_shift_frame.dart';
import 'package:shift/screens/shiftScreen/follow_shift_frame.dart';
import 'package:shift/screens/shiftScreen/input_shift_request.dart';
import 'package:shift/screens/shiftScreen/manage_shift_table.dart';
import 'package:shift/screens/signInScreen/sign_in.dart';
import 'package:shift/screens/splashScreen/splash_screen.dart';

final signInProvider = ChangeNotifierProvider((ref) => SignInProvider());
final settingProvider = ChangeNotifierProvider((ref) => SettingProvider());
final shiftFrameProvider =
    ChangeNotifierProvider((ref) => ShiftFrameProvider());
final shiftRequestProvider =
    ChangeNotifierProvider((ref) => ShiftRequestProvider());
final shiftTableProvider =
    ChangeNotifierProvider((ref) => ShiftTableProvider());
final deepLinkProvider = ChangeNotifierProvider((ref) => DeepLinkProvider());

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>(
  (ref) {
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
        if (isStarted) {
          return null;
        } else {
          if (logedInState.user != null) {
            isStarted = true;
            return '/home';
          } else {
            isStarted = true;
            return '/signin';
          }
        }
      },
      routes: [
        StatefulShellRoute.indexedStack(
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state, navigationShell) {
              return AppNavigationBar(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    name: '/notification',
                    path: '/notification',
                    pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: const NotificationScreen(),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
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
                              child: const InputShiftRequestPage());
                        },
                      ),
                      GoRoute(
                        name: 'create_shift_frame',
                        path: 'create_shift_frame',
                        pageBuilder: (context, state) {
                          return MaterialPage(
                              key: state.pageKey,
                              child: const CreateShiftFramePage());
                        },
                      ),
                      GoRoute(
                        name: 'add_shift_request',
                        path: 'add_shift_request',
                        pageBuilder: (context, state) {
                          return MaterialPage(
                              key: state.pageKey,
                              child: const FollowShiftFramePage());
                        },
                      ),
                      GoRoute(
                        name: 'manage_shift_table',
                        path: 'manage_shift_table',
                        pageBuilder: (context, state) {
                          return MaterialPage(
                              key: state.pageKey,
                              child: const ManageShiftTablePage());
                        },
                      )
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                      name: 'settings',
                      path: '/settings',
                      pageBuilder: (context, state) => NoTransitionPage(
                            key: state.pageKey,
                            child: const SettingScreen(),
                          ),
                      routes: [
                        GoRoute(
                          name: 'userInfo',
                          path: 'userInfo',
                          pageBuilder: (context, state) => MaterialPage(
                            key: state.pageKey,
                            child: const UserInfoPage(),
                          ),
                        ),
                        GoRoute(
                          name: 'link_account',
                          path: 'link_account',
                          pageBuilder: (context, state) => MaterialPage(
                            key: state.pageKey,
                            child: const LinkAccountScreen(),
                          ),
                        ),
                        GoRoute(
                          name: 'contact',
                          path: 'contact',
                          pageBuilder: (context, state) => MaterialPage(
                            key: state.pageKey,
                            child: const ContactPage(),
                          ),
                        ),
                        GoRoute(
                          name: 'privacy_policy',
                          path: 'privacy_policy',
                          pageBuilder: (context, state) => MaterialPage(
                            key: state.pageKey,
                            child: const PrivacyPolicyPage(),
                          ),
                        ),
                      ]),
                ],
              ),
            ]),
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
  },
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.read(settingProvider).appBarHeight = AppBar().preferredSize.height;
        ref.read(settingProvider).navigationBarHeight = 56.0;
        ref.read(settingProvider).screenPaddingTop =
            MediaQuery.of(context).padding.top;
        ref.read(settingProvider).screenPaddingBottom =
            MediaQuery.of(context).padding.bottom;
        ref.read(signInProvider).silentLogin();
        WidgetsBinding.instance.addObserver(this);
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    ref.read(settingProvider).isRotating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingProvider).appBarHeight = AppBar().preferredSize.height;
      ref.read(settingProvider).navigationBarHeight = 56.0;
      ref.read(settingProvider).screenPaddingTop =
          MediaQuery.of(context).padding.top;
      ref.read(settingProvider).screenPaddingBottom =
          MediaQuery.of(context).padding.bottom;
      ref.read(settingProvider).isRotating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.read(settingProvider).loadPreferences();
    final isDark = ref.watch(settingProvider).enableDarkTheme;
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Shifty',
      theme: ThemeData(
          scaffoldBackgroundColor: Styles.lightBgColor,
          primaryColor: Styles.primaryColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: Styles.lightColor,
            elevation: 0.4,
            scrolledUnderElevation: 0.4,
            shadowColor: Colors.black,
          ),
          cupertinoOverrideTheme: const CupertinoThemeData(
            primaryColor: Colors.black,
            brightness: Brightness.light,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Styles.lightColor,
            selectedItemColor: Styles.primaryColor,
            unselectedItemColor: Colors.grey,
          ),
          cardColor: Styles.lightColor,
          brightness: Brightness.light),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Styles.darkBgColor,
        primaryColor: Styles.primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Styles.darkColor,
          elevation: 0.4,
          scrolledUnderElevation: 0.4,
          shadowColor: Color(0xFF8C8C8C),
        ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.white,
          brightness: Brightness.dark,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Styles.darkColor,
          selectedItemColor: Styles.primaryColor,
          unselectedItemColor: Styles.hiddenColor,
        ),
        cardColor: Styles.darkColor,
        brightness: Brightness.dark,
      ),
      themeMode: (isDark) ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', ''),
      ],
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
    );
  }
}
