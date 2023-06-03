import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyFont{
  static TextStyle headlineStyleGreen20 = GoogleFonts.mPlus1(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold);
  static TextStyle headlineStyleWhite20 = GoogleFonts.mPlus1(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  static TextStyle headlineStyleBlack20 = GoogleFonts.mPlus1(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);
  static TextStyle headlineStyleGreen15 = GoogleFonts.mPlus1(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold);
  static TextStyle headlineStyleWhite15 = GoogleFonts.mPlus1(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold);
  static TextStyle headlineStyleBlack15 = GoogleFonts.mPlus1(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

  static TextStyle defaultStyleGrey15   = GoogleFonts.mPlus1(color: Colors.grey,  fontSize: 15, fontWeight: FontWeight.bold);
  static TextStyle defaultStyleBlack15  = GoogleFonts.mPlus1(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
  static TextStyle defaultStyleWhite15  = GoogleFonts.mPlus1(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold);
  static TextStyle defaultStyleGrey13   = GoogleFonts.mPlus1(color: Colors.grey,  fontSize: 13, fontWeight: FontWeight.bold, height: 0.8);
  static TextStyle defaultStyleBlack13  = GoogleFonts.mPlus1(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold, height: 0.8);
  static TextStyle defaultStyleWhite13  = GoogleFonts.mPlus1(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold);
  static TextStyle defaultStyleGrey10   = GoogleFonts.mPlus1(color: Colors.grey,  fontSize: 9,  fontWeight: FontWeight.bold);
  static TextStyle defaultStyleBlack10  = GoogleFonts.mPlus1(color: Colors.black, fontSize: 9,  fontWeight: FontWeight.bold);
  static TextStyle defaultStyleWhite10  = GoogleFonts.mPlus1(color: Colors.white, fontSize: 9,  fontWeight: FontWeight.bold);
  static TextStyle defaultStyleRed10    = GoogleFonts.mPlus1(color: Colors.red,   fontSize: 9,  fontWeight: FontWeight.bold);
  static TextStyle defaultStyleBlue10   = GoogleFonts.mPlus1(color: Colors.blue,  fontSize: 9,  fontWeight: FontWeight.bold);
  
  static const Color tableColumnsColor = Color.fromARGB(255, 218, 255, 208);
  static const Color tableBorderColor = Color.fromARGB(255, 0, 198, 0);
  static const TextHeightBehavior defaultBehavior = TextHeightBehavior(applyHeightToLastDescent: false, applyHeightToFirstAscent: false);
}