import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/view_models/routine_view_model.dart';
import '../../../application/view_models/schedule_view_model.dart';
import '../../../application/view_models/stats_view_model.dart';
import '../../../domain/entities/routine.dart';
import '../../../domain/services/achievement_service.dart';
import '../../widgets/routine_card.dart';
import '../../widgets/upcoming_schedule_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routineViewModelProvider);
    final completedIdsAsync = ref.watch(completedRoutineIdsProvider);
    final upcomingAsync = ref.watch(upcomingSchedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DevFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(routineViewModelProvider);
          ref.invalidate(completedRoutineIdsProvider);
          ref.invalidate(upcomingSchedulesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 다가오는 일정 요약
            upcomingAsync.when(
              data: (schedules) => schedules.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('다가오는 일정',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    )),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.calendar_month, size: 20),
                                  tooltip: '캘린더',
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/schedule/calendar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/schedule/list'),
                                  child: const Text('전체 보기'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...schedules.take(2).map((s) => UpcomingScheduleCard(schedule: s)),
                        const SizedBox(height: 20),
                      ],
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // 오늘의 루틴
            Text('오늘의 루틴',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 8),

            routinesAsync.when(
              data: (routines) {
                // 오늘 요일 필터
                final todayWeekday = DateTime.now().weekday - 1; // 0=월
                final todayRoutines = routines
                    .where((r) => r.repeatDays.contains(todayWeekday))
                    .toList();

                if (todayRoutines.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('오늘 할 루틴이 없습니다.\n루틴을 추가해보세요!',
                          textAlign: TextAlign.center),
                    ),
                  );
                }

                return completedIdsAsync.when(
                  data: (completedIds) => Column(
                    children: [
                      // 진행률 바
                      _ProgressBar(
                        completed: completedIds
                            .where((id) => todayRoutines.any((r) => r.id == id))
                            .length,
                        total: todayRoutines.length,
                      ),
                      const SizedBox(height: 12),
                      ...todayRoutines.map((routine) {
                            final streakAsync = ref.watch(routineStreakProvider(routine.id!));
                            return RoutineCard(
                              routine: routine,
                              isCompleted: completedIds.contains(routine.id),
                              streak: streakAsync.valueOrNull ?? 0,
                              onToggle: () => _toggleWithAchievementCheck(
                                    context, ref, routine, completedIds,
                                  ),
                              onEdit: () => Navigator.pushNamed(
                                context,
                                '/routine/edit',
                                arguments: routine,
                              ),
                            );
                          }),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('오류: $e'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'schedule',
            onPressed: () => Navigator.pushNamed(context, '/schedule/edit'),
            child: const Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'routine',
            onPressed: () => Navigator.pushNamed(context, '/routine/edit'),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

Future<void> _toggleWithAchievementCheck(
  BuildContext context,
  WidgetRef ref,
  Routine routine,
  List<int> completedIds,
) async {
  final isCompleted = completedIds.contains(routine.id);

  // 완료로 바꾸는 경우만 업적 체크 (해제할 때는 체크 불필요)
  if (!isCompleted) {
    final before = await ref.read(achievementProvider.future);
    await ref.read(routineViewModelProvider.notifier).toggleComplete(routine.id!, false);
    // 스트릭 캐시 무효화 후 재계산
    ref.invalidate(routineStreakProvider(routine.id!));
    final after = await ref.read(achievementProvider.future);

    final newlyUnlocked = AchievementService().getNewlyUnlocked(before, after);
    if (newlyUnlocked.isNotEmpty && context.mounted) {
      _showAchievementDialog(context, newlyUnlocked.first.title);
    }
  } else {
    await ref.read(routineViewModelProvider.notifier).toggleComplete(routine.id!, true);
  }
}

void _showAchievementDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Text('🏆 ', style: TextStyle(fontSize: 24)),
          Text('업적 달성!'),
        ],
      ),
      content: Text(
        '"$title" 업적을 달성했습니다!\n꾸준함이 빛을 발하고 있어요.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('확인'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.pushNamed(context, '/achievements');
          },
          child: const Text('업적 보기'),
        ),
      ],
    ),
  );
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 $completed / $total 완료',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
