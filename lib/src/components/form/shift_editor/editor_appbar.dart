import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift/src/components/form/utility/dialog.dart';
import 'package:shift/src/components/style/style.dart';

class EditorAppBar extends StatelessWidget {
  final BuildContext context;
  final WidgetRef ref;
  final bool registered;
  final String title;
  final Function? handleInfo;
  final Function? handleRegister;
  final Widget content;

  const EditorAppBar({
    Key? key,
    required this.context,
    required this.ref,
    required this.registered,
    required this.title,
    this.handleInfo,
    this.handleRegister,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        if (registered) {
          navigator.pop();
        } else {
          final bool shouldPop = await showConfirmDialog(
            context,
            ref,
            "注意",
            "データが保存されていません。\n未登録のデータは破棄されます。",
            "",
            () {},
            false,
            true,
          );
          if (shouldPop) {
            navigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.fill,
            child: Text(title, style: Styles.defaultStyleGreen20),
          ),
          bottomOpacity: 2.0,
          elevation: 2.0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  size: 30,
                  color: Styles.primaryColor,
                ),
                tooltip: "使い方",
                onPressed: () async {
                  handleInfo?.call();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 30,
                  color: Styles.primaryColor,
                ),
                tooltip: "登録する",
                onPressed: () {
                  handleRegister?.call();
                },
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: content,
      ),
    );
  }
}
