class Achievement {
  final String id;
  final String title;
  final String description;
  final int requiredStreak;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredStreak,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      requiredStreak: requiredStreak,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  // 미리 정의된 업적 목록
  static List<Achievement> get defaults => [
    Achievement(
      id: 'streak_7',
      title: '7일 연속',
      description: '7일 연속으로 루틴을 달성했습니다.',
      requiredStreak: 7,
    ),
    Achievement(
      id: 'streak_30',
      title: '30일 연속',
      description: '30일 연속으로 루틴을 달성했습니다.',
      requiredStreak: 30,
    ),
    Achievement(
      id: 'streak_100',
      title: '100일 연속',
      description: '100일 연속으로 루틴을 달성했습니다.',
      requiredStreak: 100,
    ),
  ];
}
