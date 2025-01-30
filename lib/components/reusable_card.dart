import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {

  final Widget cardChild;
  final GestureTapCallback? onPress;
  final Color? color;

  ReusableCard({required this.cardChild, this.onPress, this.color});




  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress ?? () {},
      child: Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        child: cardChild,
      ),
    );
  }
}