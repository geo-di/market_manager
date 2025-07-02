import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {

  final Widget cardChild;
  final GestureTapCallback? onPress;
  final Color? color;

  ReusableCard({required this.cardChild, this.onPress, this.color});




  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPress ?? () {},
        child: Container(
          margin: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: color ?? Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: cardChild,
        ),
      ),
    );
  }
}