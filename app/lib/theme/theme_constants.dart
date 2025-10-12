import 'package:flutter/material.dart';

/* NomNom Theme Constants */
class NomNomThemeConstants {
  static const Color linkBlue = Colors.blue;
  static const double linkIconSize = 16;

  static TextStyle linkTextStyle() {
    return TextStyle(
      color: linkBlue,
      decoration: TextDecoration.underline,
      decorationColor: linkBlue,
    );
  }
}
