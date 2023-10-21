import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:src/model/status_change.dart';

import '../../provider/task_provider.dart';

class StatusChangeEditScreen extends ConsumerWidget {
  final StatusChange statusChange;
  final TextEditingController _changeTimeController = TextEditingController();

  StatusChangeEditScreen(this.statusChange);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _changeTimeController.text = DateFormat('y/MM/dd HH:mm').format(statusChange.changeTime);

    return Scaffold(
      appBar: AppBar(
        title: Text("状態遷移の編集"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _save(ref);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 150,
              child: TextField(
                controller: _changeTimeController,
                decoration: InputDecoration(
                  labelText: "変更した時刻",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(WidgetRef ref) {
    final content = _changeTimeController.text;
    try {
      statusChange.changeTime = DateFormat('y/MM/dd HH:mm').parse(content);
      ref.read(taskListProvider.notifier).changeTask();
    } catch (e) {
      print("Invalid start time format");
    }
  }
}
