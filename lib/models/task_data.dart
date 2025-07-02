import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import 'package:market_manager/models/task.dart';

class TaskData extends ChangeNotifier {

  List<Task> _tasks = [];

  TaskData([List<Task>? initialTasks]) {
    if (initialTasks != null) {
      _tasks = initialTasks;
    }
  }

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  int get taskCount => _tasks.length;

  Future<void> loadTasks() async {
    final box = await Hive.openBox<Task>('list');
    _tasks = box.values.toList();
    notifyListeners();
  }

  void addTask(String newTaskTitle) {
    final task = Task(name: newTaskTitle);
    _tasks.add(task);
    storeItems();
    notifyListeners();
  }

  void updateTask(Task task) {
    task.toggleDone();
    storeItems();
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    storeItems();
    notifyListeners();
  }

  Future<void> storeItems() async {
    final box = await Hive.openBox<Task>('list');
    await box.clear();
    await box.addAll(_tasks);
  }

}