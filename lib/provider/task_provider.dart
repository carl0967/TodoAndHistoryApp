import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/status_change.dart';
import '../model/task.dart';

final initialTasks = [
  Task("新規", status: TaskStatus.newTask, isHeader: true),
  Task("進行中", status: TaskStatus.inProgress, isHeader: true),
  Task("中断", status: TaskStatus.paused, isHeader: true),
  Task("完了", status: TaskStatus.completed, isHeader: true),
];

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  var taskNotifier = TaskNotifier();
  taskNotifier.loadTasksFromPrefs();
  return taskNotifier;
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);
  void addTask(Task task) {
    //新規の位置に追加
    state = [...state]..insert(1, task);
    saveTasksToPrefs();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = state.removeAt(oldIndex);
    state = [...state]..insert(newIndex, item);

    var newStatus = TaskStatus.newTask;
    for (var i = newIndex; i > 0; i--) {
      print(state[i].name);
      if (state[i].isHeader) {
        newStatus = state[i].status;
        break;
      }
    }
    //ステータスが変更になった場合
    var oldStatus = item.status;
    print("$oldStatus $newStatus");
    if (oldStatus != newStatus) {
      _changeStatus(item, newStatus);
    }
    saveTasksToPrefs();
  }

  void _changeStatus(Task task, TaskStatus newStatus) {
    if (newStatus == TaskStatus.inProgress) {
      task.startTime = DateTime.now();
    } else if (newStatus == TaskStatus.completed) {
      // →完了
      task.endTime = DateTime.now();
      if (task.startTime != null) {
        final duration = DateTime.now().difference(task.startTime!);
        print("経過時間: ${duration.inSeconds} 秒");
        task.elapsedSecond += duration.inSeconds;
      }
    } else if (newStatus == TaskStatus.paused && task.status == TaskStatus.inProgress) {
      // 進行中→中断
      final duration = DateTime.now().difference(task.startTime!);
      print("経過時間: ${duration.inSeconds} 秒");
      task.elapsedSecond += duration.inSeconds;
    }

    task.statusHistory.insert(0, StatusChange(DateTime.now(), task.status, newStatus));
    task.status = newStatus;
  }

  void removeTask(Task task) {
    state = state.where((t) => t != task).toList();
    saveTasksToPrefs();
  }

  void changeVisible(Task task, bool visible) {
    task.isVisible = visible;
    state.remove(task);
    state.add(task);
    state = state.toList();
    saveTasksToPrefs();
  }

  void changeTask() {
    state = state.toList();
  }

  Future<void> saveTasksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(state.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  String toJson() {
    return jsonEncode(state.map((task) => task.toJson()).toList());
  }

  Future<void> loadTasksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> tasksList = jsonDecode(tasksJson) as List;
      state = tasksList.map((taskMap) {
        Task task = Task.fromJson(taskMap as Map<String, dynamic>);
        // endTimeが今日より前の場合は、task.visibleをfalseに設定
        if (task.endTime != null && task.endTime!.isBefore(DateTime.now())) {
          task.isVisible = false;
        }
        return task;
      }).toList();
    }
    if (state.length == 0) {
      state = initialTasks;
    }
  }
}
