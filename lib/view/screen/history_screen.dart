import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/task_provider.dart';

class HistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(taskListProvider);
    var taskNotifier = ref.read(taskListProvider.notifier);

    // 今日終了したタスクのみをフィルタリング
    var todayTasks = tasks
        .where((task) => task.endTime != null && task.endTime!.day == DateTime.now().day)
        .toList();

    // 各タスクの編集用コントローラーを作成
    var nameControllers = todayTasks.map((task) => TextEditingController(text: task.name)).toList();
    var durationControllers =
        todayTasks.map((task) => TextEditingController(text: task.getTodayDurationText())).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: FixedColumnWidth(100),
                  },
                  border: TableBorder.all(),
                  children: List<TableRow>.generate(todayTasks.length, (index) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: nameControllers[index],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: durationControllers[index],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // ここで全ての変更を保存する処理を実装
                for (var i = 0; i < todayTasks.length; i++) {
                  var task = todayTasks[i];
                  task.name = nameControllers[i].text;
                  // 経過時間の更新処理をここに実装する必要がある
                  task.updateDailyElapsedSeconds(DateTime.now(), durationControllers[i].text);
                }
                await taskNotifier.saveTasksToPrefs(); // 変更を保存
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('変更を保存しました')),
                );
              },
              child: Text('全て保存'),
            ),
          ],
        ),
      ),
    );
  }
}
