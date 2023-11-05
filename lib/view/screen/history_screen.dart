import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/model/status_change.dart';

import '../../model/task.dart';
import '../../provider/task_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<Task> todayTasks = [];
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> durationControllers = [];

  @override
  void initState() {
    super.initState();
    final tasks = ref.read(taskListProvider);
    todayTasks = tasks
        .where((task) => task.endTime != null && task.endTime!.day == DateTime.now().day)
        .toList();
    nameControllers = todayTasks.map((task) => TextEditingController(text: task.name)).toList();
    durationControllers =
        todayTasks.map((task) => TextEditingController(text: task.getTodayDurationText())).toList();
  }

  void _addNewTask() {
    setState(() {
      var newTask = Task("", createTime: DateTime.now());
      newTask.statusHistory
          .add(StatusChange(DateTime.now(), TaskStatus.newTask, TaskStatus.completed));
      // TODO: statusHistoryとstatusがかぶってるので直す
      newTask.status = TaskStatus.completed;
      newTask.endTime = DateTime.now();

      todayTasks.add(newTask);
      nameControllers.add(TextEditingController(text: newTask.name));
      durationControllers.add(TextEditingController(text: newTask.getTodayDurationText()));

      final taskNotifier = ref.read(taskListProvider.notifier);
      taskNotifier.addTaskWithComplete(newTask);
    });
  }

  void _saveAllTasks() async {
    final taskNotifier = ref.read(taskListProvider.notifier);
    for (int i = 0; i < todayTasks.length; i++) {
      todayTasks[i].name = nameControllers[i].text;
      todayTasks[i].updateDailyElapsedSeconds(DateTime.now(), durationControllers[i].text);
    }
    await taskNotifier.saveTasksToPrefs();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('変更を保存しました')));
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _addNewTask,
                  child: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveAllTasks,
                  child: Text('全て保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
