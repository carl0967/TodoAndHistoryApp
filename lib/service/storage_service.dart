import 'package:shared_preferences/shared_preferences.dart';

import '../model/task.dart';

class StorageService {
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = tasks.map((task) => task.toJson()).toList();
    prefs.setStringList('tasks', tasksString.cast<String>());
  }

  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getStringList('tasks') ?? [];
    return tasksString.map((task) => Task.fromJson(task as Map<String, dynamic>)).toList();
  }
}
