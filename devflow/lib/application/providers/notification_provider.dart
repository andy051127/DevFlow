import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// 알림 전체 on/off 상태 (앱 내 메모리 유지)
final notificationEnabledProvider = StateProvider<bool>((ref) => true);

/// 다크모드 상태
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// 전체 알림 비활성화 시 호출
Future<void> disableAllNotifications() async {
  await NotificationService.instance.cancelAll();
}
