import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SeedData.insert();
  runApp(const ProviderScope(child: DevFlowApp()));
}
