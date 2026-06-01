import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule.dart';
import '../../data/repositories/schedule_repository.dart';

final scheduleRepositoryProvider = Provider((ref) => ScheduleRepository());

// 전체 일정 목록
final scheduleListProvider = FutureProvider<List<Schedule>>((ref) async {
  return ref.read(scheduleRepositoryProvider).getAll();
});

// 다가오는 일정 (홈 화면 요약용)
final upcomingSchedulesProvider = FutureProvider<List<Schedule>>((ref) async {
  return ref.read(scheduleRepositoryProvider).getUpcoming();
});

class ScheduleViewModel extends StateNotifier<AsyncValue<List<Schedule>>> {
  final ScheduleRepository _repo;

  ScheduleViewModel(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _repo.getAll();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Schedule schedule) async {
    await _repo.insert(schedule);
    await load();
  }

  Future<void> update(Schedule schedule) async {
    await _repo.update(schedule);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> toggleComplete(Schedule schedule) async {
    await _repo.toggleComplete(schedule);
    await load();
  }
}

final scheduleViewModelProvider =
    StateNotifierProvider<ScheduleViewModel, AsyncValue<List<Schedule>>>((ref) {
  return ScheduleViewModel(ref.read(scheduleRepositoryProvider));
});
