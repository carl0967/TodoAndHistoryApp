import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/task_provider.dart';

class HistoryScreen extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController(text: 'Hello, World!');

  bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(taskListProvider);

    var text = "";
    for (var task in tasks) {
      if (task.isHeader) {
        continue;
      }
      if (isToday(task.endTime)) {
        if (text != "") {
          text += "\n";
        }
        text += "${task.name}\t${task.getSubTitle()}";
      }
    }
    _controller.text = text;
    print(text);

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        maxLines: null, // これにより、テキストフィールドが複数行になります
        keyboardType: TextInputType.multiline, // マルチライン入力のキーボードタイプを設定
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
    ));
  }
}
