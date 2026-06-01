import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _SectionHeader(title: '알림'),
          SwitchListTile(
            title: const Text('알림 전체 on/off'),
            subtitle: const Text('모든 루틴 및 일정 알림'),
            value: true,
            onChanged: (v) {
              // TODO: 알림 설정 구현
            },
          ),
          const Divider(),
          const _SectionHeader(title: '앱 정보'),
          ListTile(
            title: const Text('버전'),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('개발자'),
            trailing: const Text('Chanhee'),
          ),
          ListTile(
            title: const Text('과목'),
            trailing: const Text('앱프로그래밍'),
          ),
        ],
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
