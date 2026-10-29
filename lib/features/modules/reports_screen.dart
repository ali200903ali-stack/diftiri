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

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final phone = width < 600;
              final horizontalPadding = phone ? 16.0 : 24.0;
              final gap = 12.0;
              final cardWidth = phone
                  ? (width - horizontalPadding * 2 - gap) / 2
                  : 250.0;

              return ListView(
                padding: EdgeInsets.all(horizontalPadding),
                children: [
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: cards
                        .map(
                          (item) => SizedBox(
                            width: cardWidth,
                            child: _ReportCard(
                              data: item,
                              compact: phone,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: EdgeInsets.all(phone ? 15 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'أصناف منخفضة المخزون: ' +
                                stats.lowStockCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.data,
    required this.compact,
  });

  final _ReportCardData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: compact ? 130 : 150,
      ),
      padding: EdgeInsets.all(compact ? 15 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            data.icon,
            color: AppColors.emeraldDark,
            size: compact ? 26 : 30,
          ),
          const Spacer(),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              data.value.toStringAsFixed(0) + ' ر.ي',
              style: TextStyle(
                fontSize: compact ? 21 : 27,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
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
