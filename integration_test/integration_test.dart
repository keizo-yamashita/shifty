import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shift/firebase_options.dart';
import 'package:shift/main.dart';
import 'package:shift/src/app_router.dart';

import 'package:shift/src/components/deep_link_mixin.dart';
import 'package:shift/src/components/sign_in/sign_in_provider.dart';
import 'package:shift/src/components/shift/shift_provider.dart';
import 'package:shift/src/components/setting_provider.dart';

final signInProvider       = ChangeNotifierProvider((ref) => SignInProvider());
final settingProvider      = ChangeNotifierProvider((ref) => SettingProvider());
final shiftFrameProvider   = ChangeNotifierProvider((ref) => ShiftFrameProvider());
final shiftRequestProvider = ChangeNotifierProvider((ref) => ShiftRequestProvider());
final shiftTableProvider   = ChangeNotifierProvider((ref) => ShiftTableProvider());
final deepLinkProvider     = ChangeNotifierProvider((ref) => DeepLinkProvider());

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('How to Use', 
    (WidgetTester tester) async {

    // Firebaseの初期化
    print("Firebase の初期化");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    print("起動");
    await tester.pumpWidget(
      const ProviderScope(child: MyApp())
    );
   
    print("2秒待つ");
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    ///////////////////////////////////////////////////
    /// ゲストユーザとしてログイン
    ///////////////////////////////////////////////////

    print("ログイン画面が開いていることを確認");
    expect(find.byType(AppRouterWidget), findsOneWidget);
    expect(find.text('Shifty へようこそ'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    print("ゲストログインボタンをタップ");
    var guestLoginButton = find.text('ゲストログイン');
    expect(guestLoginButton, findsOneWidget);
    await tester.tap(guestLoginButton);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    print("OKをタップ");
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    print("OKをタップ");
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    ///////////////////////////////////////////////////
    /// シフト表の作成
    ///////////////////////////////////////////////////
    // + ボタンを押す
    print("+を開く");
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    //"シフト表を作成する"をタップ
    await tester.tap(find.text("シフト表を作成する"));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // シフト名の入力
    await tester.enterText(find.byType(TextField), '12月シフト表');
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // キーボードを閉じる
    await tester.tapAt(const Offset(0, 500)); // 上から下へスクロール
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 下方向にスクロール
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500)); // 上から下へスクロール
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    //　入力をクリック
    await tester.tap(find.text("入力"));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 下方向にスクロール
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500)); // 上から下へスクロール
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 次の画面に遷移
    await tester.tap(find.byIcon(Icons.navigate_next_outlined));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 登録
    await tester.tap(find.byIcon(Icons.cloud_upload_outlined));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    print("OKをタップ");
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    ///////////////////////////////////////////////////
    /// ゲストユーザ削除
    ///////////////////////////////////////////////////
    
    print("ナビゲーション メニューを開く");
    await tester.tap(find.byTooltip('ナビゲーション メニューを開く'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    print("アカウントをタップ");
    var accountButton = find.text('アカウント');
    expect(accountButton, findsOneWidget);
    await tester.tap(accountButton);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    
    print("アカウント削除をタップ");
    var accountDeleteButton = find.text('ゲストユーザの削除');
    expect(accountDeleteButton, findsOneWidget);
    await tester.tap(accountDeleteButton);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    print("OKをタップ");
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    print("OKをタップ");
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}