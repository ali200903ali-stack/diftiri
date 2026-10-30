import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_ui_preferences.dart';
import 'features/dashboard/dashboard_screen.dart';

class DiftiriApp extends StatelessWidget {
  const DiftiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = AppUiPreferences.instance;

    return AnimatedBuilder(
      animation: preferences,
      builder: (context, _) {
        return MaterialApp(
          title: 'دفتري المحاسبي',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(uiScale: preferences.uiScale),
          locale: const Locale('ar'),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  preferences.fontScale.clamp(.88, 1.28).toDouble(),
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: const DashboardScreen(),
        );
      },
    );
  }
}
