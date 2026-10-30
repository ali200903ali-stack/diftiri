import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';

class PurchaseHistoryScreen
    extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DiftiriAppBar(
        title: 'سجل المشتريات',
        subtitle: 'جميع عمليات الشراء السابقة',
        icon: Icons.history_rounded,
        tone: DiftiriTone.emerald,
      ),
      body:
          FutureBuilder<List<PurchaseSummaryRecord>>(
        future:
            AppDatabase.instance.getPurchasesHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final purchases = snapshot.data!;
          if (purchases.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد فواتير شراء حتى الآن',
                style: TextStyle(
                  color: AppColors.muted,
                ),
              ),
            );
          }

          return ListView.separated(
            key: const Key('purchase-history-list'),
            padding: const EdgeInsets.all(14),
            itemCount: purchases.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              final date = purchase.createdAt
                  .toLocal()
                  .toString()
                  .substring(0, 16);
              final supplier =
                  purchase.supplierName.isEmpty
                  ? 'بدون مورد محدد'
                  : purchase.supplierName;

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
                            const Color(0xFFEAF3FA),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          Text(
                            date +
                                ' • ' +
                                purchase.itemCount
                                    .toStringAsFixed(0) +
                                ' وحدة',
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
                        purchase.total
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
