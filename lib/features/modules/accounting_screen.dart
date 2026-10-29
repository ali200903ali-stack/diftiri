import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحسابات والقيود'),
      ),
      body: FutureBuilder<List<JournalLineRecord>>(
        future: AppDatabase.instance.getJournalLines(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final rows = snapshot.data!;
          if (rows.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'لا توجد قيود بعد. سجّل بيعاً أو شراءً أو مصروفاً.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: rows.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _JournalLineCard(
                line: rows[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _JournalLineCard extends StatelessWidget {
  const _JournalLineCard({required this.line});

  final JournalLineRecord line;

  @override
  Widget build(BuildContext context) {
    final isDebit = line.debit > 0;
    final amount = isDebit ? line.debit : line.credit;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDebit
                  ? const Color(0xFFE8F8F4)
                  : const Color(0xFFEAF3FA),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isDebit
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: isDebit
                  ? AppColors.emeraldDark
                  : AppColors.navy,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  line.accountCode +
                      ' - ' +
                      line.accountName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line.reference +
                      ' • ' +
                      line.memo,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isDebit ? 'مدين' : 'دائن',
                style: TextStyle(
                  color: isDebit
                      ? AppColors.emeraldDark
                      : AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  amount.toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
