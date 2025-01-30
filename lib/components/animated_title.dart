import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class AnimatedTitle extends StatelessWidget {
  const AnimatedTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'text',
      child: Material(
        color: Colors.transparent,
        child: AnimatedTextKit(
          isRepeatingAnimation: false,
          animatedTexts: [
            TyperAnimatedText(
              'Market',
              textAlign: TextAlign.center,
              textStyle: kAnimatedTitleDecoration(context),
            ),
            TyperAnimatedText(
              'Manager',
              textAlign: TextAlign.center,
              textStyle: kAnimatedTitleDecoration(context),

            ),
            TyperAnimatedText(
              'Market\nManager',
              textAlign: TextAlign.center,
              textStyle: kAnimatedTitleDecoration(context),
            ),
          ],
        ),
      ),
    );
  }
}