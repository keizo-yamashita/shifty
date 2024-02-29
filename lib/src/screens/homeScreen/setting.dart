////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share/share.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/components/form/utility/dialog.dart';
import 'package:shift/src/components/form/utility/modal_window.dart';
import 'package:shift/src/components/style/style.dart';


class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends ConsumerState<SettingScreen> {
  Size screenSize = const Size(0, 0);

  @override
  Widget build(BuildContext context) {
    screenSize = Size(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    bool enableDarkTheme = ref.watch(settingProvider).enableDarkTheme;
    bool defaultShiftView = ref.watch(settingProvider).defaultShiftView;

    Future<String> getVersionInfo() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      var text = packageInfo.version;
      return text;
    }

    return SafeArea(
        child: SettingsList(
          lightTheme: const SettingsThemeData(
            settingsListBackground: Styles.lightBgColor,
            settingsSectionBackground: Styles.lightColor,
          ),
          darkTheme: const SettingsThemeData(
            settingsListBackground: Styles.darkBgColor,
            settingsSectionBackground: Styles.darkColor,
          ),
          sections: [
            SettingsSection(
              title: Text('基本設定', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: Icon(
                    (enableDarkTheme) ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: Text('カラーテーマ', style: Styles.defaultStyle13),
                  value: Text(
                    (enableDarkTheme) ? "ダークテーマ" : "ライトテーマ",
                    style: Styles.defaultStyle13,
                  ),
                  onPressed: (value) {
                    setState(
                      () {
                        showModalWindow(
                          context,
                          0.5,
                          buildModalWindowContainer(
                            context,
                            [
                              Text(
                                "ライトテーマ",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "ダークテーマ",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            0.5,
                            (BuildContext context, int index) {
                              setState(() {});
                              ref.read(settingProvider).enableDarkTheme =
                                  index == 1 ? true : false;
                              ref.read(settingProvider).storePreferences();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text('デフォルトの画面', style: Styles.defaultStyle13),
                  value: Text(
                    (defaultShiftView) ? "管理中のシフト表" : "フォロー中のシフト表",
                    style: Styles.defaultStyle13,
                  ),
                  onPressed: (value) {
                    setState(
                      () {
                        showModalWindow(
                          context,
                          0.5,
                          buildModalWindowContainer(
                            context,
                            [
                              Text(
                                "フォロー中のシフト表",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "管理中のシフト表",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            0.5,
                            (BuildContext context, int index) {
                              setState(() {});
                              ref.read(settingProvider).defaultShiftView =
                                  index == 1 ? true : false;
                              ref.read(settingProvider).storePreferences();
                            },
                          ),
                        );
                      },
                    );
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
                if (!ref.read(signInProvider).user!.isAnonymous) ...[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.logout_rounded),
                    title: Text('ログアウト', style: Styles.defaultStyle13),
                    onPressed: (context) {
                      showConfirmDialog(
                        context: context,
                        ref: ref,
                        title: "確認",
                        message1: "ログアウトしますか？\n登録したデータは失われません。",
                        message2: "ログアウトしました。",
                        onAccept: () {
                          ref.read(signInProvider).logout().then(
                            (_) => context.go('/signin'),
                          );
                        },
                        confirm: true,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.red,
                    ),
                    title: Text('ユーザの削除', style: Styles.defaultStyleRed13),
                    onPressed: (context) {
                      showConfirmDialog(
                        context: context,
                        ref: ref,
                        title: "確認",
                        message1: "アカウントを削除しますか？\n登録したデータは全て削除されます。\n管理者である場合、フォロワーのリクエストデータも削除されます。",
                        message2: "アカウントを削除しました。",
                        onAccept: () {
                          ref.read(signInProvider).deleteUserData().then(
                            (value) {
                              ref.read(signInProvider).deleteUser().then(
                                (error) {
                                  if (error) {
                                    showAlertDialog(
                                      context,
                                      ref,
                                      "エラー",
                                      "アカウントの削除に失敗しました。もう一度お試しく下さい。",
                                      error,
                                    );
                                  }else{
                                    context.go('/signin');
                                  }
                                }
                              );
                            },
                          );
                        },
                        confirm: true,
                        error: true,
                      );
                    },
                  ),
                ] else ...[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.login_rounded),
                    title: Text('アカウント連携', style: Styles.defaultStyle13),
                    onPressed: (context) {
                      context.go('/settings/link_account');
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text('ゲストユーザの削除', style: Styles.defaultStyleRed13),
                    onPressed: (context) {
                      showConfirmDialog(
                        context: context,
                        ref: ref,
                        title: "確認",
                        message1: "ゲストユーザを削除しますか？\n登録したデータは全て削除されます。\n管理者である場合、フォロワーのリクエストデータも削除されます。",
                        message2: "ゲストユーザを削除しました。",
                        onAccept: () {
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
                                  }else{
                                    context.go('/signin');
                                  }
                                },
                              );
                            },
                          );
                        },
                        confirm: true,
                        error: true,
                      );
                    },
                  ),
                ]
              ],
            ),
            SettingsSection(
              title: Text('その他', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.email_rounded),
                  title: Text('お問い合わせ / ご要望', style: Styles.defaultStyle13),
                  onPressed: (context) => context.go('/settings/contact'),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.share_rounded),
                  title: Text('アプリを共有する', style: Styles.defaultStyle13),
                  onPressed: (context) {
                    var message = "Shifty\n\n↓↓インストールはこちらから↓↓\n\n";
                    message +=
                        "iOS : https://apps.apple.com/jp/app/shifty-%E3%82%B7%E3%83%95%E3%83%88%E8%A1%A8%E4%BD%9C%E6%88%90%E3%82%A2%E3%83%97%E3%83%AA/id6458593130 \n\n";
                    message +=
                        "Android : https://play.google.com/store/apps/details?id=com.kakupan.shift&pcampaignid=web_share \n";
                    Share.share(message);
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.star_rounded),
                  title: Text('レビューを書く', style: Styles.defaultStyle13),
                  onPressed: (context) {
                    DrawerHelper.launchStoreReview(context);
                  }
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.document_scanner_rounded),
                  title: Text('利用規約', style: Styles.defaultStyle13),
                  onPressed: (context) =>
                      context.go('/settings/privacy_policy'),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: Text('プライバシーポリシー', style: Styles.defaultStyle13),
                  onPressed: (context) =>
                      context.go('/settings/privacy_policy'),
                ),
                SettingsTile.navigation(
                  trailing: FutureBuilder<String>(
                    future: getVersionInfo(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Text(
                        snapshot.hasData ? snapshot.data : '',
                        style: Styles.defaultStyle13,
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  title: Text('バージョン情報', style: Styles.defaultStyle13),
                ),
              ],
            ),
          ],
        ),
      
    );
  }
}

class DrawerHelper {
  static final InAppReview _inAppReview = InAppReview.instance;

  // URLを定数化
  static const String _urlAppStore = 'https://apps.apple.com/jp/app/shifty-%E3%82%B7%E3%83%95%E3%83%88%E8%A1%A8%E4%BD%9C%E6%88%90%E3%82%A2%E3%83%97%E3%83%AA/id6458593130';
  static const String _urlPlayStore = 'https://play.google.com/store/apps/details?id=com.kakupan.shift&pcampaignid=web_share';

  static void launchStoreReview(BuildContext context) async {
    try {
      if (await _inAppReview.isAvailable()) {
        _inAppReview.requestReview();
      } else {
        // ストアのURLにフォールバック
        final url = Platform.isIOS ? _urlAppStore : _urlPlayStore;

        if (!await launchUrl(Uri.parse(url))) {
          throw 'Cannot launch the store URL';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ストアページを開けませんでした')),
      );
    }
  }
}
