import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.lightBlueAccent,
    primary: Colors.lightBlueAccent,
    brightness: Brightness.light,
    surface: Color(0xFFF5F5F5)
  ),
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    elevation: 5,
    shadowColor: Colors.black,
    backgroundColor: Color(0xFF1976D2),
    foregroundColor: Color(0xFFF5F5F5),

  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Color(0xFFF5F5F5)
    )
  ),
  iconTheme: IconThemeData(
    color: Color(0xFFF5F5F5)
  )
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent.shade700,
    primary: Colors.blueAccent.shade700,
    brightness: Brightness.dark,
    surface: Color(0xFF0A0E21),
  ),
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    elevation: 5,
    shadowColor: Colors.black,
    backgroundColor: Color(0xFF1E1E1E),
  ),
);