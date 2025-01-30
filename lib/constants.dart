import 'package:flutter/material.dart';

final kPrimaryLightColor = Colors.lightBlueAccent;
final kPrimaryDarkColor = Colors.blueAccent.shade400;
final kAppWhite = Color(0xFFF5F5F5);
final kLightAppBarBackground = Color(0xFF1976D2);
final kDarkBackground = Color(0xFF0A0E21);
final kDarkAppBarBackground = Color(0xFF12161D);


InputDecoration kTextFieldDecoration(BuildContext context) {
  return InputDecoration(
    hintText: 'Enter a value',
    contentPadding:
      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
      enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
      focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
  );
}

const kSubtitleTextDecoration = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20,
);

TextStyle kAnimatedTitleDecoration(BuildContext context) {
  return TextStyle(
    color: Theme.of(context).colorScheme.primary,
    fontSize: 45,
    fontWeight: FontWeight.w900,
  );
}
