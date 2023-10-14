import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/task_model.dart';

final initialTasks = [
  Task("新規", status: TaskStatus.newTask, isHeader: true),
  Task("進行中", status: TaskStatus.inProgress, isHeader: true),
  Task("中断", status: TaskStatus.paused, isHeader: true),
  Task("完了", status: TaskStatus.completed, isHeader: true),
];

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) => TaskNotifier());

final taskTimerProvider = StateProvider<int>((ref) => 0);

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super(initialTasks);
  void addTask(Task task) {
    //新規の位置に追加
    state = [...state]..insert(1, task);
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
  }

  void _changeStatus(Task task, TaskStatus newStatus) {
    if (newStatus == TaskStatus.inProgress) {
      task.startTime = DateTime.now();
    } else if (newStatus == TaskStatus.completed) {
      task.endTime = DateTime.now();
      final duration = DateTime.now().difference(task.startTime!);
      print("経過時間: ${duration.inSeconds} 秒");
      task.elapsedSecond += duration.inSeconds;
    } else if (newStatus == TaskStatus.paused && task.status == TaskStatus.inProgress) {
      final duration = DateTime.now().difference(task.startTime!);
      print("経過時間: ${duration.inSeconds} 秒");
      task.elapsedSecond += duration.inSeconds;
    }

    task.status = newStatus;
  }

  void removeTask(Task task) {
    state = state.where((t) => t != task).toList();
  }
}
