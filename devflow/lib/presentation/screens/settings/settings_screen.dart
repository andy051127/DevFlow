import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/notification_provider.dart';
import '../../../application/services/notification_service.dart';
import '../../../application/view_models/routine_view_model.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifEnabled = ref.watch(notificationEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _SectionHeader(title: '알림'),
          SwitchListTile(
            title: const Text('알림 전체 on/off'),
            subtitle: const Text('모든 루틴 알림'),
            value: notifEnabled,
            onChanged: (enabled) async {
              ref.read(notificationEnabledProvider.notifier).state = enabled;

              if (!enabled) {
                // 전체 알림 취소
                await NotificationService.instance.cancelAll();
              } else {
                // 알람 시간이 설정된 루틴 전부 재예약
                final routinesAsync = ref.read(routineViewModelProvider);
                routinesAsync.whenData((routines) async {
                  for (final r in routines) {
                    if (r.alarmTime != null && r.alarmTime!.isNotEmpty) {
                      await NotificationService.instance
                          .scheduleRoutineNotifications(r);
                    }
                  }
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('알림이 활성화되었습니다.')),
                  );
                }
              }
            },
          ),
          ListTile(
            title: const Text('알림 즉시 테스트'),
            subtitle: const Text('버튼을 누르면 바로 알림이 옵니다'),
            trailing: const Icon(Icons.send_outlined),
            onTap: () => NotificationService.instance.showTestNotification(),
          ),
          ListTile(
            title: const Text('배터리 최적화 안내'),
            subtitle: const Text('예약 알림이 안 오면 여기를 확인하세요'),
            trailing: const Icon(Icons.battery_alert_outlined),
            onTap: () => _showBatteryGuideDialog(context),
          ),
          const Divider(),
          const _SectionHeader(title: '화면'),
          _ThemeSelector(),
          const Divider(),
          const _SectionHeader(title: '앱 정보'),
          const ListTile(
            title: Text('버전'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            title: Text('개발자'),
            trailing: Text('Chanhee'),
          ),
          const ListTile(
            title: Text('과목'),
            trailing: Text('앱프로그래밍'),
          ),
        ],
      ),
    );
  }
}

void _showBatteryGuideDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('배터리 최적화 해제'),
      content: const Text(
        '삼성 기기는 배터리 최적화로 인해 예약 알림이 차단될 수 있습니다.\n\n'
        '해제 방법:\n'
        '1. 기기 설정 앱 열기\n'
        '2. 배터리 → 백그라운드 앱 제한\n'
        '3. DevFlow → "제한 없음" 선택\n\n'
        '또는:\n'
        '설정 → 앱 → DevFlow → 배터리 → 제한 없음',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

class _ThemeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
            label: Text('라이트'),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto),
            label: Text('시스템'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
            label: Text('다크'),
          ),
        ],
        selected: {current},
        onSelectionChanged: (value) {
          ref.read(themeModeProvider.notifier).state = value.first;
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
