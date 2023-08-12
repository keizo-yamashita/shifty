import 'package:flutter/material.dart';
import 'package:shift/src/functions/style.dart';

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
    constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
    builder: (BuildContext context) {
      return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * height,
            width: MediaQuery.of(context).size.width,
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * height - MediaQuery.of(context).padding.bottom - 23,
                  width: MediaQuery.of(context).size.width,
                  child: child
                )
              ],
            )
          ),
        )
      );
    }
  );
}

Widget buildModalWindowContainer(BuildContext context,  list, double height, Function(BuildContext, int) onTapped, {Text? title, bool? fadeout}){
  return Column(
    children: [
      if(title != null)
      SizedBox(
        height: 50,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index){
            return ListTile(
              title: title,
              onTap: (){
                Navigator.of(context).pop();
              },
            );
          }
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height * height - MediaQuery.of(context).padding.bottom - 23 - 50,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [            
                ListTile(
                  title: (list.runtimeType == List<String>) ? Text(list[index], style: MyStyle.headlineStyle15,textAlign: TextAlign.center) : list[index],
                  onTap: () {
                    onTapped(context, index);
                    if(fadeout == null || fadeout == true){
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const Divider(thickness: 2)
              ],
            );
          },
        ),
      ),
    ],
  );
}