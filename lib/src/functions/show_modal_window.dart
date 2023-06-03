import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Future<dynamic> showModalWindow(BuildContext context, Widget child){
  return showModalBottomSheet(
    useRootNavigator: true,
    //モーダルの背景の色、透過
    backgroundColor: Colors.transparent,
    //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: child,
      );
    }
  );
}

Future<dynamic> showModalWindowCupertino(BuildContext context, Widget child, double height){
  return showCupertinoModalPopup(
    context: context,
    builder: (_) => Container(
      height: height,
      color: CupertinoColors.white,
      child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.maxFinite,
      child: Material(
        child: child
      ),
    )
    )
  );
}