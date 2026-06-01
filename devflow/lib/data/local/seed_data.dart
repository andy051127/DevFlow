import 'database_helper.dart';

class SeedData {
  static Future<void> insert() async {
    final db = await DatabaseHelper.instance.database;

    // 이미 데이터가 있으면 스킵
    final existing = await db.query('routines');
    if (existing.isNotEmpty) return;

    final now = DateTime.now();

    // 루틴 3개 삽입
    await db.insert('routines', {
      'name': '알고리즘 풀기',
      'icon': '💻',
      'color': 'FF2563EB',
      'repeat_days': '0,1,2,3,4',
      'goal': '코딩 테스트 합격',
      'alarm_time': null,
      'created_at': now.subtract(const Duration(days: 35)).toIso8601String(),
    });

    await db.insert('routines', {
      'name': '기술 블로그 읽기',
      'icon': '📚',
      'color': 'FF16A34A',
      'repeat_days': '0,1,2,3,4,5,6',
      'goal': '최신 기술 트렌드 파악',
      'alarm_time': null,
      'created_at': now.subtract(const Duration(days: 35)).toIso8601String(),
    });

    await db.insert('routines', {
      'name': '사이드 프로젝트',
      'icon': '🎯',
      'color': 'FF7C3AED',
      'repeat_days': '0,2,4',
      'goal': '포트폴리오 완성',
      'alarm_time': null,
      'created_at': now.subtract(const Duration(days: 35)).toIso8601String(),
    });

    // 30일치 달성 로그 삽입
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final weekday = date.weekday - 1; // 0=월

      // 루틴 1 (월~금): 평일만, 80% 달성률
      if ([0, 1, 2, 3, 4].contains(weekday) && i % 5 != 0) {
        await db.insert('routine_logs', {
          'routine_id': 1,
          'completed_at': date.toIso8601String(),
        });
      }

      // 루틴 2 (매일): 90% 달성률
      if (i % 10 != 0) {
        await db.insert('routine_logs', {
          'routine_id': 2,
          'completed_at': date.toIso8601String(),
        });
      }

      // 루틴 3 (월수금): 70% 달성률
      if ([0, 2, 4].contains(weekday) && i % 4 != 0) {
        await db.insert('routine_logs', {
          'routine_id': 3,
          'completed_at': date.toIso8601String(),
        });
      }
    }

    // 일정 5개 삽입
    await db.insert('schedules', {
      'name': '포트폴리오 제출',
      'date': now.add(const Duration(days: 3)).toIso8601String(),
      'detail': '취업 지원용 포트폴리오 최종 제출',
      'is_completed': 0,
      'linked_routine_id': 3,
      'created_at': now.toIso8601String(),
    });

    await db.insert('schedules', {
      'name': '코딩 테스트',
      'date': now.add(const Duration(days: 7)).toIso8601String(),
      'detail': '카카오 코딩 테스트 응시',
      'is_completed': 0,
      'linked_routine_id': 1,
      'created_at': now.toIso8601String(),
    });

    await db.insert('schedules', {
      'name': '기술 면접 준비 마감',
      'date': now.add(const Duration(days: 14)).toIso8601String(),
      'detail': 'CS 기초 + 프로젝트 설명 준비',
      'is_completed': 0,
      'linked_routine_id': null,
      'created_at': now.toIso8601String(),
    });

    await db.insert('schedules', {
      'name': 'Flutter 스터디 발표',
      'date': now.add(const Duration(days: 1)).toIso8601String(),
      'detail': 'Riverpod 상태관리 발표',
      'is_completed': 0,
      'linked_routine_id': null,
      'created_at': now.toIso8601String(),
    });

    await db.insert('schedules', {
      'name': '앱 기말 발표',
      'date': now.add(const Duration(days: 21)).toIso8601String(),
      'detail': 'DevFlow 최종 발표',
      'is_completed': 0,
      'linked_routine_id': null,
      'created_at': now.toIso8601String(),
    });
  }
}
