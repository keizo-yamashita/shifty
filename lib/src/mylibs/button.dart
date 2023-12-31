////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:shift/src/mylibs/style.dart';

////////////////////////////////////////////////////////////////////////////////////////////
///  ページ上部のツールボタン作成に使用 (onPress OnLongPress 2つの関数を使用)
///  OnLongPress に 0.5 秒の検出時間がかかるので，GestureDetector で検出したほうがいいかも
////////////////////////////////////////////////////////////////////////////////////////////

class ToolButton extends StatelessWidget {
  final IconData icon;
  final bool flag;
  final double width;
  final Function? onPressed;
  final Function? onLongPressed;

  const ToolButton({
    Key? key,
    required this.icon,
    required this.flag,
    required this.width,
    this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: SizedBox(
        width: width,
        height: 30,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            shadowColor: MyStyle.hiddenColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: flag ? MyStyle.primaryColor : MyStyle.hiddenColor),
          ),
          onPressed: onPressed as void Function()?,
          onLongPress: onLongPressed as void Function()?,
          child: Align(
              alignment: Alignment.center,
              child: Icon(icon, color: flag ? MyStyle.primaryColor : MyStyle.hiddenColor, size: 20)),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
///  Auto-Fill UI作成に使用するテキストボタンを構築
////////////////////////////////////////////////////////////////////////////////////////////

class CustomTextButton extends StatelessWidget {
  final String text;
  final bool flag;
  final double width;
  final double height;
  final Function action;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.flag,
    required this.width,
    required this.height,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: MyStyle.hiddenColor,
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: flag ? MyStyle.primaryColor : MyStyle.hiddenColor),
        ),
        onPressed: action as void Function()?,
        child: FittedBox(fit: BoxFit.fill, child: Text(text, style: MyStyle.headlineStyleGreen15)),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Icon icon;
  final bool flag;
  final double width;
  final double height;
  final Function action;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.flag,
    required this.width,
    required this.height,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shadowColor: MyStyle.hiddenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: flag ? MyStyle.primaryColor : MyStyle.hiddenColor),
        ),
        onPressed: action as void Function()?,
        child: icon,
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
///  ページ下部の切り替えボタン作成に使用 (onPress OnLongPress 2つの関数を使用)
////////////////////////////////////////////////////////////////////////////////////////////

class BottomButton extends StatelessWidget {
  final Widget content;
  final bool flag;
  final double width;
  final double height;
  final Function? onPressed;
  final Function? onLongPressed;

  const BottomButton({
    Key? key,
    required this.content,
    required this.flag,
    required this.width,
    required this.height,
    this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            shadowColor: MyStyle.hiddenColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: flag ? MyStyle.primaryColor : MyStyle.hiddenColor),
          ),
          onPressed: onPressed as void Function()?,
          onLongPress: onLongPressed as void Function()?,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: content,
          ),
        ),
      ),
    );
  }
}