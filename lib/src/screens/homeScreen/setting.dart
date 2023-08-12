import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/functions/style.dart';
import 'package:shift/src/functions/setting_provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  State<SettingScreen> createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {

  Size _screenSize      = const Size(0, 0);

  @override
  Widget build(BuildContext context) {
    
    var appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    _screenSize      = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - appBarHeight);

    var settingProvider = Provider.of<SettingProvider>(context, listen: false);

    bool enableDarkTheme = settingProvider.enableDarkTheme;
    bool defaultShiftView = settingProvider.defaultShiftView;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: _screenSize.height * 0.05 + appBarHeight / 2),
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
                        settingProvider.enableDarkTheme = result;
                        settingProvider.storePreferences();
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
                        settingProvider.defaultShiftView = result;
                        settingProvider.storePreferences();
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
