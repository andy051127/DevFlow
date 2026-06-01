import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../application/view_models/schedule_view_model.dart';
import '../../../domain/entities/schedule.dart';

class ScheduleCalendarScreen extends ConsumerStatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  ConsumerState<ScheduleCalendarScreen> createState() =>
      _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState
    extends ConsumerState<ScheduleCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventMapAsync = ref.watch(scheduleEventMapProvider);
    final selectedKey =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedAsync = ref.watch(scheduleByDateProvider(selectedKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/schedule/edit');
              ref.invalidate(scheduleEventMapProvider);
              ref.invalidate(scheduleByDateProvider(selectedKey));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더
          eventMapAsync.when(
            data: (eventMap) => TableCalendar<Schedule>(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2027, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                final key = DateTime(day.year, day.month, day.day);
                return eventMap[key] ?? [];
              },
              calendarStyle: CalendarStyle(
                // 이벤트 마커
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
              },
            ),
            loading: () => const SizedBox(
              height: 380,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('오류: $e'),
          ),

          const Divider(height: 1),

          // 선택한 날짜 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('M월 d일 (E)', 'ko').format(_selectedDay),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('일정 추가'),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/schedule/edit');
                    ref.invalidate(scheduleEventMapProvider);
                    ref.invalidate(scheduleByDateProvider(selectedKey));
                  },
                ),
              ],
            ),
          ),

          // 선택 날짜의 일정 목록
          Expanded(
            child: selectedAsync.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return const Center(
                    child: Text('이 날의 일정이 없습니다.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: schedules.length,
                  itemBuilder: (context, i) =>
                      _CalendarScheduleTile(schedule: schedules[i],
                        onChanged: () {
                          ref.invalidate(scheduleEventMapProvider);
                          ref.invalidate(scheduleByDateProvider(selectedKey));
                          ref.invalidate(upcomingSchedulesProvider);
                        },
                      ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarScheduleTile extends ConsumerWidget {
  final Schedule schedule;
  final VoidCallback onChanged;

  const _CalendarScheduleTile(
      {required this.schedule, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = schedule.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: () async {
            await ref
                .read(scheduleViewModelProvider.notifier)
                .toggleComplete(schedule);
            onChanged();
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
        title: Text(
          schedule.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Theme.of(context).colorScheme.outline : null,
          ),
        ),
        subtitle: schedule.detail != null && schedule.detail!.isNotEmpty
            ? Text(schedule.detail!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12))
            : null,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.pushNamed(context, '/schedule/edit',
                  arguments: schedule);
              onChanged();
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
                onChanged();
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
      ),
    );
  }
}
