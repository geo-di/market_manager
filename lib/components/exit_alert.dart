import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';

class ReusableDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const ReusableDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  static const TextStyle _titleStyle = TextStyle(
    color: Colors.black87,
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _contentStyle = TextStyle(
    color: Colors.black54,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static ButtonStyle actionButtonStyle(BuildContext context) => TextButton.styleFrom(
    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 14,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 2,
      backgroundColor: kAppWhite,
      title: Text(title, style: _titleStyle),
      content: DefaultTextStyle(
        style: _contentStyle,
        child: content,
      ),
      actions: actions
          .map((action) => TextButton(
        style: actionButtonStyle(context),
        onPressed: () {
          if (action is TextButton) {
            // To keep existing onPressed behavior if action is TextButton
            (action.onPressed)?.call();
          }
        },
        child: action is TextButton ? action.child! : action,
      ))
          .toList(),
    );
  }
}
