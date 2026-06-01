import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/routine.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // 알림 채널 설정 (Android 8.0+)
  static const _channel = AndroidNotificationDetails(
    'devflow_routine',
    '루틴 알림',
    channelDescription: '설정한 시간에 오늘의 루틴을 알려드립니다.',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> init() async {
    // timezone 초기화 (한국 표준시 KST = UTC+9 고정)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Android 13+ 알림 권한 요청
    await androidPlugin?.requestNotificationsPermission();

    // Android 12+ 정확한 알람 권한 요청
    await androidPlugin?.requestExactAlarmsPermission();

  }

  /// 루틴의 repeatDays × alarmTime 조합으로 알림 예약
  /// 알람이 없거나 repeatDays가 비어 있으면 아무것도 하지 않음
  Future<void> scheduleRoutineNotifications(Routine routine) async {
    if (routine.id == null) return;
    if (routine.alarmTime == null || routine.alarmTime!.isEmpty) return;

    final parts = routine.alarmTime!.split(':');
    if (parts.length != 2) return;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    // 기존 알림 먼저 취소
    await cancelRoutineNotifications(routine.id!);

    for (final day in routine.repeatDays) {
      // flutter_local_notifications의 요일: 1=월 ~ 7=일 (ISO 8601과 동일)
      final isoWeekday = day + 1; // 0=월 → 1
      final notifId = routine.id! * 10 + day;

      final scheduledDate =
          _nextWeekdayAt(isoWeekday, hour, minute);

      await _plugin.zonedSchedule(
        notifId,
        '${routine.icon} ${routine.name}',
        routine.goal ?? '오늘의 루틴을 완료해보세요!',
        scheduledDate,
        const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// 루틴에 연결된 모든 알림 취소 (요일 0~6 각각)
  Future<void> cancelRoutineNotifications(int routineId) async {
    for (int day = 0; day < 7; day++) {
      await _plugin.cancel(routineId * 10 + day);
    }
  }

  /// 앱의 모든 알림 취소
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// 즉시 알림 (테스트용)
  Future<void> showTestNotification() async {
    await _plugin.show(
      9999,
      '🔔 DevFlow 알림 테스트',
      '알림이 정상적으로 동작합니다!',
      const NotificationDetails(android: _channel),
    );
  }

  /// 지정한 ISO 요일(1=월 ~ 7=일)의 다음 발생 시각 반환
  tz.TZDateTime _nextWeekdayAt(int isoWeekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    // 오늘 같은 요일이고 아직 시각이 안 지났으면 오늘, 아니면 다음 주
    while (candidate.weekday != isoWeekday || candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
