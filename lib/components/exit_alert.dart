import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';

class ExitAlert extends StatelessWidget {
  const ExitAlert({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 2,
      backgroundColor: kAppWhite,

      title: const Text(
        'Are you sure?',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 30,
          fontWeight: FontWeight.w700
        ),
      ),
      content: const Text(
        'Are you sure you want to leave this page?',
        style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.w500
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 14),

          ),
          child: const Text('Nevermind'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          child: const Text('Leave'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}