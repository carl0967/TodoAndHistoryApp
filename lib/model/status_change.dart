import 'package:src/model/task.dart';

class StatusChange {
  DateTime changeTime;
  TaskStatus previousStatus; // 変更前のステータス
  TaskStatus newStatus; // 変更後のステータス

  StatusChange(this.changeTime, this.previousStatus, this.newStatus);

  Map<String, dynamic> toJson() => {
        'changeTime': changeTime.toIso8601String(),
        'previousStatus': previousStatus.index,
        'newStatus': newStatus.index,
      };

  static StatusChange fromJson(Map<String, dynamic> json) => StatusChange(
        DateTime.parse(json['changeTime'] as String),
        json['previousStatus'] != null
            ? TaskStatus.values[json['previousStatus'] as int]
            : TaskStatus.newTask,
        json['newStatus'] != null
            ? TaskStatus.values[json['previousStatus'] as int]
            : TaskStatus.newTask,
      );
}
