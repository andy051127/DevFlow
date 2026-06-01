import '../local/database_helper.dart';
import '../../domain/entities/schedule.dart';

class ScheduleRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Schedule>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('schedules', orderBy: 'date ASC');
    return maps.map(Schedule.fromMap).toList();
  }

  Future<List<Schedule>> getByDate(DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'schedules',
      where: "date LIKE ?",
      whereArgs: ['$dateStr%'],
      orderBy: 'date ASC',
    );
    return maps.map(Schedule.fromMap).toList();
  }

  Future<List<Schedule>> getUpcoming() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String().substring(0, 10);
    final maps = await db.query(
      'schedules',
      where: "date >= ? AND is_completed = 0",
      whereArgs: [now],
      orderBy: 'date ASC',
      limit: 5,
    );
    return maps.map(Schedule.fromMap).toList();
  }

  Future<Schedule> insert(Schedule schedule) async {
    final db = await _db.database;
    final id = await db.insert('schedules', schedule.toMap());
    return schedule.copyWith(id: id);
  }

  Future<void> update(Schedule schedule) async {
    final db = await _db.database;
    await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleComplete(Schedule schedule) async {
    await update(schedule.copyWith(isCompleted: !schedule.isCompleted));
  }
}
