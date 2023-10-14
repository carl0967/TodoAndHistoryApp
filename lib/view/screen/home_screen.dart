import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/task_model.dart';
import '../../provider/task_provider.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("タスク管理"),
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          ref.read(taskListProvider.notifier).reorder(oldIndex, newIndex);
        },
        children: [
          for (var status in TaskStatus.values) ...[
            // セクションヘッダー
            ListTile(
              key: ValueKey(status),
              title: Text(status.toString().split('.').last),
              tileColor: Colors.grey[200],
              enabled: false,
            ),
            // セクションのアイテム
            for (var task in tasks.where((t) => t.status == status))
              ListTile(
                key: ValueKey(task),
                title: Text(task.name),
              ),
          ]
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? newTaskName = await _showAddTaskDialog(context);
          if (newTaskName != null && newTaskName.isNotEmpty) {
            ref.read(taskListProvider.notifier).addTask(Task(newTaskName));
          }
        },
        child: Icon(Icons.add),
        tooltip: 'タスクを追加',
      ),
    );
  }

  Future<String?> _showAddTaskDialog(BuildContext context) async {
    TextEditingController taskController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("新しいタスク"),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(
              labelText: "タスク名",
              hintText: "タスク名を入力してください",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("キャンセル"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                print(taskController.text);
                Navigator.of(context).pop(taskController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  List<Task> _reorderList(List<Task> items, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    return items;
  }
}
