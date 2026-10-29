import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحسابات والقيود')),
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
              child: Text(
                'لا توجد قيود بعد. سجّل بيعاً أو شراءً أو مصروفاً.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final row = rows[index];

              return ListTile(
                title: Text(
                  row.accountCode + ' - ' + row.accountName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  row.reference + ' • ' + row.memo,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (row.debit > 0)
                      Text(
                        'مدين ' + row.debit.toStringAsFixed(0),
                        style: const TextStyle(
                          color: AppColors.emeraldDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (row.credit > 0)
                      Text(
                        'دائن ' + row.credit.toStringAsFixed(0),
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
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
