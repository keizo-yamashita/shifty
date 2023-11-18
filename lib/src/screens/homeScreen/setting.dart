////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/mylibs/style.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends ConsumerState<SettingScreen> {

  Size _screenSize      = const Size(0, 0);

  @override
  Widget build(BuildContext context) {
    
    var appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    _screenSize      = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - appBarHeight);

    bool enableDarkTheme = ref.read(settingProvider).enableDarkTheme;
    bool defaultShiftView = ref.read(settingProvider).defaultShiftView;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: _screenSize.height * 0.1 + appBarHeight / 2),
              SizedBox(
                width: _screenSize.width * 0.8,
                child: Text("カラーテーマの設定", style: MyStyle.headlineStyle20)
              ),
              SizedBox(
                child: ListTile(
                  title: Text((enableDarkTheme) ? "ダークテーマ" : "ライトテーマ", style: MyStyle.headlineStyle15),
                  leading: CupertinoSwitch(
                    thumbColor: MyStyle.primaryColor,
                    activeColor : MyStyle.primaryColor.withAlpha(100),
                    value: enableDarkTheme,
                    onChanged: (result){
                      setState(() {
                        ref.read(settingProvider).enableDarkTheme = result;
                        ref.read(settingProvider).storePreferences();
                      });
                    },
                  ),
                ),
              ),
              Text("「ライトテーマ」/「ダークテーマ」どちらを使用するか設定します。", style: MyStyle.defaultStyleGrey15),
              
              SizedBox(height: _screenSize.height * 0.05),

              SizedBox(
                width: _screenSize.width * 0.8,
                child: Text("デフォルトで表示するシフト表", style: MyStyle.headlineStyle20)
              ),
              SizedBox(
                child: ListTile(
                  title: Text((defaultShiftView) ? "管理中のシフト表" : "フォロー中のシフト表", style: MyStyle.headlineStyle15),
                  leading: CupertinoSwitch(
                    thumbColor: MyStyle.primaryColor,
                    activeColor : MyStyle.primaryColor.withAlpha(100),
                    value: defaultShiftView,
                    onChanged: (result){
                      setState(() {
                        ref.read(settingProvider).defaultShiftView = result;
                        ref.read(settingProvider).storePreferences();
                      });
                    },
                  ),
                ),
              ),
              Text("「ホーム画面」で「管理中のシフト表」/「フォロー中のシフト表」どちらをデフォルト表示にするか設定します。", style: MyStyle.defaultStyleGrey15),
              Text("シフト表管理者は「管理中のシフト表」を設定することをお勧めします。", style: MyStyle.defaultStyleGrey15)
            ],
          ),
        ),
      ),
    );
  }
}
