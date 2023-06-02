import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// my file
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/screens/account.dart';
import 'package:shift/src/screens/create_schedule.dart';
import 'package:shift/src/screens/home.dart';
import 'package:shift/src/functions/notification.dart';
import 'package:shift/src/screens/google_login_provider.dart';

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
  
  final List<MenuContent> _contents = [
    MenuContent(contentTitle: "シフト表一覧", contentIcon: Icons.home, content: const CreateScheduleWidget()),
    MenuContent(contentTitle: "お知らせ", contentIcon: Icons.notification_important_outlined, content: const NotificationScreen()),
    MenuContent(contentTitle: "アカウント", contentIcon: Icons.person_2, content: const AccountScreen()),
   MenuContent(contentTitle: "設定", contentIcon: Icons.settings, content: const HomeScreen()), 
  ];
  
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    var accountProvider = Provider.of<GoogleAccountProvider>(context);
    var screenSize      = MediaQuery.of(context).size;

    accountProvider.silentLogin();

    return Scaffold(
      // appBar: AppBar(title: const Text("",style: TextStyle(color: Colors.white))),
      drawer: Drawer(
        width: screenSize.width * 0.7,
        child: Column(
          children: [
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: Image.network(accountProvider.user?.photoUrl ?? '').image,
                        )
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(accountProvider.user?.displayName ?? '', style: MyFont.defaultStyle15, overflow: TextOverflow.ellipsis),
                            Text(accountProvider.user?.email ?? '', style: MyFont.commentStyle15, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ]
                )
              ),
            ),
            for(int index = 0; index < _contents.length; index++)
              ListTile(
                title: Text(_contents[index].contentTitle),
                leading: Icon(_contents[index].contentIcon, color: Colors.green, size: 30),
                onTap: () {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
              ),      
          ],
        ),
      ),

      body: SafeArea(
        child: (accountProvider.user != null) ? 
          _contents[_selectedIndex].content : 
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                signInButton(accountProvider, "assets/google_logo.png", "Google でサインインする", Colors.white, Colors.black),
              ],
            )
          )
      ) 
    );
  }

  Widget signInButton(GoogleAccountProvider account, String imageUri, String buttonTitle, Color baseColor, Color textColor){
    
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(baseColor),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      onPressed: () async {
        setState(() {
          account.login();
        });
      },
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage(imageUri),
                  height: 35.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(buttonTitle, style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class MenuContent {
  final String contentTitle;
  final IconData contentIcon;
  final Widget content;

  MenuContent({
    required this.contentTitle,
    required this.contentIcon,
    required this.content
  });
}