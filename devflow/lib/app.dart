import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/providers/notification_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/routine/routine_edit_screen.dart';
import 'presentation/screens/schedule/schedule_edit_screen.dart';
import 'presentation/screens/schedule/schedule_list_screen.dart';
import 'presentation/screens/schedule/schedule_calendar_screen.dart';
import 'presentation/screens/stats/stats_screen.dart';
import 'presentation/screens/achievement/achievement_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/theme/app_theme.dart';

class DevFlowApp extends ConsumerWidget {
  const DevFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'DevFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/routine/edit': (context) => const RoutineEditScreen(),
        '/schedule/edit': (context) => const ScheduleEditScreen(),
        '/stats': (context) => const StatsScreen(),
        '/schedule/list': (context) => const ScheduleListScreen(),
        '/schedule/calendar': (context) => const ScheduleCalendarScreen(),
        '/achievements': (context) => const AchievementScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
