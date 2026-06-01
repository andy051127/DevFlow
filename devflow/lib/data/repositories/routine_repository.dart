import '../local/database_helper.dart';
import '../../domain/entities/routine.dart';

class RoutineRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Routine>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('routines', orderBy: 'created_at DESC');
    return maps.map(Routine.fromMap).toList();
  }

  Future<Routine> insert(Routine routine) async {
    final db = await _db.database;
    final id = await db.insert('routines', routine.toMap());
    return routine.copyWith(id: id);
  }

  Future<void> update(Routine routine) async {
    final db = await _db.database;
    await db.update(
      'routines',
      routine.toMap(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  // 오늘 완료한 루틴 ID 목록
  Future<List<int>> getCompletedRoutineIds(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'routine_logs',
      where: "completed_at LIKE ?",
      whereArgs: ['$dateStr%'],
    );
    return maps.map((m) => m['routine_id'] as int).toList();
  }

  // 루틴 완료 체크
  Future<void> markComplete(int routineId, DateTime date) async {
    final db = await _db.database;
    await db.insert('routine_logs', {
      'routine_id': routineId,
      'completed_at': date.toIso8601String(),
    });
  }

  // 루틴 완료 취소
  Future<void> unmarkComplete(int routineId, DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().substring(0, 10);
    await db.delete(
      'routine_logs',
      where: "routine_id = ? AND completed_at LIKE ?",
      whereArgs: [routineId, '$dateStr%'],
    );
  }

  // 스트릭 계산용 — 특정 루틴의 모든 완료 날짜
  Future<List<DateTime>> getCompletedDates(int routineId) async {
    final db = await _db.database;
    final maps = await db.query(
      'routine_logs',
      where: 'routine_id = ?',
      whereArgs: [routineId],
      orderBy: 'completed_at DESC',
    );
    return maps
        .map((m) => DateTime.parse(m['completed_at'] as String))
        .toList();
  }
}
