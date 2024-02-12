import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/status_change.dart';
import '../model/task.dart';

final log = Logger('TaskNotifier');

final initialTasks = [
  Task("新規", status: TaskStatus.newTask, isHeader: true, createTime: DateTime.now()),
  Task("進行中", status: TaskStatus.inProgress, isHeader: true, createTime: DateTime.now()),
  Task("中断", status: TaskStatus.paused, isHeader: true, createTime: DateTime.now()),
  Task("完了", status: TaskStatus.completed, isHeader: true, createTime: DateTime.now()),
];

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  var taskNotifier = TaskNotifier();
  taskNotifier.loadTasksFromPrefs();
  return taskNotifier;
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  void clear() {
    state = state..clear();
    saveTasksToPrefs();
  }

  // ファイルを選択して読み込むメソッド
  Future<void> importJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      updateTasksFromJson(content);
    } else {}
  }

  void updateTasksFromJson(String jsonData) {
    final List<dynamic> tasksList = jsonDecode(jsonData) as List;
    state = tasksList.map((taskMap) {
      return Task.fromJson(taskMap as Map<String, dynamic>);
    }).toList();
  }

  void addTask(Task task) {
    //新規の位置に追加
    state = [...state]..insert(1, task);
    saveTasksToPrefs();
  }

  void addTaskWithComplete(Task task) {
    //完了の位置に追加
    state = [...state]..add(task);
    saveTasksToPrefs();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    log.info("oldIndex:$oldIndex,newIndex:$newIndex");

    final item = state.removeAt(oldIndex);
    state = [...state]..insert(newIndex, item);

    for (var i = 0; i < state.length; i++) {
      log.info("$i: ${state[i].name}");
    }

    var newStatus = TaskStatus.newTask;
    for (var i = newIndex; i > 0; i--) {
      log.info("$i: ${state[i].name}");
      if (state[i].isHeader) {
        newStatus = state[i].status;
        break;
      }
    }
    //ステータスが変更になった場合
    var oldStatus = item.status;
    log.info("status changed. $oldStatus -> $newStatus");

    if (oldStatus != newStatus) {
      changeStatus(item, newStatus);
    }
  }

  void changeStatus(Task task, TaskStatus newStatus) {
    if (newStatus == TaskStatus.inProgress) {
      task.startTime = DateTime.now();
    } else if (newStatus == TaskStatus.completed) {
      // →完了
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

    task.statusHistory.add(StatusChange(DateTime.now(), task.status, newStatus));
    task.status = newStatus;

    state = state.toList();
    saveTasksToPrefs();
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

  void updateAndSave() {
    state = state.toList();
    saveTasksToPrefs();
  }

  Future<void> saveTasksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(state.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  void filter(bool todayOnly) {
    if (todayOnly) {
      for (var task in state
          .where((element) => element.isVisible && element.status != TaskStatus.completed)) {
        var startDate = task.plannedStartDate;
        if (startDate == null) {
          task.isVisible = false;
        }
        if (startDate != null && startDate.isAfter(DateTime.now())) {
          task.isVisible = false;
        }
      }
    } else {
      for (var task in state
          .where((element) => !element.isVisible && element.status != TaskStatus.completed)) {
        var startDate = task.plannedStartDate;
        if ((startDate == null || startDate.isAfter(DateTime.now())) &&
            task.status != TaskStatus.completed) {
          task.isVisible = true;
        }
      }
    }
    state = state.toList();
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
        // endTimeの日付部分が今日より前の場合は、task.visibleをfalseに設定
        if (task.getEndTime() != null) {
          var endTime = task.getEndTime();
          DateTime currentDateWithoutTime =
              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          DateTime endTimeWithoutTime = DateTime(endTime!.year, endTime!.month, endTime!.day);

          if (endTimeWithoutTime.isBefore(currentDateWithoutTime)) {
            task.isVisible = false;
          }
        }
        return task;
      }).toList();
    }
    if (state.length == 0) {
      state = initialTasks;
    }
  }
}
