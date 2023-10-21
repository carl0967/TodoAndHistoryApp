import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/view/screen/task_detail_screen.dart';

import '../../model/task.dart';
import '../../provider/task_provider.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(taskListProvider);

    return Scaffold(
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          ref.read(taskListProvider.notifier).reorder(oldIndex, newIndex);
        },
        children: tasks
            .where((task) => task.isVisible)
            .map((task) => ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(task: task),
                      ),
                    );
                  },
                  key: ValueKey(task),
                  title: Text(task.name),
                  subtitle: !task.isHeader && task.getSubTitle() != null
                      ? Text(task.getSubTitle()!)
                      : null,
                  tileColor: task.isHeader ? Colors.grey[200] : null,
                  enabled: task.isHeader ? false : true,
                  trailing: !task.isHeader
                      ? SizedBox(
                          width: 96,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    ref.read(taskListProvider.notifier).changeVisible(task, false);
                                  },
                                  icon: const Icon(Icons.visibility_off)),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  bool? shouldDelete = await _showDeleteConfirmationDialog(context);
                                  if (shouldDelete == true) {
                                    ref.read(taskListProvider.notifier).removeTask(task);
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      : null,
                ))
            .toList(),
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

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("タスクを削除しますか？"),
          actions: <Widget>[
            TextButton(
              child: Text("キャンセル"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("削除"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
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
            onSubmitted: (text) {
              print(taskController.text);
              Navigator.of(context).pop(taskController.text.trim());
            },
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
}
