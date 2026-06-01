import 'package:home_widget/home_widget.dart';
import '../../data/repositories/routine_repository.dart';
import '../../domain/services/streak_service.dart';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const _appGroupId = 'com.devflow.devflow';
  static const _widgetName = 'DevFlowWidgetProvider';

  Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// 오늘 루틴 완료 현황을 위젯에 반영
  Future<void> updateWidget() async {
    try {
      final repo = RoutineRepository();
      final streakService = StreakService();

      final routines = await repo.getAll();
      final completedIds = await repo.getCompletedRoutineIds(DateTime.now());

      final todayWeekday = DateTime.now().weekday - 1; // 0=월
      final todayRoutines =
          routines.where((r) => r.repeatDays.contains(todayWeekday)).toList();

      final completed = completedIds
          .where((id) => todayRoutines.any((r) => r.id == id))
          .length;
      final total = todayRoutines.length;

      // 최고 스트릭 계산
      int maxStreak = 0;
      for (final r in routines) {
        if (r.id == null) continue;
        final dates = await repo.getCompletedDates(r.id!);
        final s = streakService.calculate(dates);
        if (s > maxStreak) maxStreak = s;
      }

      await HomeWidget.saveWidgetData('completed', completed);
      await HomeWidget.saveWidgetData('total', total);
      await HomeWidget.saveWidgetData('max_streak', maxStreak);
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
    } catch (_) {
      // 위젯 업데이트 실패는 앱 동작에 영향 없음
    }
  }
}
