import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local/seed_data.dart';
import 'application/services/notification_service.dart';
import 'application/services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SeedData.insert();
  await NotificationService.instance.init();
  await WidgetService.instance.init();
  await WidgetService.instance.updateWidget();
  runApp(const ProviderScope(child: DevFlowApp()));
}
