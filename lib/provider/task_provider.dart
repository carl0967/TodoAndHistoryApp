import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/task_model.dart';

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) => TaskNotifier());

final taskTimerProvider = StateProvider<int>((ref) => 0);

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  void addTask(Task task) {
    state = [...state, task];
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = state.removeAt(oldIndex);
    state = [...state]..insert(newIndex, item);
  }
}
