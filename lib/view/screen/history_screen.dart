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
  DateTime selectedDate = DateTime.now();
  List<Task> todayTasks = [];
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> durationControllers = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final tasks = ref.read(taskListProvider);
    todayTasks = tasks
        .where((task) =>
            task.getEndTime() != null &&
            task.getEndTime()!.day == selectedDate.day &&
            task.getEndTime()!.month == selectedDate.month &&
            task.getEndTime()!.year == selectedDate.year)
        .toList();

    nameControllers = todayTasks.map((task) => TextEditingController(text: task.name)).toList();
    durationControllers = todayTasks
        .map((task) => TextEditingController(text: task.getTodayDurationText(selectedDate)))
        .toList();
  }

  void _addNewTask() {
    setState(() {
      var newTask = Task("", createTime: DateTime.now());
      newTask.statusHistory
          .add(StatusChange(DateTime.now(), TaskStatus.newTask, TaskStatus.completed));
      // TODO: statusHistoryとstatusがかぶってるので直す
      newTask.status = TaskStatus.completed;

      todayTasks.add(newTask);
      nameControllers.add(TextEditingController(text: newTask.name));
      durationControllers
          .add(TextEditingController(text: newTask.getTodayDurationText(selectedDate)));

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _init();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedDate.toString()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
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
