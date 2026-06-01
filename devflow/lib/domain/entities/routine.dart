class Routine {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final List<int> repeatDays; // 0=월, 1=화, ..., 6=일
  final String? goal;
  final String? alarmTime;
  final DateTime createdAt;

  Routine({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.repeatDays,
    this.goal,
    this.alarmTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'repeat_days': repeatDays.join(','),
      'goal': goal,
      'alarm_time': alarmTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      repeatDays: (map['repeat_days'] as String)
          .split(',')
          .map(int.parse)
          .toList(),
      goal: map['goal'],
      alarmTime: map['alarm_time'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Routine copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    List<int>? repeatDays,
    String? goal,
    String? alarmTime,
    DateTime? createdAt,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      repeatDays: repeatDays ?? this.repeatDays,
      goal: goal ?? this.goal,
      alarmTime: alarmTime ?? this.alarmTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
