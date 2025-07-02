import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';

class TaskTile extends StatelessWidget {

  final bool isChecked;
  final String taskTitle;
  final ValueChanged checkboxCallback;
  final GestureLongPressCallback longPressCallback;

  TaskTile({required this.taskTitle, required this.isChecked, required this.checkboxCallback, required this.longPressCallback});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: longPressCallback,
      title: Text(
        taskTitle,
        style: TextStyle(
            decoration: isChecked ? TextDecoration.lineThrough : null
        ),
      ),
      trailing: Checkbox(
          activeColor: Theme.of(context).colorScheme.primary,
          checkColor: kAppWhite,
          value: isChecked,
          onChanged: checkboxCallback
      ),
    );
  }
}



