////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shift/src/screens/homeScreen/suggest.dart';
import 'package:uni_links/uni_links.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shift/main.dart';
import 'package:shift/src/screens/createScreen/add_shift_request.dart';
import 'package:shift/src/screens/signInScreen/sign_in.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/deep_link_mixin.dart';
import 'package:shift/src/screens/homeScreen/home.dart';
import 'package:shift/src/screens/homeScreen/account.dart';
import 'package:shift/src/screens/homeSCreen/setting.dart';
// import 'package:shift/src/screens/homeSCreen/notification.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// App Widget
////////////////////////////////////////////////////////////////////////////////////////////

List<bool> _displayInfoFlag = [true, true];

class AppWidget extends ConsumerStatefulWidget {
  const AppWidget({Key? key}) : super(key: key);
  @override
  AppWidgetState createState() => AppWidgetState();
}

class AppWidgetState extends ConsumerState<AppWidget> with DeepLinkMixin{

  final List<MenuContent> _contents = [
    MenuContent(contentTitle: "ホーム",    contentIcon: Icons.home,              content: const HomeWidget()),
    MenuContent(contentTitle: "アカウント", contentIcon: Icons.person_2,          content: const AccountScreen()),
    MenuContent(contentTitle: "ご要望",     contentIcon: Icons.sms_failed,       content: const SuggestionBoxScreen()), 
    MenuContent(contentTitle: "設定",      contentIcon: Icons.settings,          content: const SettingScreen()), 
    // MenuContent(contentTitle: "お知らせ",   contentIcon: Icons.notification_important_outlined, content: const NotificationScreen()),
  ];
  
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    checkInitialLink().then((tableId){
      if(tableId != ""){
        ref.read(deepLinkProvider).shiftFrameId = tableId;
      }
    });
  }

  /////////////////////////////////////////////////////////////////////////////
  /// build
  /////////////////////////////////////////////////////////////////////////////
  
  @override
  Widget build(BuildContext context) {
    
    var screenSize = MediaQuery.of(context).size;
    
    ref.read(settingProvider).loadPreferences();

    // Sign In Cheack
    return 
    (ref.watch(signInProvider).user != null) ? Scaffold(
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
                  showInfoDialog(ref.read(settingProvider).enableDarkTheme);
                }
              ),
            ),
          ],
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
      
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
                        (ref.read(signInProvider).user != null && ref.read(signInProvider).user!.providerData.isNotEmpty && ref.read(signInProvider).user!.providerData[0].photoURL != null)
                        ? Container(
                          width: 45.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: Image.network(ref.read(signInProvider).user!.providerData[0].photoURL!).image
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
                            child: (ref.read(signInProvider).user != null )
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(fit: BoxFit.fitWidth, child: Text((!ref.read(signInProvider).user!.isAnonymous) ? (ref.read(signInProvider).user?.providerData[0].displayName ?? ref.read(signInProvider).user?.uid ?? "") :  "ゲストユーザ", style: MyStyle.headlineStyleWhite20, overflow: TextOverflow.ellipsis)),
                                FittedBox(fit: BoxFit.fitWidth, child: Text((!ref.read(signInProvider).user!.isAnonymous) ? (ref.read(signInProvider).user?.providerData[0].email ?? '') : ref.read(signInProvider).user?.uid ?? "", style: GoogleFonts.mPlus1(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
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
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              title: Text("「ホーム画面」の使い方", style:  MyStyle.headlineStyleGreen20, textAlign: TextAlign.center),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.95,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextButton(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                              child : _displayInfoFlag[0] ? Text("-", style: MyStyle.headlineStyleGreen18) : Text("+", style: MyStyle.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("「管理中のシフト表」について", style: MyStyle.headlineStyleGreen18),
                          ],
                        ),
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
                            // how to use Managed Shift
                            Text("「管理中のシフト表」の一覧が表示されます。", style: MyStyle.defaultStyleGrey13),
                            Text("表示されるカードをタップすることで「シフトリクエストの確認」「シフトの管理」を行うことができます。", style: MyStyle.defaultStyleGrey13),
                            Text("シフト管理者としてシフト表を作成したい場合、下記の手順に従って下さい。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("1. シフト表の作成", style: MyStyle.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("管理者としてシフト表を作成します。", style: MyStyle.defaultStyleGrey13),
                            Text("画面遷移後「シフト表作成画面」より参照して下さい。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset("assets/how_to_use/home_1.png"),
                                  Image.asset("assets/how_to_use/home_2.png"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("2. シフト表の共有", style: MyStyle.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("フォロワーにシフト表を共有します。", style: MyStyle.defaultStyleGrey13),
                            Text("共有リンクからアプリを開くには事前のアプリインストールが必要です。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("共有リンクから管理者もフォロワーとして登録することができます。", style: MyStyle.defaultStyleGrey13),
                            Text("※ 一度、管理者自身がリンクからシフトリクエストを入力し、テストしてみることをお勧めします。", style: MyStyle.defaultStyleRed13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset("assets/how_to_use/home_3.png"),
                                  Image.asset("assets/how_to_use/home_4.png"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("3. シフト表の管理", style: MyStyle.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("管理者としてシフト表を管理します。", style: MyStyle.defaultStyleGrey13),
                            Text("画面遷移後「シフト管理画面」より参照して下さい。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/home_5.png"),
                            ),
                            Text("4. シフト表の削除", style: MyStyle.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("誤ったシフト表やシフト期間が満了したシフト表は削除しましょう。", style: MyStyle.defaultStyleGrey13),
                            Text("削除すると、フォロワーが登録した内容含む全ての登録データが削除されます。", style: MyStyle.defaultStyleGrey13),
                            Text("よく確認してから、削除して下さい。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/home_6.png"),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                              child : _displayInfoFlag[1] ? Text("-", style: MyStyle.headlineStyleGreen18) : Text("+", style: MyStyle.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("「フォロー中のシフト表」について", style: MyStyle.headlineStyleGreen18),
                          ],
                        ),
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
                            // hou to use Followed Shift
                            Text("「フォロー中のシフト表」の一覧が表示されます。", style: MyStyle.defaultStyleGrey13),
                            Text("表示されるカードをタップすることで「シフトリクエストの入力」「シフト表の確認」を行うことができます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("1. シフト表のフォロー", style: MyStyle.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("シフト表管理者が共有する共有リンクをタップすることで、フォロー画面に遷移します。", style: MyStyle.defaultStyleGrey13),
                            Text("※ 共有リンクからアプリを開くには事前のアプリインストールが必要です。", style: MyStyle.defaultStyleRed13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset("assets/how_to_use/home_7.png"),
                                  Image.asset("assets/how_to_use/home_8.png"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("2. 「シフトリクエストの入力」/「シフトの確認」", style: MyStyle.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("カードをタップすることで画面遷移します  。", style: MyStyle.defaultStyleGrey13),
                            Text("「シフトリクエストの入力」は「リクエスト期間」でのみ行えます。", style: MyStyle.defaultStyleGrey13),
                            Text("「シフトの確認」は「リクエスト期間終了後」にのみ行えます。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/home_9.png"),
                            ),
                            const SizedBox(height: 10),
                            Text("3. フォローの解除", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("一度フォローを解除すると、フォロー中に登録した内容は全て破棄されます。", style: MyStyle.defaultStyleGrey13),
                            Text("よく確認してから、削除してください。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/home_10.png"),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      )
                    ],
                  )
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('閉じる', style: MyStyle.headlineStyleGreen13),
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