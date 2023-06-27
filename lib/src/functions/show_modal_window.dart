import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:shift/src/functions/font.dart';

//////////////////////////////////////////////////////////////////////
/// Show Modal Window
/// Contain Child Widget : child is usually create by buildModalWindowCointainer method.
//////////////////////////////////////////////////////////////////////

Future<dynamic> showModalWindow(BuildContext context, double height, Widget child){
  return showModalBottomSheet(
    useRootNavigator: true,
    //モーダルの背景の色、透過
    backgroundColor: Colors.transparent,
    //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * height,
            width: double.maxFinite,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 10),
                child
              ],
            )
          ),
        )
      );
    }
  );
}

//////////////////////////////////////////////////////////////////////
/// Show Modal Window for Cupertino
/// Contain Child Widget : child is usually create build list method.
//////////////////////////////////////////////////////////////////////

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

Widget buildModalWindowContainer(double height, List list, Function(BuildContext, int) onTapped){
    return SizedBox(
      height: height,
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                title: (list.runtimeType == List<String>) ? Text(list[index], style: MyFont.headlineStyleBlack15,textAlign: TextAlign.center) : list[index],
                onTap: () {
                  onTapped(context, index);
                  Navigator.of(context).pop();
                },
              ),
              const Divider(thickness: 2)
            ],
          );
        },
      ),
    );
}