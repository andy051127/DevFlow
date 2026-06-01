import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/view_models/stats_view_model.dart';
import '../../../domain/entities/achievement.dart';

class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('업적')),
      body: achievementsAsync.when(
        data: (achievements) {
          final unlocked = achievements.where((a) => a.isUnlocked).toList();
          final locked = achievements.where((a) => !a.isUnlocked).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 달성 현황 요약
              _SummaryCard(
                  unlocked: unlocked.length, total: achievements.length),
              const SizedBox(height: 24),

              if (unlocked.isNotEmpty) ...[
                _SectionLabel(title: '달성 완료 (${unlocked.length})'),
                const SizedBox(height: 8),
                ...unlocked.map((a) => _AchievementCard(achievement: a)),
                const SizedBox(height: 20),
              ],

              _SectionLabel(title: '도전 중 (${locked.length})'),
              const SizedBox(height: 8),
              ...locked.map((a) => _AchievementCard(achievement: a)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int unlocked;
  final int total;
  const _SummaryCard({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$unlocked / $total 달성',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              Text(
                unlocked == total ? '모든 업적을 달성했습니다!' : '계속 도전하세요!',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: unlocked
              ? Colors.amber.shade100
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            unlocked ? '🏆' : '🔒',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: unlocked ? null : Theme.of(context).colorScheme.outline,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: unlocked
                    ? null
                    : Theme.of(context).colorScheme.outlineVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            _StreakProgress(achievement: achievement),
          ],
        ),
        trailing: unlocked
            ? const Icon(Icons.check_circle, color: Colors.amber)
            : Text(
                '${achievement.requiredStreak}일',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12),
              ),
        isThreeLine: true,
      ),
    );
  }
}

class _StreakProgress extends StatelessWidget {
  final Achievement achievement;
  const _StreakProgress({required this.achievement});

  @override
  Widget build(BuildContext context) {
    if (achievement.isUnlocked) {
      return Text(
        '달성!',
        style: TextStyle(
            color: Colors.amber.shade700,
            fontSize: 11,
            fontWeight: FontWeight.bold),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0, // 현재 스트릭은 카드에서 알 수 없으므로 0 표시
              minHeight: 4,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${achievement.requiredStreak}일 연속 필요',
          style: TextStyle(
              fontSize: 10, color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
  }
}
