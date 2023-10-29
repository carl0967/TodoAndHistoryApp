import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/task_provider.dart';

class AllTaskScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(taskListProvider);

    return Scaffold(
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          ref.read(taskListProvider.notifier).reorder(oldIndex, newIndex);
        },
        children: tasks
            .map((task) => ListTile(
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
                                    if (task.isVisible) {
                                      ref
                                          .read(taskListProvider.notifier)
                                          .changeVisible(task, false);
                                    } else {
                                      ref.read(taskListProvider.notifier).changeVisible(task, true);
                                    }
                                  },
                                  icon: task.isVisible
                                      ? const Icon(Icons.visibility_off)
                                      : const Icon(Icons.visibility)),
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
          await _exportStringToFile(context, ref);
        },
        child: Icon(Icons.save_alt),
        tooltip: 'エクスポート',
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

  Future<void> _exportStringToFile(BuildContext context, WidgetRef ref) async {
    // 保存する文字列
    String contentToSave = ref.read(taskListProvider.notifier).toJson();

    try {
      // ディレクトリを選択
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ディレクトリ選択がキャンセルされました')));
        return;
      }
      Directory directory = Directory(directoryPath);

      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ディレクトリ選択がキャンセルされました')));
        return;
      }

      // ファイルの保存先を選択するダイアログを表示
      TextEditingController fileNameController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ファイル名を入力してください"),
            content: TextField(
              controller: fileNameController,
              decoration: InputDecoration(
                labelText: "ファイル名",
                hintText: "例：myfile.txt",
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("キャンセル"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("保存"),
                onPressed: () async {
                  String filePath = '${directory.path}/${fileNameController.text}';
                  await File(filePath).writeAsString(contentToSave);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エクスポート完了!')));
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エクスポートエラー: $e')));
    }
  }
}
