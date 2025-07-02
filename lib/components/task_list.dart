import 'package:flutter/material.dart';
import 'package:market_manager/components/task_tile.dart';
import 'package:market_manager/models/task_data.dart';
import 'package:provider/provider.dart';


class TaskList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskData>(
        builder: (BuildContext context,taskData, Widget? child) {
          return ListView.builder(
            itemBuilder: (context, index) {
              final task = taskData.tasks[index];
              return TaskTile(
                taskTitle: task.name,
                isChecked: task.isDone,
                checkboxCallback: (checkboxState) {
                  taskData.updateTask(task);
                },
                longPressCallback: () {
                  taskData.deleteTask(task);
                },
              );
            },
            itemCount: taskData.taskCount,
          );
        }
    );
  }
}
