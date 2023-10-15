import 'package:flutter/material.dart';

import '../../model/task_model.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("タスク詳細"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('タスク名: ${task.name}'),
            SizedBox(height: 16.0),
            Text('ステータス: ${task.status}'),
            // ここに他の詳細情報を追加できます
          ],
        ),
      ),
    );
  }
}
