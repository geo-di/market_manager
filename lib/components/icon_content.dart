import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';



class IconContent extends StatelessWidget {

  final IconData icon;
  final String label;

  IconContent({required this.icon, required this.label});



  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 80.0,
        ),
        SizedBox(
          height: 15.0,
        ),
        Text (
          label,
          style: kSubtitleTextDecoration.copyWith(
            color: kAppWhite,
          ),
        ),
      ],
    );
  }
}