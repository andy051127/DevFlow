import '../entities/achievement.dart';

class AchievementService {
  List<Achievement> evaluate(int currentStreak) {
    return Achievement.defaults.map((a) {
      if (!a.isUnlocked && currentStreak >= a.requiredStreak) {
        return a.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return a;
    }).toList();
  }

  // 새로 달성된 업적만 반환
  List<Achievement> getNewlyUnlocked(
    List<Achievement> before,
    List<Achievement> after,
  ) {
    return after.where((a) {
      final prev = before.firstWhere((b) => b.id == a.id);
      return a.isUnlocked && !prev.isUnlocked;
    }).toList();
  }
}
