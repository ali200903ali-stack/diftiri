import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class CashScreen extends StatelessWidget {
  const CashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصندوق')),
      body: FutureBuilder<List<Object>>(
        future: Future.wait<Object>([
          AppDatabase.instance.getDashboardStats(),
          AppDatabase.instance.getCashJournalLines(),
        ]),
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
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الرصيد النقدي',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        stats.cashBalance
                                .toStringAsFixed(0) +
                            ' ر.ي',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
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
    final amount = incoming
        ? line.debit
        : line.credit;

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
          CircleAvatar(
            backgroundColor: incoming
                ? const Color(0xFFE8F8F4)
                : const Color(0xFFFFECEC),
            child: Icon(
              incoming
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: incoming
                  ? AppColors.emeraldDark
                  : Colors.red.shade700,
            ),
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
