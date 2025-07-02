import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:market_manager/components/task_list.dart';
import 'package:market_manager/constants.dart';
import 'package:market_manager/models/task.dart';
import 'package:market_manager/models/task_data.dart';
import 'package:market_manager/screens/add_task_screen.dart';
import 'package:provider/provider.dart';

class ShowTasksScreen extends StatelessWidget {
  const ShowTasksScreen({super.key});

  static const String id = 'show_tasks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.add,
            color: kAppWhite,
          ),
        onPressed: () {
          final taskData = Provider.of<TaskData>(context, listen: false);

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: AddTaskScreen(),
              ),
            ),
          );
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)
                )

            ),
            padding: EdgeInsets.only(
                top: 60,
                left: 30,
                right: 30,
                bottom: 30
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.list,
                    size: 30,
                    color: kAppWhite,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Daily Tasks',
                  style: TextStyle(
                    color: kAppWhite,
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${Provider.of<TaskData>(context).taskCount} tasks left!',
                  style: TextStyle(
                    color: kAppWhite,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)
                ),
              ),
              child: TaskList(),
            ),
          )
        ],
      ),
    );
  }
}
