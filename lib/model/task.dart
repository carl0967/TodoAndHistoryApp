import 'package:intl/intl.dart';
import 'package:src/model/status_change.dart';

enum TaskStatus { newTask, inProgress, paused, completed }

class Task {
  String name;
  DateTime createTime;
  DateTime? startTime;
  int elapsedSecond = 0;

  TaskStatus status;
  bool isHeader = false;
  bool isVisible = true;
  String? detail;
  List<StatusChange> statusHistory = [];
  Map<String, int> dailyElapsedSeconds = {};

  Task(this.name,
      {this.status = TaskStatus.newTask,
      this.isHeader = false,
      this.elapsedSecond = 0,
      this.isVisible = true,
      this.startTime = null,
      this.detail = null,
      required this.createTime});

  DateTime? getEndTime() {
    //var sortedHistory = List<StatusChange>.from(statusHistory)
    //  ..sort((a, b) => b.changeTime.compareTo(a.changeTime));

    // ソートされたリストからcompletedステータスの最新の時間を探す
    for (StatusChange change in statusHistory) {
      if (change.newStatus == TaskStatus.completed) {
        return change.changeTime; // 最新のcompletedステータスの時間を返す
      }
    }
    // ソートされたリストからpausedステータスの最新の時間を探す
    for (StatusChange change in statusHistory) {
      if (change.newStatus == TaskStatus.paused) {
        return change.changeTime; // 最新のcompletedステータスの時間を返す
      }
    }

    return null; // completedステータスがない場合はnullを返す
  }

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

  // 今日の作業時間をテキスト形式で取得するメソッド
  String getTodayDurationText(DateTime? time) {
    int todaySeconds = getDailyElapsedSeconds(time ?? DateTime.now());

    if (todaySeconds > 0) {
      // 登録されている時間を時間単位で取得して返す
      double hours = todaySeconds / 3600.0;
      return "${hours.toStringAsFixed(2)}h";
    } else {
      // 元の処理を行う
      var duration = getTodayDuration(time);
      int roundedMinutes = (duration.inMinutes / 15).ceil() * 15;
      double hours = roundedMinutes / 60.0;
      return "${hours.toStringAsFixed(2)}h";
    }
  }

  // 今日の作業時間をDouble形式で取得するメソッド
  double getTodayDurationDouble(DateTime? time) {
    String durationText = getTodayDurationText(time);
    // "h" を取り除く
    String numberPart = durationText.replaceAll('h', '');
    // 文字列を double に変換
    return double.tryParse(numberPart) ?? 0.0;
  }

  Duration getTodayDuration(DateTime? time) {
    Duration totalDuration = Duration.zero;
    DateTime now = time ?? DateTime.now();
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
        ? "実績:" + getTodayDurationText(DateTime.now())
        : text;
    return text == "" ? null : text;
  }

  // 日ごとの作業時間を更新するメソッド
  void updateDailyElapsedSeconds(DateTime date, String durationText) {
    int seconds = convertDurationTextToSeconds(durationText);
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    dailyElapsedSeconds.update(dateKey, (existingSeconds) => seconds, ifAbsent: () => seconds);
  }

  int convertDurationTextToSeconds(String durationText) {
    // "h" を取り除いて数値部分のみを取得
    String numberPart = durationText.replaceAll('h', '');

    // 数値部分を double に変換
    double hours = double.tryParse(numberPart) ?? 0.0;

    // 時間を秒に変換
    int seconds = (hours * 3600).toInt();

    return seconds;
  }

  // 日ごとの作業時間を取得するメソッド
  int getDailyElapsedSeconds(DateTime date) {
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    return dailyElapsedSeconds[dateKey] ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status.index,
        'isHeader': isHeader,
        'elapsedSecond': elapsedSecond,
        'isVisible': isVisible,
        'startTime': startTime?.toIso8601String(), // DateTimeをISO8601文字列に変換
        'detail': detail,
        'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
        'createTime': createTime.toIso8601String(),
        'dailyElapsedSeconds': dailyElapsedSeconds,
      };

  static Task fromJson(Map<String, dynamic> json) {
    var task = Task(
      json['name'].toString(),
      status: TaskStatus.values[json['status'] as int],
      isHeader: json['isHeader'] as bool,
      elapsedSecond: json['elapsedSecond'] as int,
      isVisible: json['isVisible'] as bool,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
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

    if (json['dailyElapsedSeconds'] != null) {
      task.dailyElapsedSeconds = (json['dailyElapsedSeconds'] as Map).map((key, value) {
        // 値をStringにキャストしてからintに変換します。
        // nullや他の非数値型の場合に備えて、エラーハンドリングも行います。
        int intValue;
        try {
          intValue = int.parse(value.toString());
        } catch (e) {
          intValue = 0; // 数値に変換できない場合は0を代入
        }
        return MapEntry(key as String, intValue);
      });
    }

    return task;
  }
}
