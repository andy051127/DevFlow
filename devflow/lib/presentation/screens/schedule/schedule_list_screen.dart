import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/view_models/schedule_view_model.dart';
import '../../../domain/entities/schedule.dart';

class ScheduleListScreen extends ConsumerWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 일정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/schedule/edit');
              ref.invalidate(scheduleListProvider);
            },
          ),
        ],
      ),
      body: schedulesAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('등록된 일정이 없습니다.\n+ 버튼으로 추가해보세요!',
                    textAlign: TextAlign.center),
              ),
            );
          }

          // 미완료 / 완료 분리
          final upcoming = schedules.where((s) => !s.isCompleted).toList();
          final completed = schedules.where((s) => s.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(title: '예정 (${upcoming.length})'),
                const SizedBox(height: 8),
                ...upcoming.map((s) => _ScheduleListTile(schedule: s)),
                const SizedBox(height: 20),
              ],
              if (completed.isNotEmpty) ...[
                _SectionHeader(title: '완료 (${completed.length})'),
                const SizedBox(height: 8),
                ...completed.map((s) => _ScheduleListTile(schedule: s)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _ScheduleListTile extends ConsumerWidget {
  final Schedule schedule;
  const _ScheduleListTile({required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = schedule.isCompleted;
    final now = DateTime.now();
    final diff = schedule.date.difference(now).inDays;
    final dLabel = diff == 0
        ? '오늘'
        : diff == 1
            ? '내일'
            : diff < 0
                ? 'D+${-diff}'
                : 'D-$diff';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            dLabel,
            style: TextStyle(
              color: isCompleted
                  ? Theme.of(context).colorScheme.outline
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          schedule.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Theme.of(context).colorScheme.outline : null,
          ),
        ),
        subtitle: Text(
          DateFormat('yyyy.MM.dd (E)', 'ko').format(schedule.date),
          style: TextStyle(
            fontSize: 12,
            color: isCompleted ? Theme.of(context).colorScheme.outline : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 완료 체크 버튼
            GestureDetector(
              onTap: () {
                ref
                    .read(scheduleViewModelProvider.notifier)
                    .toggleComplete(schedule);
                ref.invalidate(scheduleListProvider);
                ref.invalidate(upcomingSchedulesProvider);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            // 수정/삭제 메뉴
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) async {
                if (value == 'edit') {
                  await Navigator.pushNamed(context, '/schedule/edit',
                      arguments: schedule);
                  ref.invalidate(scheduleListProvider);
                  ref.invalidate(upcomingSchedulesProvider);
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('일정 삭제'),
                      content: Text('"${schedule.name}"을 삭제할까요?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('취소')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('삭제',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref
                        .read(scheduleViewModelProvider.notifier)
                        .delete(schedule.id!);
                    ref.invalidate(scheduleListProvider);
                    ref.invalidate(upcomingSchedulesProvider);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('수정')),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('삭제', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
