import 'package:intl/intl.dart';
import 'package:src/model/status_change.dart';

enum TaskStatus { newTask, inProgress, paused, completed }

class Task {
  String name;
  DateTime createTime;
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
      this.detail = null,
      required this.createTime});

  DateTime getLastUpdateTime() {
    if (statusHistory.isNotEmpty) {
      // statusHistoryの最新の時刻を返す
      return statusHistory.last.changeTime;
    } else {
      // statusHistoryが空の場合は、createTimeを返す
      return createTime;
    }
  }

  String getDuration() {
    var duration = Duration(seconds: elapsedSecond);
    // 分を0.25時間の単位（つまり15分）で四捨五入
    int roundedMinutes = (duration.inMinutes / 15).ceil() * 15;

    // 丸められた結果を時間単位で取得
    double hours = roundedMinutes / 60.0;
    return "${hours}h";
  }

  String getTodayDurationText() {
    var duration = getTodayDuration();
    // 分を0.25時間の単位（つまり15分）で四捨五入
    int roundedMinutes = (duration.inMinutes / 15).ceil() * 15;

    // 丸められた結果を時間単位で取得
    double hours = roundedMinutes / 60.0;
    return "${hours}h";
  }

  Duration getTodayDuration() {
    Duration totalDuration = Duration.zero;
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);

    print(statusHistory.length);
    for (int i = 0; i < statusHistory.length; i++) {
      StatusChange change = statusHistory[i];
      if (change.changeTime.isAfter(todayStart) && change.newStatus == TaskStatus.inProgress) {
        DateTime? nextChangeTime = change.getNextChangeTime(statusHistory, i);
        if (nextChangeTime != null) {
          totalDuration += nextChangeTime.difference(change.changeTime);
          print("$totalDuration s");
        } else {
          // 最後の状態遷移の場合、現在の時間を使用
          totalDuration += now.difference(change.changeTime);
        }
      }
    }

    return totalDuration;
  }

  String? getSubTitle() {
    var text = startTime != null ? "開始:" + DateFormat('HH:mm').format(startTime!) : "";
    text = status == TaskStatus.completed || status == TaskStatus.paused
        ? "実績:" + getTodayDurationText()
        : text;
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
        'createTime': createTime.toIso8601String(),
      };

  static Task fromJson(Map<String, dynamic> json) {
    var task = Task(
      json['name'].toString(),
      status: TaskStatus.values[json['status'] as int],
      isHeader: json['isHeader'] as bool,
      elapsedSecond: json['elapsedSecond'] as int,
      isVisible: json['isVisible'] as bool,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      detail: json['detail'] as String?,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'] as String)
          : DateTime.now(),
    );

    if (json['statusHistory'] != null) {
      task.statusHistory = (json['statusHistory'] as List)
          .map((e) => StatusChange.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return task;
  }
}
