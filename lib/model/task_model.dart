enum TaskStatus { newTask, inProgress, completed, paused }

class Task {
  final String name;
  int elapsedSeconds;
  TaskStatus status;

  Task(this.name, {this.elapsedSeconds = 0, this.status = TaskStatus.newTask});

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status.index,
        'elapsedTime': elapsedSeconds,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        json['name'].toString(),
        status: TaskStatus.values[json['status'] as int],
        elapsedSeconds: json['elapsedSeconds'] as int,
      );
}
