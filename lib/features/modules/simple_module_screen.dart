import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SimpleModuleScreen extends StatelessWidget {
  const SimpleModuleScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 46, color: AppColors.emeraldDark),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  color: AppColors.muted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'هذه شاشة تجريبية وسيتم ربطها بقاعدة البيانات في المرحلة التالية.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.emeraldDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
