import 'package:intl/intl.dart';
import 'package:src/model/status_change.dart';

enum TaskStatus { newTask, inProgress, paused, completed }

class Task {
  String name;
  DateTime? startTime;
  DateTime? endTime;
  int elapsedSecond = 0;

  TaskStatus status;
  bool isHeader = false;
  bool isVisible = true;
  String? detail;
  List<StatusChange> statusHistory = [];

  Task(this.name,
      {this.status = TaskStatus.newTask,
      this.isHeader = false,
      this.elapsedSecond = 0,
      this.isVisible = true,
      this.startTime = null,
      this.endTime = null,
      this.detail = null});

  String getDuration() {
    var duration = Duration(seconds: elapsedSecond);
    // 分を0.25時間の単位（つまり15分）で四捨五入
    int roundedMinutes = (duration.inMinutes / 15).ceil() * 15;

    // 丸められた結果を時間単位で取得
    double hours = roundedMinutes / 60.0;
    return "${hours}h";
  }

  String? getSubTitle() {
    var text = startTime != null ? "開始:" + DateFormat('HH:mm').format(startTime!) : "";
    text = status == TaskStatus.completed ? "実績:" + getDuration() : text;
    return text == "" ? null : text;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status.index,
        'isHeader': isHeader,
        'elapsedSecond': elapsedSecond,
        'isVisible': isVisible,
        'startTime': startTime?.toIso8601String(), // DateTimeをISO8601文字列に変換
        'endTime': endTime?.toIso8601String(),
        'detail': detail,
        'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
      };

  static Task fromJson(Map<String, dynamic> json) {
    var task = Task(json['name'].toString(),
        status: TaskStatus.values[json['status'] as int],
        isHeader: json['isHeader'] as bool,
        elapsedSecond: json['elapsedSecond'] as int,
        isVisible: json['isVisible'] as bool,
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
        detail: json['detail'] as String?);

    if (json['statusHistory'] != null) {
      task.statusHistory = (json['statusHistory'] as List)
          .map((e) => StatusChange.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return task;
  }
}
