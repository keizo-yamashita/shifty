////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/components/form/utility/dialog.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shift/src/screens/signInScreen/link_account.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends ConsumerState<SettingScreen> {

  Size screenSize = const Size(0, 0);

  @override
  Widget build(BuildContext context) {
    
    screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    bool enableDarkTheme = ref.read(settingProvider).enableDarkTheme;
    bool defaultShiftView = ref.read(settingProvider).defaultShiftView;

    return 
    Scaffold(
      body: SafeArea(
        child: SettingsList(
          lightTheme: const SettingsThemeData(
            settingsListBackground: Color(0xFFF2F2F7),
            settingsSectionBackground: Colors.white,
          ),
          sections: [
            SettingsSection(
              title: Text('基本設定', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.color_lens_rounded),
                  title: Text('カラーテーマ', style: Styles.defaultStyle13),
                  value: Text((enableDarkTheme) ? "ダークテーマ" : "ライトテーマ", style: Styles.defaultStyle13),
                  onPressed: (value){
                    setState(() {
                      // ref.read(settingProvider).enableDarkTheme = value;
                      // ref.read(settingProvider).storePreferences();
                    });
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text('デフォルトの画面', style: Styles.defaultStyle13),
                  value: Text((defaultShiftView) ? "管理中のシフト表" : "フォロー中のシフト表", style: Styles.defaultStyle13),
                  onPressed: (value) {
                    setState(() {
                      // ref.read(settingProvider).defaultShiftView = value;
                      // ref.read(settingProvider).storePreferences();
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Text('アカウント', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.person_rounded),
                  title: Text('ユーザ情報', style: Styles.defaultStyle13),
                  onPressed: (context) {
                    context.go('/settings/userInfo');
                  },
                ),
                if (!ref.read(signInProvider).user!.isAnonymous) ... [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.logout_rounded),
                    title: Text('ログアウト', style: Styles.defaultStyle13),
                    onPressed: (context){
                      showConfirmDialog(
                        context,
                        ref,
                        "確認",
                        "ログアウトしますか？\n登録したデータは失われません。",
                        "ログアウトしました。",
                        () {
                          ref.read(signInProvider).logout();
                        },
                        true,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
                    title: Text('ユーザの削除', style: Styles.defaultStyleRed13),
                    onPressed: (context) {
                      showConfirmDialog(
                        context,
                        ref,
                        "確認",
                        "ログアウトしますか？\n登録したデータは失われません。",
                        "ログアウトしました。",
                        () {
                          ref.read(signInProvider).logout();
                        },
                        true,
                      );
                    },
                  ),
                ] else ... [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.login_rounded),
                    title: Text('アカウント連携', style: Styles.defaultStyle13),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const LinkAccountScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text('ゲストユーザの削除', style: Styles.defaultStyleRed13),
                    onPressed: (context) {
                      showConfirmDialog(
                        context,
                        ref,
                        "確認",
                        "ゲストデータを削除しますか？\n登録したデータは全て削除されます。\n管理者である場合、フォロワーのリクエストデータも削除されます。",
                        "ゲストユーザを削除しました。",
                        () {
                          ref.read(signInProvider).deleteUserData().then(
                            (value) {
                              ref.read(signInProvider).deleteUser().then(
                                (error) {
                                  if (error) {
                                    showAlertDialog(
                                      context,
                                      ref,
                                      "エラー",
                                      "ゲストユーザの削除に失敗しました。もう一度お試しく下さい。",
                                      error,
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                        true,
                        true,
                      );
                    },
                  ),
                ]
              ]
            ),
            SettingsSection(
              title: Text('その他', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.email_rounded),
                  title: Text('お問い合わせ / ご要望', style: Styles.defaultStyle13),
                  onPressed:(context) => context.go('/settings/contact'),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.share_rounded),
                  title: Text('アプリを共有する', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.star_rounded),
                  title: Text('レビューを書く', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.document_scanner_rounded),
                  title: Text('利用規約', style: Styles.defaultStyle13),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: Text('プライバシーポリシー', style: Styles.defaultStyle13),
                  onPressed:(context) => context.go('/settings/privacy_policy'),
                ),
                SettingsTile.navigation(
                  trailing:  Text('1.0.0', style: Styles.defaultStyle13),
                  title: Text('バージョン情報', style: Styles.defaultStyle13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
