// Flutter imports:
import 'package:flutter/material.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyAppBar({
    Key? key,
    this.trailingWidget,
  }) : super(key: key);

  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(0.0);
}
