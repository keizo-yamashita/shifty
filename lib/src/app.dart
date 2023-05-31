import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/gestures.dart';
import 'screens/account.dart';
import 'screens/create_schedule.dart';
import 'screens/home.dart';
import 'screens/notification.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'シフト表作成アプリ',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      localizationsDelegates:const  [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', ''),],

      home: const MyStatefulWidget(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => MyStatefulWidgetState();
}

class MyStatefulWidgetState extends State<MyStatefulWidget> {
  static const _screens = [
    HomeScreen(),
    CreateScheduleWidget(),
    NotificationScreen(),
    AccountScreen()
  ];

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: const Text("シフト表作成アプリ",style: TextStyle(color: Colors.white))),
        drawer: Drawer(
          width: screenSize.width * 0.7,
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration( color: Colors.green),
                child: Text('メニュー', style: TextStyle( fontSize: 15, color: Colors.white)),
              ),
              ListTile(
                title: const Text('登録シフト表一覧'),
                leading: const Icon(Icons.home, color: Colors.green, size: 30),
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('シフト表の作成'),
                leading: const Icon(Icons.create, color: Colors.green, size: 30),
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading:  const Icon(Icons.notifications, color: Colors.green, size: 30),
                title: const Text('お知らせ'),
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.green, size: 30),
                title: const Text('アカウント'),
                onTap: () {
                  setState(() => _selectedIndex = 3);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.green, size: 30),
                title: const Text('設定'),
                onTap: () {
                  setState(() => _selectedIndex = 3);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green, size: 30),
                title: const Text('お問い合わせ'),
                onTap: () {
                  setState(() => _selectedIndex = 3);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: _screens[_selectedIndex]
      );
  }
}
