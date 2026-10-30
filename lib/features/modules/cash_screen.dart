import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() =>
      _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  late Future<List<Object>> future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    future = Future.wait<Object>([
      AppDatabase.instance.getDashboardStats(),
      AppDatabase.instance.getCashJournalLines(),
    ]);
  }

  Future<void> _addOpeningBalance() async {
    final controller = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'إضافة رصيد افتتاحي',
          ),
          content: SizedBox(
            width: 380,
            child: TextField(
              autofocus: true,
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                suffixText: 'ر.ي',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final value =
                    double.tryParse(controller.text);
                if (value == null || value <= 0) {
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  value,
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null) return;

    await AppDatabase.instance
        .addCashOpeningBalance(amount);

    if (!mounted) return;

    setState(_reload);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تسجيل الرصيد الافتتاحي وقيده محاسبياً',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DiftiriAppBar(
        title: 'الصندوق',
        subtitle: 'الرصيد النقدي وحركة الصندوق',
        icon: Icons.account_balance_wallet_rounded,
        tone: DiftiriTone.emerald,
        actions: [
          IconButton(
            tooltip: 'رصيد افتتاحي',
            onPressed: _addOpeningBalance,
            icon: const Icon(
              Icons.add_card_rounded,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<List<Object>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final stats =
              snapshot.data![0] as DashboardStats;
          final lines =
              snapshot.data![1] as List<JournalLineRecord>;

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.navy,
                      AppColors.navyDark,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'الرصيد النقدي',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Colors.white,
                          ),
                          onPressed:
                              _addOpeningBalance,
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'رصيد افتتاحي',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment:
                          Alignment.centerRight,
                      child: Text(
                        stats.cashBalance
                                .toStringAsFixed(0) +
                            ' ر.ي',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'آخر حركات الصندوق',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (lines.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 28,
                  ),
                  child: Center(
                    child: Text(
                      'لا توجد حركات في الصندوق بعد',
                      style: TextStyle(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                )
              else
                ...lines.take(40).map(
                      (line) => _CashMovementCard(
                        line: line,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _CashMovementCard extends StatelessWidget {
  const _CashMovementCard({
    required this.line,
  });

  final JournalLineRecord line;

  @override
  Widget build(BuildContext context) {
    final incoming = line.debit > 0;
    final amount =
        incoming ? line.debit : line.credit;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          DiftiriIconBox(
            icon: incoming
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            tone: incoming
                ? DiftiriTone.emerald
                : DiftiriTone.navy,
            size: 46,
            iconSize: 23,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  line.memo.isEmpty
                      ? line.reference
                      : line.memo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  line.reference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
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
              (incoming ? '+' : '-') +
                  amount.toStringAsFixed(0),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: incoming
                    ? AppColors.emeraldDark
                    : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
