import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:src/view/screen/all_task_screen.dart';
import 'package:src/view/screen/history_screen.dart';
import 'package:src/view/screen/home_screen.dart';

import '../../provider/task_provider.dart';

class TabScreen extends ConsumerWidget {
  // データクリアの確認ダイアログを表示するメソッド
  Future<void> _showClearConfirmationDialog(BuildContext context, WidgetRef ref) async {
    // showDialog 関数を使用してダイアログを表示
    final bool confirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm'),
              content: Text('Are you sure you want to clear all data?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // ダイアログを閉じて false を返す
                  },
                ),
                TextButton(
                  child: Text('Clear'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // ダイアログを閉じて true を返す
                  },
                ),
              ],
            );
          },
        ) ??
        false; // showDialog が null を返した場合は false とする

    // 確認が取れた場合のみクリア処理を実行
    if (confirmed) {
      ref.read(taskListProvider.notifier).clear();
    }
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: TabBar(
            tabs: [
              Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Tab(icon: Icon(Icons.home), text: "Home")),
              Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Tab(icon: Icon(Icons.history), text: "History")),
              Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Tab(icon: Icon(Icons.align_horizontal_left_outlined), text: "All")),
            ],
            isScrollable: true,
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Menu'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Import'),
                onTap: () {
                  ref.read(taskListProvider.notifier).importJson();
                },
              ),
              ListTile(
                title: Text('Export'),
                onTap: () {
                  _exportStringToFile(context, ref);
                },
              ),
              ListTile(
                title: Text('Clear'),
                onTap: () {
                  _showClearConfirmationDialog(context, ref);
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeScreen(),
            HistoryScreen(),
            AllTaskScreen(),
          ],
        ),
      ),
    );
  }
}
