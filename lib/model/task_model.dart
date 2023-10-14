enum TaskStatus { newTask, inProgress, paused, completed }

class Task {
  final String name;
  DateTime? startTime;
  DateTime? endTime;
  int elapsedSecond = 0;

  TaskStatus status;
  bool isHeader = false;

  Task(this.name, {this.status = TaskStatus.newTask, this.isHeader = false});

  String getDuration() {
    var duration = Duration(seconds: elapsedSecond);
    // 分を0.25時間の単位（つまり15分）で四捨五入
    int roundedMinutes = (duration.inMinutes / 15).ceil() * 15;

    // 丸められた結果を時間単位で取得
    double hours = roundedMinutes / 60.0;
    return "${hours}h";
  }

  String getSubTitle() {
    var text = startTime != null ? "開始:" + startTime.toString() : "";
    text = endTime != null ? "経過時刻:" + getDuration() : text;
    return text;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status.index,
        'isHeader': isHeader,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        json['name'].toString(),
        status: TaskStatus.values[json['status'] as int],
        isHeader: json['isHeader'] as bool,
      );
}
