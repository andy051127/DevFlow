import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule.dart';

class UpcomingScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const UpcomingScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = schedule.date.difference(now).inDays;
    final label = diff == 0 ? '오늘' : diff == 1 ? '내일' : 'D-$diff';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(schedule.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(DateFormat('MM/dd (E)', 'ko').format(schedule.date)),
      ),
    );
  }
}
