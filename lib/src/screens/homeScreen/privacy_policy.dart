////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webviewx/webviewx.dart';

// my package
import 'package:shift/main.dart';

class PrivacyPolicyPage extends ConsumerStatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);
  @override
  PrivacyPolicyPageState createState() => PrivacyPolicyPageState();
}

class PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {

  Size screenSize = const Size(0, 0);

  late WebViewXController webviewController;
  //Size get screenSize => MediaQuery.of(context).size;

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    bool enableDarkTheme = ref.read(settingProvider).enableDarkTheme;
    bool defaultShiftView = ref.read(settingProvider).defaultShiftView;

    return 
    Scaffold(
      body: SafeArea(
        child: WebViewX(
          key: const ValueKey('webviewx'),
          initialContent: 'https://kaku-panda.github.io/shifty/privacy_and_policy.html',
          initialSourceType: SourceType.html,
          height: 500,//サイズは適当
          width: 500,//サイズは適当
          onWebViewCreated: (controller) => webviewController = controller,
        )
      ),
    );
  }
}
