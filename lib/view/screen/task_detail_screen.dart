import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/task_model.dart';
import '../../provider/task_provider.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;

  TaskDetailScreen({required this.task});
  final TextEditingController _controller = TextEditingController();

  Future<bool> _saveAndPop(BuildContext context, WidgetRef ref) async {
    _save(context, ref);
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task.detail != null) {
      _controller.text = task.detail!;
    }
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
                  Text('タスク名: ${task.name}'),
                  SizedBox(height: 16.0),
                  Text('ステータス: ${task.status}'),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
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
    // ここで保存処理を行います
    final content = _controller.text;
    ref.read(taskListProvider.notifier).changeDetail(task, content);

    final snackBar = SnackBar(content: Text('保存しました!'));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class DoSave extends Intent {}
