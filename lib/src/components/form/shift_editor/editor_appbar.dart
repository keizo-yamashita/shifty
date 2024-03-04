import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift/src/components/form/utility/dialog.dart';
import 'package:shift/src/components/style/style.dart';

class EditorAppBar extends StatelessWidget {
  final BuildContext context;
  final WidgetRef ref;
  final bool isEditting;
  final String title;
  final String subtitle;
  final Function? handleInfo;
  final Function? handleRegister;
  final Widget content;

  const EditorAppBar({
    Key? key,
    required this.context,
    required this.ref,
    required this.isEditting,
    required this.title,
    required this.subtitle,
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
        if (!isEditting) {
          navigator.pop();
        } else {
          final bool shouldPop = await showConfirmDialog(
            context: context,
            ref: ref,
            title: "注意",
            message1: "データが保存されていません。\n未登録のデータは破棄されます。",
            message2: "",
            onAccept: (){},
            confirm: false,
            error: true,
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
            child: Column(
              children: [
                Text(subtitle, style: Styles.defaultStyle13),
                Text(title, style: Styles.defaultStyle18),
              ],
            ),
          ),
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
