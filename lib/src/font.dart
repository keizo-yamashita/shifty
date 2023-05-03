import 'package:flutter/material.dart';

class MyFont{
  static const TextStyle headlineStyleGreen = TextStyle(color: Colors.green, fontSize: 25, fontWeight: FontWeight.bold);
  static const TextStyle headlineStyleWhite = TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold);
  static const TextStyle commentStyle = TextStyle(color: Colors.grey, fontSize: 15);
  static const Color tableColumnsColor = Color.fromARGB(255, 218, 255, 208);
  static const Color tableBorderColor = Color.fromARGB(255, 0, 198, 0);
  static const TextHeightBehavior defaultBehavior = TextHeightBehavior(applyHeightToLastDescent: false, applyHeightToFirstAscent: false);
}