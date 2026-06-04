class InterviewStory {
  final String id;
  final String title;
  final String situation;
  final String task;
  final String action;
  final String result;
  final DateTime lastModified;

  InterviewStory({
    required this.id,
    required this.title,
    required this.situation,
    required this.task,
    required this.action,
    required this.result,
    required this.lastModified,
  });

  InterviewStory copyWith({
    String? title,
    String? situation,
    String? task,
    String? action,
    String? result,
  }) {
    return InterviewStory(
      id: id,
      title: title ?? this.title,
      situation: situation ?? this.situation,
      task: task ?? this.task,
      action: action ?? this.action,
      result: result ?? this.result,
      lastModified: DateTime.now(),
    );
  }
}
