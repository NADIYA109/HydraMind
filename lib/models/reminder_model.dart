class ReminderModel {
  int id;
  int hour;
  int minute;
  bool isEnabled;
  bool isExpanded;
  List<int> days; // 1=Mon ... 7=Sun

  ReminderModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.isExpanded = false,
    this.days = const [1, 2, 3, 4, 5, 6, 7], // default everyday
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'days': days,
      'isEnabled': isEnabled,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      hour: json['hour'],
      minute: json['minute'],
      days: List<int>.from(json['days']),
      isEnabled: json['isEnabled'],
    );
  }
}
