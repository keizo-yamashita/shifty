import 'package:integration_test/integration_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shift/main.dart' as app;
import 'package:shift/src/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashScreen navigates to AppWidget after 2 seconds', 
    (WidgetTester tester) async {
    
    app.main(); // アプリケーションを起動します
    await tester.pumpAndSettle();

    // 2秒待ちます
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // AppWidgetが表示されているかを確認します
    expect(find.byType(AppWidget), findsOneWidget);

    // ログイン画面に遷移していることを確認    
    expect(find.text('Shifty へようこそ'), findsOneWidget);

    // ゲストログインボタンをタップ
    await tester.tap(find.text('ゲストログイン'));
    await tester.pumpAndSettle();

    // 1つ目の確認ダイアログ
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 2つ目の確認ダイアログ
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 新しい画面が表示されたかどうかを確認します
    // expect(find.byType(HomeWidget), findsOneWidget);
  });
}