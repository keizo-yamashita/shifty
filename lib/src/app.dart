////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/screens/createScreen/add_shift_request.dart';
import 'package:shift/src/screens/signInScreen/sign_in.dart';
import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:google_fonts/google_fonts.dart';
// my file
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/sign_in/sign_in_provider.dart';
import 'package:shift/src/mylibs/deep_link_mixin.dart';

import 'package:shift/src/screens/homeScreen/home.dart';
import 'package:shift/src/screens/homeScreen/account.dart';
import 'package:shift/src/mylibs/setting_provider.dart';
// import 'package:shift/src/screens/homeSCreen/notification.dart';
import 'package:shift/src/screens/homeSCreen/setting.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// App Widget
////////////////////////////////////////////////////////////////////////////////////////////

List<bool> _displayInfoFlag = [false, false];

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);
  @override
  State<AppWidget> createState() => AppWidgetState();
}

class AppWidgetState extends State<AppWidget> with DeepLinkMixin{

  final List<MenuContent> _contents = [
    MenuContent(contentTitle: "ホーム", contentIcon: Icons.home,                            content: const HomeWidget()),
    // MenuContent(contentTitle: "お知らせ",   contentIcon: Icons.notification_important_outlined, content: const NotificationScreen()),
    MenuContent(contentTitle: "アカウント", contentIcon: Icons.person_2,                        content: const AccountScreen()),
    MenuContent(contentTitle: "設定",      contentIcon: Icons.settings,                        content: const SettingScreen()), 
  ];
  
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    checkInitialLink().then((tableId){
      if(tableId != ""){
        Provider.of<DeepLinkProvider>(context).shiftFrameId = tableId;
      }
    });
  }

  /////////////////////////////////////////////////////////////////////////////
  /// build
  /////////////////////////////////////////////////////////////////////////////
  
  @override
  Widget build(BuildContext context) {
    
    var signInProvider = Provider.of<SignInProvider>(context);
    var screenSize     = MediaQuery.of(context).size;
    
    var settingProvider = Provider.of<SettingProvider>(context, listen: false);
    settingProvider.loadPreferences();

    // Sign In Cheack
    return 
    (signInProvider.user != null)
    ? Scaffold(
      //AppBar
      appBar: AppBar(
        title: Text(_contents[_selectedIndex].contentTitle ,style: MyStyle.headlineStyleGreen20),
        bottomOpacity: 2.0,
        actions: [
          if(_selectedIndex == 0)
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton( 
              icon: const Icon(Icons.info_outline, size: 30, color: MyStyle.primaryColor),
              tooltip: "使い方",
              onPressed: () async {
                showInfoDialog(settingProvider.enableDarkTheme);
              }
            ),
          ),
        ],
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,

      // Main Contents
      body: _contents[_selectedIndex].content,

      // Drawer
      drawer: Drawer(
        width: screenSize.shortestSide * 0.7,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: MyStyle.primaryColor),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      (signInProvider.user != null && signInProvider.user!.providerData.isNotEmpty && signInProvider.user!.providerData[0].photoURL != null)
                      ? Container(
                        width: 45.0,
                        height: 45.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: Image.network(signInProvider.user!.providerData[0].photoURL!).image
                          )
                        ),
                      )
                      : Container(
                        width: 45.0,
                        height: 45.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.account_circle_outlined, color: MyStyle.backgroundColor, size: 45),
                      ),
                      Flexible(
                        child: Padding( 
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: (signInProvider.user != null )
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(fit: BoxFit.fitWidth, child: Text((!signInProvider.user!.isAnonymous) ? (signInProvider.user?.providerData[0].displayName ?? signInProvider.user?.uid ?? "") :  "ゲストユーザ", style: MyStyle.headlineStyleWhite20, overflow: TextOverflow.ellipsis)),
                              FittedBox(fit: BoxFit.fitWidth, child: Text((!signInProvider.user!.isAnonymous) ? (signInProvider.user?.providerData[0].email ?? '') : signInProvider.user?.uid ?? "", style: GoogleFonts.mPlus1(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                            ],
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("未ログイン", style: MyStyle.headlineStyleWhite20, overflow: TextOverflow.ellipsis),
                            ],
                          )
                        ),
                      ),
                    ]
                  )
                ),
              ),
            ),
            for(int index = 0; index < _contents.length; index++)
            ListTile(
              title: Text(_contents[index].contentTitle, style: MyStyle.headlineStyle15),
              leading: Icon(_contents[index].contentIcon, color: MyStyle.primaryColor, size: 30),
              onTap: () {
                setState(() => _selectedIndex = index);
                Navigator.pop(context);
              },
            ),      
          ],
        ),
      ),
    )
    : const SignInScreen();
  }

  /////////////////////////////////////////////////////////////////////////////
  /// Deep Link 用関数
  /////////////////////////////////////////////////////////////////////////////
  
  @override
  void onDeepLinkNotify(Uri? uri) {
    String? parameter = uri!.queryParameters['id'];
    if(parameter != null){
      Navigator.push(context, MaterialPageRoute(builder: (c) => AddShiftRequestWidget(tableId: parameter)));
    }
    setState(() {});
  }

  Future<String> checkInitialLink() async{
    String? link = await getInitialLink();
    
    if(link != null){
      Uri uri = Uri.parse(link);
      String? parameter = uri.queryParameters['id'];
      if(parameter != null){
        return parameter;
      }
    }
    return "";
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  ホーム画面の使い方を説明するための関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<int?> showInfoDialog(bool isDarkTheme) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              title: Text("「ホーム画面」の使い方", style:  MyStyle.headlineStyleGreen20, textAlign: TextAlign.center),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.90,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Shift Table Buttons 
                      const SizedBox(height: 20),
                      TextButton(
                            child: _displayInfoFlag[0]
                            ? Text("- 「フォロー中のシフト表」について", style: MyStyle.headlineStyleGreen18)
                            : Text("+「フォロー中のシフト表」について", style: MyStyle.headlineStyleGreen18),
                        onPressed: (){
                          _displayInfoFlag[0] = !_displayInfoFlag[0];
                          setState(() {});
                        },
                      ),

                      if(_displayInfoFlag[0])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // hou to use Followed Shift
                            Text("「フォロー中のシフト表」の一覧が表示されます。", style: MyStyle.defaultStyleGrey13),
                            Text("表示されるカードをタップすることで、「シフトリクエストの入力」/「シフト表の確認」を行うことができます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("追加方法 ①", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("シフト管理者が共有するシフト表フォロー用のURLリンクをタップすることで、追加画面に遷移します。", style: MyStyle.defaultStyleGrey13),
                            Text("「自身の表示名」を入力し、追加ボタンを押すことで追加できます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("追加方法 ②", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("画面右下の「追加ボタン」をタップし、「シフト表をフォローする」を選択することで追加画面に遷移します。", style: MyStyle.defaultStyleGrey13),
                            Text("画面遷移後に、「シフト表のID」及び「自身の表示名」を入力することで追加できます。", style: MyStyle.defaultStyleGrey13),
                            Text("注意 : 「シフト表のID」はシフト管理者に共有してもらう必要があります。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("削除方法", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("カードを長押しすることで、シフト表の「フォロー解除」確認ダイアログが表示されます。", style: MyStyle.defaultStyleGrey13),
                            Text("一度解除すると、フォロー中に登録した内容は全て破棄されます。", style: MyStyle.defaultStyleGrey13),
                            Text("よく確認してから、削除してください。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                      // About Shift Request View 
                      const SizedBox(height: 20),
                      TextButton(
                        child : _displayInfoFlag[1]
                          ? Text("- 「管理中のシフト表」について", style: MyStyle.headlineStyleGreen18)
                          : Text("+「管理中のシフト表」について", style: MyStyle.headlineStyleGreen18),
                        onPressed: (){
                          _displayInfoFlag[1] = !_displayInfoFlag[1];
                          setState(() {});
                        },
                      ),
                      
                      if(_displayInfoFlag[1])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // how to use Managed Shift
                            Text("「管理中のシフト表」の一覧が表示されます。", style: MyStyle.defaultStyleGrey13),
                            Text("表示されるカードをタップすることで、「シフトリクエスト状況の確認」/「シフトの管理」を行うことができます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("追加方法", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("画面右下の「追加ボタン」をタップし、「シフト表を作成する」を選択することでシフト表作成画面に遷移します。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("共有方法", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("カードを長押し、表示されるメニューから「シフト表をSNSで共有する」をタップすることでSNSで共有できます。", style: MyStyle.defaultStyleGrey13),
                            Text("また、「シフト表のIDをコピーする」から「シフト表のID」をコピーし共有することで、シフト表を共有することも可能です。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("削除方法", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("カードを長押し、表示されるメニューから「シフト表を削除する」をタップすることで確認ダイアログが表示されます。", style: MyStyle.defaultStyleGrey13),
                            Text("削除すると、フォロー中のユーザが登録した内容含む全ての登録データが削除されます。", style: MyStyle.defaultStyleGrey13),
                            Text("よく確認してから、削除してください。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('閉じる'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      }
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