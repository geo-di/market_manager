import 'package:flutter/material.dart';
import 'constants.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryLightColor,
    primary: kPrimaryLightColor,
    brightness: Brightness.light,
    surface: kAppWhite
  ),
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    elevation: 5,
    shadowColor: Colors.black,
    backgroundColor: kLightAppBarBackground,
    foregroundColor: kAppWhite,
    iconTheme: IconThemeData(
        color: kAppWhite
    ),

  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: kAppBlack
    ),
    bodySmall: TextStyle(
        color: kAppBlack
    ),
  ),
  iconTheme: IconThemeData(
    color: kAppWhite
  )
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryDarkColor,
    primary: kPrimaryDarkColor,
    brightness: Brightness.dark,
    surface: kDarkBackground,
  ),
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    elevation: 5,
    shadowColor: Colors.black,
    backgroundColor: kDarkAppBarBackground,
    foregroundColor: kAppWhite,
    iconTheme: IconThemeData(
        color: kAppWhite
    )
  ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
          color: kAppWhite
      ),
      bodySmall: TextStyle(
        color: kAppWhite
      ),
    ),
    iconTheme: IconThemeData(
        color: kAppWhite
    )
);