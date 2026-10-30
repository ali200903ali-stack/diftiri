import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DiftiriAppBar(
        title: 'سجل المبيعات',
        subtitle: 'جميع عمليات البيع السابقة',
        icon: Icons.history_rounded,
        tone: DiftiriTone.navy,
      ),
      body: FutureBuilder<List<SaleSummaryRecord>>(
        future: AppDatabase.instance.getSalesHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final sales = snapshot.data!;
          if (sales.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد عمليات بيع حتى الآن',
                style: TextStyle(
                  color: AppColors.muted,
                ),
              ),
            );
          }

          return ListView.separated(
            key: const Key('sales-history-list'),
            padding: const EdgeInsets.all(14),
            itemCount: sales.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final sale = sales[index];
              final date = sale.createdAt
                  .toLocal()
                  .toString()
                  .substring(0, 16);
              final orderLabel =
                  sale.orderType == 'dine_in'
                  ? (sale.tableName.isEmpty
                      ? 'محلي'
                      : 'محلي - ' + sale.tableName)
                  : sale.orderType == 'takeaway'
                      ? 'سفري'
                      : 'بيع مباشر';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE8F8F4),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color:
                            AppColors.emeraldDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فاتورة #' +
                                sale.id.toString(),
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          Text(
                            date +
                                ' • ' +
                                orderLabel +
                                ' • ' +
                                sale.itemCount
                                    .toStringAsFixed(0) +
                                ' صنف',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        sale.total
                                .toStringAsFixed(0) +
                            ' ر.ي',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
