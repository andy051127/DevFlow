import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/routine/routine_edit_screen.dart';
import 'presentation/screens/schedule/schedule_edit_screen.dart';
import 'presentation/screens/stats/stats_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/theme/app_theme.dart';

class DevFlowApp extends StatelessWidget {
  const DevFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevFlow',
      theme: AppTheme.light,
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
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
