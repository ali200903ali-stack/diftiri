import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/theme/app_ui_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.initialize();
  await AppUiPreferences.instance.load();
  runApp(const DiftiriApp());
}
