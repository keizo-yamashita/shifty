////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:shift/components/style/style.dart';

class PrivacyPolicyPage extends ConsumerStatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);
  @override
  PrivacyPolicyPageState createState() => PrivacyPolicyPageState();
}

class PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
  Size screenSize = const Size(0, 0);

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(
                color: Styles.primaryColor,
              ),
            ),
          );
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(
      Uri.parse(
        'https://kaku-panda.github.io/shifty/privacy_and_policy.html',
      ),
    );

  @override
  Widget build(BuildContext context) {
    screenSize = Size(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
