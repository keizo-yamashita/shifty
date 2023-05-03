import 'package:flutter/material.dart';
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
    CreateScheduleWidget(),
    HomeScreen(),
    NotificationScreen(),
    AccountScreen()
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("シフト表作成アプリ",style: TextStyle(color: Colors.white))),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          iconSize: 30,
          selectedFontSize: 13,
          unselectedFontSize: 10,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.create), label: '作成'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '入力'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'お知らせ'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'アカウント'),
          ],
          type: BottomNavigationBarType.fixed,
        ));
  }
}
