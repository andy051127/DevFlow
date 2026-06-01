class Schedule {
  final int? id;
  final String name;
  final DateTime date;
  final String? detail;
  final bool isCompleted;
  final int? linkedRoutineId;
  final DateTime createdAt;

  Schedule({
    this.id,
    required this.name,
    required this.date,
    this.detail,
    this.isCompleted = false,
    this.linkedRoutineId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'detail': detail,
      'is_completed': isCompleted ? 1 : 0,
      'linked_routine_id': linkedRoutineId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      detail: map['detail'],
      isCompleted: map['is_completed'] == 1,
      linkedRoutineId: map['linked_routine_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Schedule copyWith({
    int? id,
    String? name,
    DateTime? date,
    String? detail,
    bool? isCompleted,
    int? linkedRoutineId,
    DateTime? createdAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      detail: detail ?? this.detail,
      isCompleted: isCompleted ?? this.isCompleted,
      linkedRoutineId: linkedRoutineId ?? this.linkedRoutineId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
