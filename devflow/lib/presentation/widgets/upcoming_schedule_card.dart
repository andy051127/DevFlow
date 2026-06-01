import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule.dart';
import '../../application/view_models/schedule_view_model.dart';

class UpcomingScheduleCard extends ConsumerWidget {
  final Schedule schedule;

  const UpcomingScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final diff = schedule.date.difference(now).inDays;
    final label = diff == 0 ? '오늘' : diff == 1 ? '내일' : 'D-$diff';
    final isCompleted = schedule.isCompleted;

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
            label,
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
          DateFormat('MM/dd (E)', 'ko').format(schedule.date),
          style: TextStyle(
            color: isCompleted ? Theme.of(context).colorScheme.outline : null,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            ref
                .read(scheduleViewModelProvider.notifier)
                .toggleComplete(schedule);
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
      ),
    );
  }
}
