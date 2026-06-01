import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/routine.dart';
import '../../domain/services/streak_service.dart';
import '../../data/repositories/routine_repository.dart';

final routineRepositoryProvider = Provider((ref) => RoutineRepository());
final streakServiceProvider = Provider((ref) => StreakService());

// 전체 루틴 목록
final routineListProvider = FutureProvider<List<Routine>>((ref) async {
  return ref.read(routineRepositoryProvider).getAll();
});

// 오늘 완료된 루틴 ID 목록
final completedRoutineIdsProvider = FutureProvider<List<int>>((ref) async {
  return ref.read(routineRepositoryProvider).getCompletedRoutineIds(DateTime.now());
});

// 루틴별 스트릭
final routineStreakProvider = FutureProvider.family<int, int>((ref, routineId) async {
  final repo = ref.read(routineRepositoryProvider);
  final streakService = ref.read(streakServiceProvider);
  final dates = await repo.getCompletedDates(routineId);
  return streakService.calculate(dates);
});

class RoutineViewModel extends StateNotifier<AsyncValue<List<Routine>>> {
  final RoutineRepository _repo;
  final Ref _ref;

  RoutineViewModel(this._repo, this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final routines = await _repo.getAll();
      state = AsyncValue.data(routines);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Routine routine) async {
    await _repo.insert(routine);
    await load();
  }

  Future<void> update(Routine routine) async {
    await _repo.update(routine);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> toggleComplete(int routineId, bool isCompleted) async {
    final now = DateTime.now();
    if (isCompleted) {
      await _repo.unmarkComplete(routineId, now);
    } else {
      await _repo.markComplete(routineId, now);
    }
    _ref.invalidate(completedRoutineIdsProvider);
  }
}

final routineViewModelProvider =
    StateNotifierProvider<RoutineViewModel, AsyncValue<List<Routine>>>((ref) {
  return RoutineViewModel(ref.read(routineRepositoryProvider), ref);
});
