import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/view_models/routine_view_model.dart';
import '../../../application/services/notification_service.dart';
import '../../../application/providers/notification_provider.dart';
import '../../../domain/entities/routine.dart';

class RoutineEditScreen extends ConsumerStatefulWidget {
  const RoutineEditScreen({super.key});

  @override
  ConsumerState<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends ConsumerState<RoutineEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();

  String _icon = '💻';
  String _color = 'FF2563EB';
  List<int> _repeatDays = [0, 1, 2, 3, 4]; // 월~금 기본
  TimeOfDay? _alarmTime;
  Routine? _existing;

  final _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  final _iconOptions = ['💻', '📚', '🏃', '✍️', '🎯', '🔧', '📊', '🧠'];
  final _colorOptions = [
    'FF2563EB', 'FF16A34A', 'FFDC2626',
    'FFD97706', 'FF7C3AED', 'FF0891B2',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Routine && _existing == null) {
      _existing = args;
      _nameController.text = args.name;
      _goalController.text = args.goal ?? '';
      _icon = args.icon;
      _color = args.color;
      _repeatDays = List.from(args.repeatDays);
      if (args.alarmTime != null) {
        final parts = args.alarmTime!.split(':');
        _alarmTime = TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final alarmStr = _alarmTime != null
        ? '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
        : null;

    final routine = Routine(
      id: _existing?.id,
      name: _nameController.text.trim(),
      icon: _icon,
      color: _color,
      repeatDays: _repeatDays,
      goal: _goalController.text.trim().isEmpty ? null : _goalController.text.trim(),
      alarmTime: alarmStr,
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );

    final vm = ref.read(routineViewModelProvider.notifier);
    if (_existing == null) {
      await vm.add(routine);
    } else {
      await vm.update(routine);
    }

    // 알림 전체 설정이 on일 때만 예약
    final notifEnabled = ref.read(notificationEnabledProvider);
    if (notifEnabled) {
      // id를 얻기 위해 저장 후 재조회 대신 routineId를 직접 사용
      final savedRoutine = routine.copyWith(id: routine.id ?? _existing?.id);
      await NotificationService.instance.scheduleRoutineNotifications(savedRoutine);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (_existing?.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('루틴 삭제'),
        content: const Text('이 루틴을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(routineViewModelProvider.notifier).delete(_existing!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '루틴 편집' : '루틴 추가'),
        actions: [
          if (isEdit)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 아이콘 선택
            Text('아이콘', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _iconOptions.map((icon) => GestureDetector(
                onTap: () => setState(() => _icon = icon),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _icon == icon
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: _icon == icon ? 2 : 1,
                    ),
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // 색상 선택
            Text('색상', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colorOptions.map((color) {
                final c = Color(int.parse(color, radix: 16));
                return GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == color ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: _color == color
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 루틴 이름
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '루틴 이름 *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? '이름을 입력하세요' : null,
            ),
            const SizedBox(height: 12),

            // 목표
            TextFormField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: '목표 (선택)',
                hintText: '이 루틴으로 달성하고 싶은 것',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // 반복 요일
            Text('반복 요일', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) => FilterChip(
                label: Text(_dayLabels[i]),
                selected: _repeatDays.contains(i),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _repeatDays.add(i);
                  } else {
                    _repeatDays.remove(i);
                  }
                }),
              )),
            ),
            const SizedBox(height: 16),

            // 알람 시간 선택
            Text('알람 시간 (선택)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.alarm, size: 18),
                  label: Text(_alarmTime == null
                      ? '시간 설정 안 함'
                      : _alarmTime!.format(context)),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _alarmTime ?? const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (picked != null) setState(() => _alarmTime = picked);
                  },
                ),
                if (_alarmTime != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    tooltip: '알람 해제',
                    onPressed: () => setState(() => _alarmTime = null),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(isEdit ? '저장' : '추가'),
            ),
          ],
        ),
      ),
    );
  }
}
