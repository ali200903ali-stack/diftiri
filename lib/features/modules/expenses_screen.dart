import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late Future<List<ExpenseRecord>> future;
  final category = TextEditingController(text: 'مصروف تشغيلي');
  final amount = TextEditingController();
  final note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    future = AppDatabase.instance.getExpenses();
  }

  Future<void> _add() async {
    final value = double.tryParse(amount.text) ?? 0;
    if (value <= 0) return;

    await AppDatabase.instance.recordExpense(
      category: category.text,
      amount: value,
      note: note.text,
    );

    amount.clear();
    note.clear();

    if (!mounted) return;
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المصروفات')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: category,
                    decoration: const InputDecoration(labelText: 'التصنيف'),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'المبلغ'),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: note,
                    decoration: const InputDecoration(labelText: 'ملاحظة'),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<ExpenseRecord>>(
                future: future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final rows = snapshot.data!;
                  if (rows.isEmpty) {
                    return const Center(
                      child: Text('لا توجد مصروفات'),
                    );
                  }

                  return ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final dateText = row.createdAt
                          .toLocal()
                          .toString()
                          .substring(0, 16);

                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.request_quote_rounded),
                        ),
                        title: Text(
                          row.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          row.note.isEmpty ? dateText : row.note,
                        ),
                        trailing: Text(
                          row.amount.toStringAsFixed(0) + ' ر.ي',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
