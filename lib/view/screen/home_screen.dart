import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:src/view/screen/task_detail_screen.dart';

import '../../model/task.dart';
import '../../provider/task_provider.dart';

class HomeScreen extends ConsumerWidget {
  String dropdownValue = '未完了'; // ドロップダウンの初期値

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(taskListProvider);

    return Scaffold(
      body: Column(
        children: [
          // ドロップダウンメニュー
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String? newValue) {
              dropdownValue = newValue ?? "";
              bool todayOnly = dropdownValue == "今日";
              ref.watch(taskListProvider.notifier).filter(todayOnly);
            },
            items: <String>['未完了', '今日'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                ref.read(taskListProvider.notifier).reorder(oldIndex, newIndex);
              },
              children: _list(tasks, context, ref),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var task = await _showAddTaskDialog(context);
          if (task != null) {
            ref.read(taskListProvider.notifier).addTask(task);
          }
        },
        child: Icon(Icons.add),
        tooltip: 'タスクを追加',
      ),
    );
  }

  List<Widget> _list(List<Task> tasks, BuildContext context, WidgetRef ref) {
    var sortedTasks = tasks.where((task) => task.isVisible && !task.isHeader).toList() // Listに変換
      ..sort((a, b) {
        // 並び替えの優先順位を定義
        const order = {
          TaskStatus.inProgress: 1,
          TaskStatus.paused: 2,
          TaskStatus.newTask: 3,
          TaskStatus.completed: 4,
        };

        // タスクのステータスに基づいて並び替え
        return order[a.status]!.compareTo(order[b.status]!);
      });

    return sortedTasks
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
              title: Text(task.status.statusName + " " + task.name),
              subtitle:
                  !task.isHeader && task.getSubTitle() != null ? Text(task.getSubTitle()!) : null,
              tileColor: task.isHeader ? Colors.grey[200] : null,
              enabled: task.isHeader ? false : true,
              trailing: !task.isHeader
                  ? SizedBox(
                      width: 32 * 4,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_forward), // Replace with your desired icon
                            onPressed: () {
                              TaskStatus nextStatus = TaskStatus.inProgress;
                              // Check the current status and update accordingly
                              if (task.status == TaskStatus.newTask) {
                                nextStatus = TaskStatus.inProgress;
                              } else if (task.status == TaskStatus.inProgress) {
                                nextStatus = TaskStatus.completed;
                                ref.read(taskListProvider.notifier).changeVisible(task, false);
                              }

                              // Update the task in the provider or state management logic
                              ref.read(taskListProvider.notifier).changeStatus(task, nextStatus);
                            },
                          ),
                          IconButton(
                              onPressed: () {
                                ref
                                    .read(taskListProvider.notifier)
                                    .changeStatus(task, TaskStatus.paused);
                              },
                              icon: const Icon(Icons.stop_circle_outlined)),
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
        .toList();
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

  Future<Task?> _showAddTaskDialog(BuildContext context) async {
    TextEditingController taskController = TextEditingController();
    DateTime? selectedDate; // 選択された日付を保持する変数

    return showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // StatefulBuilderを使用
          builder: (BuildContext context, StateSetter setState) {
            // StateSetterを使用
            // 日付ピッカーを表示するメソッド
            Future<void> _selectPlannedStartDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(), // 初期選択日付
                firstDate: DateTime(2000),
                lastDate: DateTime(2025),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  // StatefulBuilderのsetStateを使用
                  selectedDate = picked;
                });
              }
            }

            return AlertDialog(
              title: Text("新しいタスク"),
              content: Column(
                mainAxisSize: MainAxisSize.min, // コンテンツのサイズを最小限に
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: _selectPlannedStartDate,
                      ),
                      // 選択された日付を表示
                      Text(selectedDate != null
                          ? DateFormat('yyyy/MM/dd').format(selectedDate!)
                          : '日付を選択'),
                    ],
                  ),
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      labelText: "タスク名",
                      hintText: "タスク名を入力してください",
                    ),
                  ),
                ],
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
                    var newTaskName = taskController.text.trim();
                    var task = Task(newTaskName,
                        createTime: DateTime.now(), plannedStartDate: selectedDate);
                    Navigator.of(context).pop(task);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
