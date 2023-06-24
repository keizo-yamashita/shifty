import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// my file
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/google_login_provider.dart';
import 'package:shift/src/screens/sign_in.dart';
import 'package:shift/src/functions/deep_link_mixin.dart';
import 'package:shift/src/screens/home.dart';
import 'package:shift/src/screens/account.dart';
import 'package:shift/src/screens/notification.dart';
import 'package:shift/src/screens/setting.dart';
import 'package:shift/src/screens/createScreen/create_shift_table.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);
  @override
  State<AppWidget> createState() => AppWidgetState();
}

class AppWidgetState extends State<AppWidget> with DeepLinkMixin{

  final List<MenuContent> _contents = [
    MenuContent(contentTitle: "マイシフト", contentIcon: Icons.home,                            content: const HomeWidget()),
    MenuContent(contentTitle: "お知らせ",     contentIcon: Icons.notification_important_outlined, content: const NotificationScreen()),
    MenuContent(contentTitle: "アカウント",   contentIcon: Icons.person_2,                        content: const AccountScreen()),
    MenuContent(contentTitle: "設定",         contentIcon: Icons.settings,                        content: const HomeScreen()), 
  ];
  
  int _selectedIndex = 0;

  String? catchLink;
  String? parameter;
  

  /////////////////////////////////////////////////////////////////////////////
  /// Deep Link 用関数
  /////////////////////////////////////////////////////////////////////////////
  @override
  void onDeepLinkNotify(Uri? uri) {
    final link = uri.toString();
    catchLink = link;
    parameter = getQueryParameter(link);
    if(parameter != null){
      Navigator.push( context, MaterialPageRoute(builder: (context) => const CreateShiftTableWidget()));
    }
    setState(() {});
  }

  String? getQueryParameter(String? link) {
    if (link == null) return null;
    final uri = Uri.parse(link);
    String? tableId = uri.queryParameters['id'];
    return tableId;
  }

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
        backgroundColor: MyFont.backgroundColor.withOpacity(0.9),
        foregroundColor: MyFont.primaryColor,
        bottomOpacity: 2.0,
        elevation: 2.0,
      ),

      extendBody: true,
      extendBodyBehindAppBar: true,

      // Main Contents
      body: _contents[_selectedIndex].content,

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
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index){
          setState((){
            _selectedIndex = index;
          });
        },
        backgroundColor: MyFont.backgroundColor.withOpacity(0.9),
        selectedItemColor: MyFont.primaryColor,
        unselectedItemColor: MyFont.hiddenColor,
        iconSize: 30,
        selectedFontSize: 13,
        unselectedFontSize: 10,
        items: List<BottomNavigationBarItem>.generate(_contents.length, (index) => BottomNavigationBarItem(icon: Icon(_contents[index].contentIcon), label: _contents[index].contentTitle)),
        type: BottomNavigationBarType.fixed
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