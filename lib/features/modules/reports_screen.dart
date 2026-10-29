import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: FutureBuilder<DashboardStats>(
        future: AppDatabase.instance.getDashboardStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final stats = snapshot.data!;

          final cards = <_ReportCardData>[
            _ReportCardData(
              'مبيعات اليوم',
              stats.salesToday,
              Icons.point_of_sale_rounded,
            ),
            _ReportCardData(
              'مصروفات اليوم',
              stats.expensesToday,
              Icons.request_quote_rounded,
            ),
            _ReportCardData(
              'صافي اليوم',
              stats.netToday,
              Icons.trending_up_rounded,
            ),
            _ReportCardData(
              'رصيد الصندوق',
              stats.cashBalance,
              Icons.account_balance_wallet_rounded,
            ),
          ];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: cards
                    .map(
                      (item) => SizedBox(
                        width: 250,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                item.icon,
                                color: AppColors.emeraldDark,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                item.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                item.value.toStringAsFixed(0) + ' ر.ي',
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'أصناف منخفضة المخزون: ' +
                          stats.lowStockCount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportCardData {
  const _ReportCardData(
    this.label,
    this.value,
    this.icon,
  );

  final String label;
  final double value;
  final IconData icon;
}
