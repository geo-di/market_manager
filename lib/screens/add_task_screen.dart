import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';
import 'package:provider/provider.dart';
import 'package:market_manager/models/task_data.dart';

class AddTaskScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    late String newTaskTitle;

    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Task',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          TextField(
            autofocus: true,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0
                ),
              ),
            ),
            cursorColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              newTaskTitle = value;
            },
          ),

          TextButton(
            onPressed: () {
              Provider.of<TaskData>(context, listen: false).addTask(newTaskTitle);
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).colorScheme.primary
              ),
            ),
            child: Text(
              'Add',
              style: TextStyle(
                  color: kAppWhite
              ),
            ),
          ),
        ],
      ),
    );
  }
}
