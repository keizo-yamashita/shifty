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
  final bool enable;
  final double width;
  final bool  slash;
  final Function? onPressed;
  final Function? onLongPressed;

  const ToolButton({
    Key? key,
    required this.icon,
    required this.enable,
    required this.width,
    this.slash = false,
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
            // backgroundColor: enable ? MyStyle.primaryColor : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(color: enable ? MyStyle.primaryColor: MyStyle.hiddenColor),
          ),
          onPressed: onPressed as void Function()?,
          onLongPress: onLongPressed as void Function()?,
          child:
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: enable ? MyStyle.primaryColor : MyStyle.hiddenColor, size: 20),
              // Icon(icon, color: enable ? Colors.white : MyStyle.hiddenColor, size: 20),
              if(slash)
              SizedBox(
                width: 18, height: 18,
                child: CustomPaint(
                  painter: SlashPainter(
                    lineColor: enable ? MyStyle.primaryColor : Colors.grey,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    downRight: true
                  )
                )
              )
            ],
          ),
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
  final bool enable;
  final double width;
  final double height;
  final Function action;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.enable,
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
            borderRadius: BorderRadius.circular(5),
          ),
          side: BorderSide(color: enable ? MyStyle.primaryColor : MyStyle.hiddenColor),
        ),
        onPressed: action as void Function()?,
        child: FittedBox(fit: BoxFit.fill, child: Text(text, style: MyStyle.headlineStyleGreen15)),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Icon icon;
  final bool enable;
  final double width;
  final double height;
  final Function action;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.enable,
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
            borderRadius: BorderRadius.circular(5),
          ),
          side: BorderSide(color: enable ? MyStyle.primaryColor : MyStyle.hiddenColor),
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
  final bool enable;
  final double width;
  final double height;
  final Function? onPressed;
  final Function? onLongPressed;

  const BottomButton({
    Key? key,
    required this.content,
    required this.enable,
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
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(color: enable ? MyStyle.primaryColor : MyStyle.hiddenColor),
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

/////////////////////////////////////////////////////////////////////////////////
// DiagonalLinePainter Class
// ... 斜線を引くためのクラス
/////////////////////////////////////////////////////////////////////////////////

class SlashPainter extends CustomPainter {
  
  final Color lineColor;
  final Color backgroundColor;
  final bool downRight;

  SlashPainter({
    Color? lineColor,
    Color? backgroundColor,
    bool? downRight,
  })
  : lineColor       = lineColor ?? Colors.grey,
    backgroundColor = backgroundColor ?? Colors.white,
    downRight = downRight ?? true;

  @override
  void paint(Canvas canvas, Size size) {
    
    final paint = Paint();

    paint.color = backgroundColor;
    paint.strokeWidth = 3.5;
    _drawLine(canvas, size, paint);

    paint.color = lineColor;
    paint.strokeWidth = 1.5;
    _drawLine(canvas, size, paint);
  }

  // 線を描画するヘルパーメソッド
  void _drawLine(Canvas canvas, Size size, Paint paint) {
    if(downRight){
      canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    } else {
      canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SlashPainter oldDelegate) {
    return false;
  }
}