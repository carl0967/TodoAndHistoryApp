import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:src/view/screen/task_detail_screen.dart';

import '../../provider/task_provider.dart';

class AllTaskScreen extends ConsumerStatefulWidget {
  @override
  _AllTaskScreenState createState() => _AllTaskScreenState();
}

class _AllTaskScreenState extends ConsumerState<AllTaskScreen> {
  String searchQuery = ''; // 検索クエリを保持する変数

  void _filterTasks(String query) {
    // 検索クエリを更新
    setState(() {
      searchQuery = query;
    });
    // ここでタスクリストをフィルタリングするロジックを実装します。
    // 例えば、Providerを使用している場合は、Providerの状態を更新することができます。
  }

  @override
  Widget build(BuildContext context) {
    var tasks = ref.watch(taskListProvider);
    if (searchQuery.isNotEmpty) {
      tasks = tasks
          .where((x) => x.name.contains(searchQuery) || x.detail?.contains(searchQuery) == true)
          .toList();
    }

    var sortedTasks = tasks.toList()
      ..sort((a, b) {
        // 完了しているタスクの場合、完了時刻で比較
        var aTime = a.getEndTime() ?? a.createTime;
        var bTime = b.getEndTime() ?? b.createTime;

        // どちらかが未完了の場合、生成時刻で比較
        return bTime.compareTo(aTime);
      });

    sortedTasks = sortedTasks.where((element) => !element.isHeader).toList();

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    searchQuery = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Task',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // 検索ボタンが押されたときの処理
                  _filterTasks(searchQuery);
                },
              ),
            ],
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {},
              children: sortedTasks
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
                        title: task.isHeader
                            ? Text(task.name)
                            : Text(
                                "${DateFormat('MM/dd').format(task.getLastUpdateTime())} ${task.name}"),
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
                                          if (task.isVisible) {
                                            ref
                                                .read(taskListProvider.notifier)
                                                .changeVisible(task, false);
                                          } else {
                                            ref
                                                .read(taskListProvider.notifier)
                                                .changeVisible(task, true);
                                          }
                                        },
                                        icon: task.isVisible
                                            ? const Icon(Icons.visibility_off)
                                            : const Icon(Icons.visibility)),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        bool? shouldDelete =
                                            await _showDeleteConfirmationDialog(context);
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
          ),
        ],
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
}
