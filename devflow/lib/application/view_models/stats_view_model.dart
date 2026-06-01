import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/streak_service.dart';
import '../../data/repositories/routine_repository.dart';
import 'routine_view_model.dart';

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(routineRepositoryProvider);
  final streakService = ref.read(streakServiceProvider);
  final routines = await repo.getAll();

  // 전체 완료 날짜 수집 (히트맵용)
  final allDates = <DateTime>[];
  final streaks = <int, int>{};

  for (final routine in routines) {
    if (routine.id == null) continue;
    final dates = await repo.getCompletedDates(routine.id!);
    allDates.addAll(dates);
    streaks[routine.id!] = streakService.calculate(dates);
  }

  final heatmap = streakService.buildHeatmap(allDates);
  final totalDays = allDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().length;

  return {
    'heatmap': heatmap,
    'streaks': streaks,
    'totalDays': totalDays,
  };
});
