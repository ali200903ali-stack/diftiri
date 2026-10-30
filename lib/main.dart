import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_ui_preferences.dart';
import 'core/ui/diftiri_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DiftiriBootstrap());
}

class DiftiriBootstrap extends StatefulWidget {
  const DiftiriBootstrap({super.key});

  @override
  State<DiftiriBootstrap> createState() =>
      _DiftiriBootstrapState();
}

class _DiftiriBootstrapState extends State<DiftiriBootstrap> {
  late Future<void> startup;

  @override
  void initState() {
    super.initState();
    startup = _initialize();
  }

  Future<void> _initialize() async {
    await AppDatabase.instance.initialize();
    await AppUiPreferences.instance.load();
  }

  void _retry() {
    setState(() {
      startup = _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState !=
            ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _StartupLoading(),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: const Locale('ar'),
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            ),
            home: _StartupFailure(
              error: snapshot.error.toString(),
              onRetry: _retry,
            ),
          );
        }

        return const DiftiriApp();
      },
    );
  }
}

class _StartupLoading extends StatelessWidget {
  const _StartupLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DiftiriBrandLogo(
                width: 220,
                height: 82,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text(
                'جاري فتح دفتري المحاسبي',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupFailure extends StatelessWidget {
  const _StartupFailure({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16123E63),
                      blurRadius: 28,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const DiftiriBrandLogo(
                      width: 220,
                      height: 82,
                      alignment: Alignment.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEC),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تعذر بدء النظام',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لم يتم إغلاق التطبيق. يمكنك إعادة المحاولة، وإذا استمرت المشكلة أرسل نص الخطأ الظاهر هنا.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SelectableText(
                        error,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'إعادة المحاولة',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
