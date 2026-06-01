import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/view_models/stats_view_model.dart';
import '../../../application/view_models/routine_view_model.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final routinesAsync = ref.watch(routineViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: statsAsync.when(
        data: (stats) {
          final heatmap = stats['heatmap'] as Map<DateTime, int>;
          final streaks = stats['streaks'] as Map<int, int>;
          final totalDays = stats['totalDays'] as int;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 총 달성일
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('$totalDays',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              )),
                      const Text('총 달성일'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 히트맵
              Text('달성 히트맵',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 8),
              _HeatmapWidget(heatmap: heatmap),
              const SizedBox(height: 20),

              // 루틴별 스트릭
              Text('루틴별 스트릭',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 8),
              routinesAsync.when(
                data: (routines) => Column(
                  children: routines.map((r) {
                    final streak = streaks[r.id] ?? 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(r.icon, style: const TextStyle(fontSize: 24)),
                        title: Text(r.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange),
                            Text('$streak일',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('오류: $e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
}

class _HeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> heatmap;

  const _HeatmapWidget({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weeks = <List<DateTime?>>[];
    var current = now.subtract(Duration(days: now.weekday - 1 + 7 * 11));

    for (int w = 0; w < 12; w++) {
      final week = <DateTime?>[];
      for (int d = 0; d < 7; d++) {
        week.add(current);
        current = current.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    return SizedBox(
      height: 120,
      child: Row(
        children: weeks.map((week) => Column(
          children: week.map((date) {
            if (date == null) return const SizedBox(width: 14, height: 14);
            final key = DateTime(date.year, date.month, date.day);
            final count = heatmap[key] ?? 0;
            final opacity = count == 0 ? 0.1 : (count / 5).clamp(0.2, 1.0);
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha((opacity * 255).toInt()),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        )).toList(),
      ),
    );
  }
}
