import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// my file
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/google_login_provider.dart';

import 'package:shift/src/screens/sign_in.dart';
import 'package:shift/src/screens/home.dart';
import 'package:shift/src/screens/account.dart';
import 'package:shift/src/screens/notification.dart';
import 'package:shift/src/screens/setting.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);
  @override
  State<AppWidget> createState() => AppWidgetState();
}

class AppWidgetState extends State<AppWidget> {
  final List<MenuContent> _contents = [
    MenuContent(contentTitle: "マイシフト", contentIcon: Icons.home,                            content: const HomeWidget()),
    // MenuContent(contentTitle: "シフト表作成", contentIcon: Icons.create,                          content: const CreateScheduleWidget()),
    MenuContent(contentTitle: "お知らせ",     contentIcon: Icons.notification_important_outlined, content: const NotificationScreen()),
    MenuContent(contentTitle: "アカウント",   contentIcon: Icons.person_2,                        content: const AccountScreen()),
    MenuContent(contentTitle: "設定",         contentIcon: Icons.settings,                        content: const HomeScreen()), 
  ];
  
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    var accountProvider = Provider.of<GoogleAccountProvider>(context);
    var screenSize      = MediaQuery.of(context).size;

    // Sign In Cheack
    return (accountProvider.user == null) ? const SignInScreen() : 
    
    Scaffold(
      //AppBar
      appBar: AppBar(
        title: Text(_contents[_selectedIndex].contentTitle ,style: MyFont.headlineStyleGreen20),
        backgroundColor: MyFont.backGroundColor,
        foregroundColor: MyFont.primaryColor,
        bottomOpacity: 2.0,
        elevation: 2.0,
      ),

      // Main Contents
      body: SafeArea(
        bottom: false,
        child: _contents[_selectedIndex].content
      ),
      
      // Drawer
      drawer: Drawer(
        width: screenSize.width * 0.7,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: MyFont.primaryColor),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 45.0,
                        height: 45.0,
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
                              Text(accountProvider.user?.displayName ?? '', style: MyFont.headlineStyleWhite20, overflow: TextOverflow.ellipsis),
                              Text(accountProvider.user?.email ?? '', style: MyFont.defaultStyleWhite15, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ),
                    ]
                  )
                ),
              ),
            ),
            for(int index = 0; index < _contents.length; index++)
            ListTile(
              title: Text(_contents[index].contentTitle, style: MyFont.headlineStyleBlack15),
              leading: Icon(_contents[index].contentIcon, color: MyFont.primaryColor, size: 30),
              onTap: () {
                setState(() => _selectedIndex = index);
                Navigator.pop(context);
              },
            ),      
          ],
        ),
      ),
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2,
            spreadRadius: 2,
          ),
        ]),

        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index){
            setState((){
              _selectedIndex = index;
            });
          },
          backgroundColor: MyFont.backGroundColor,
          selectedItemColor: MyFont.primaryColor,
          unselectedItemColor: MyFont.hiddenColor,
          iconSize: 30,
          selectedFontSize: 13,
          unselectedFontSize: 10,
          items: List<BottomNavigationBarItem>.generate(_contents.length, (index) => BottomNavigationBarItem(icon: Icon(_contents[index].contentIcon), label: _contents[index].contentTitle)),
          type: BottomNavigationBarType.fixed
        ),
      ),
    );
  }
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