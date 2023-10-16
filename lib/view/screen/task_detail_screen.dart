import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/task_model.dart';
import '../../provider/task_provider.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _elapsedMinuteController =
      TextEditingController(); // Change to minute

  TaskDetailScreen({required this.task});

  Future<bool> _saveAndPop(BuildContext context, WidgetRef ref) async {
    _save(context, ref);
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task.detail != null) {
      _detailController.text = task.detail!;
    }
    _nameController.text = task.name;
    _elapsedMinuteController.text =
        (task.elapsedSecond / 60).round().toString(); // Convert to minutes

    return WillPopScope(
      onWillPop: () => _saveAndPop(context, ref),
      child: Scaffold(
        appBar: AppBar(
          title: Text("タスク詳細"),
        ),
        body: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): DoSave(), // Ctrl+S
            LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS):
                DoSave(), // Cmd+S for macOS
          },
          child: Actions(
            actions: {
              DoSave: CallbackAction(onInvoke: (intent) => _save(context, ref)),
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "タスク名",
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Container(
                        width: 100, // Adjust width as needed
                        child: TextField(
                          controller: _elapsedMinuteController,
                          decoration: InputDecoration(
                            labelText: "経過分数",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: TextField(
                      minLines: 30,
                      controller: _detailController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "タスク詳細",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context, WidgetRef ref) {
    final content = _detailController.text;
    final name = _nameController.text;
    final elapsedMinutes = int.tryParse(_elapsedMinuteController.text);
    final elapsedSeconds = (elapsedMinutes ?? 0) * 60; // Convert minutes back to seconds

    task.detail = content;
    task.name = name;
    task.elapsedSecond = elapsedSeconds;
    ref.read(taskListProvider.notifier).changeTask();
    ref.read(taskListProvider.notifier).saveTasksToPrefs();

    final snackBar = SnackBar(content: Text('保存しました!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class DoSave extends Intent {}
