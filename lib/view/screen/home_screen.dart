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
            focusNode: FocusNode(canRequestFocus: false),
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

  void _deleteTask(BuildContext context, Task task, WidgetRef ref) async {
    bool? shouldDelete = await _showDeleteConfirmationDialog(context);
    if (shouldDelete == true) {
      ref.read(taskListProvider.notifier).removeTask(task);
    }
  }

  void _moveNextStatus(BuildContext context, Task task, WidgetRef ref) {
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
  }

  List<Widget> _list(List<Task> tasks, BuildContext context, WidgetRef ref) {
    var sortedTasks = tasks.where((task) => task.isVisible && !task.isHeader).toList()
      ..sort((a, b) {
        const order = {
          TaskStatus.inProgress: 1,
          TaskStatus.paused: 2,
          TaskStatus.newTask: 3,
          TaskStatus.completed: 4,
        };
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
            title: Text("【${task.status.statusName}】 ${task.plannedStartDateText} ${task.name}"),
            subtitle: !task.isHeader && task.getSubTitle() != null
                ? Text(task.getSubTitle() ?? "")
                : null,
            tileColor: task.isHeader ? Colors.grey[200] : null,
            enabled: task.isHeader ? false : true,
            trailing: PopupMenuButton<String>(
              onSelected: (String value) {
                switch (value) {
                  case 'nextStatus':
                    _moveNextStatus(context, task, ref);
                    break;
                  case 'pause':
                    ref.read(taskListProvider.notifier).changeStatus(task, TaskStatus.paused);
                    break;
                  case 'end':
                    ref.read(taskListProvider.notifier).changeVisible(task, false);
                    ref.read(taskListProvider.notifier).changeStatus(task, TaskStatus.completed);
                    break;
                  case 'delete':
                    _deleteTask(context, task, ref);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'nextStatus',
                  child: Text('次のステータスへ'),
                ),
                const PopupMenuItem<String>(
                  value: 'pause',
                  child: Text('停止'),
                ),
                const PopupMenuItem<String>(
                  value: 'end',
                  child: Text('完了'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('削除'),
                ),
              ],
            )))
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
    DateTime? selectedDate = DateTime.now(); // 選択された日付を保持する変数

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
                initialDate: selectedDate,
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
                          : '予定開始日を選択'),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() => selectedDate = null); // 日付をクリア
                        },
                      ),
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
