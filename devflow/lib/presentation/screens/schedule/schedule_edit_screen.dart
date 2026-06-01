import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/view_models/schedule_view_model.dart';
import '../../../domain/entities/schedule.dart';

class ScheduleEditScreen extends ConsumerStatefulWidget {
  const ScheduleEditScreen({super.key});

  @override
  ConsumerState<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends ConsumerState<ScheduleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Schedule? _existing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Schedule && _existing == null) {
      _existing = args;
      _nameController.text = args.name;
      _detailController.text = args.detail ?? '';
      _selectedDate = args.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final schedule = Schedule(
      id: _existing?.id,
      name: _nameController.text.trim(),
      date: _selectedDate,
      detail: _detailController.text.trim().isEmpty ? null : _detailController.text.trim(),
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );

    final vm = ref.read(scheduleViewModelProvider.notifier);
    if (_existing == null) {
      await vm.add(schedule);
    } else {
      await vm.update(schedule);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (_existing?.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(scheduleViewModelProvider.notifier).delete(_existing!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '일정 편집' : '일정 추가'),
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '일정 이름 *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? '이름을 입력하세요' : null,
            ),
            const SizedBox(height: 12),

            // 날짜 선택
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '날짜',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _detailController,
              decoration: const InputDecoration(
                labelText: '세부사항 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(isEdit ? '저장' : '추가'),
            ),
          ],
        ),
      ),
    );
  }
}
