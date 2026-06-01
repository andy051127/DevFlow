class StreakService {
  // 연속 달성일 계산
  int calculate(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    final dates = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // 최신순 정렬

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // 오늘 또는 어제부터 시작하지 않으면 스트릭 0
    if (dates.first.isBefore(todayNormalized.subtract(const Duration(days: 1)))) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // 히트맵용 — 날짜별 달성 횟수 맵
  Map<DateTime, int> buildHeatmap(List<DateTime> completedDates) {
    final map = <DateTime, int>{};
    for (final date in completedDates) {
      final key = DateTime(date.year, date.month, date.day);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }
}
