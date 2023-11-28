////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:shift/src/mylibs/style.dart';

////////////////////////////////////////////////////////////////////////////////////////////
///  ページ上部のツールボタン作成に使用 (onPress OnLongPress 2つの関数を使用)
///  OnLongPress に 0.5 秒の検出時間がかかるので，GestureDetector で検出したほうがいいかも
////////////////////////////////////////////////////////////////////////////////////////////

Widget buildToolButton(IconData icon, bool flag, double width, Function onPressed, Function onLongPressed){
  
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
          side: BorderSide(color: (flag) ? MyStyle.primaryColor : MyStyle.hiddenColor),
        ),
        onPressed: (){ 
          onPressed();
        },
        onLongPress: (){
          onLongPressed();
        },
        child: Align(alignment: Alignment.center, child: Icon(icon, color: (flag) ? MyStyle.primaryColor : MyStyle.hiddenColor, size: 20))
      ),
    ),
  );
}

////////////////////////////////////////////////////////////////////////////////////////////
///  Auto-Fill UI作成に使用するテキストボタンを構築
////////////////////////////////////////////////////////////////////////////////////////////

Widget buildTextButton(String text, bool flag, double width, double height, Function action){
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
        side: BorderSide(color: (flag) ? MyStyle.primaryColor : MyStyle.hiddenColor),
      ),
      onPressed: (){ 
          action();
      },
      child: FittedBox(fit: BoxFit.fill, child: Text(text, style: MyStyle.headlineStyleGreen15))
    ),
  );
}

Widget buildIconButton(Icon icon, bool flag, double width, double height, Function action){
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
        side: BorderSide(color: (flag) ? MyStyle.primaryColor : MyStyle.hiddenColor),
      ),
      onPressed: (){ 
          action();
      },
      child: icon
    ),
  );
}

////////////////////////////////////////////////////////////////////////////////////////////
///  ページ下部の切り替えボタン作成に使用 (onPress OnLongPress 2つの関数を使用)
////////////////////////////////////////////////////////////////////////////////////////////

Widget buildBottomButton(Widget content, bool flag, Function onPressed, Function onLongPressed){
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: SizedBox(
      // width: _screenSize.width / 3,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shadowColor: MyStyle.hiddenColor, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: (flag) ? MyStyle.primaryColor : MyStyle.hiddenColor),
        ),
        onPressed: (){ 
          onPressed();
        },
        onLongPress: (){
          onLongPressed();
        },
        child: content
      ),
    ),
  );
}