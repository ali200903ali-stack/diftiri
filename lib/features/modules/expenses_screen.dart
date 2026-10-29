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

  final category = TextEditingController(
    text: 'مصروف تشغيلي',
  );
  final amount = TextEditingController();
  final note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    category.dispose();
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  void _reload() {
    future = AppDatabase.instance.getExpenses();
  }

  Future<void> _add() async {
    final value = double.tryParse(amount.text) ?? 0;
    if (value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل مبلغًا صحيحًا'),
        ),
      );
      return;
    }

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final phone = constraints.maxWidth < 600;
          final padding = phone ? 14.0 : 20.0;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                _ExpenseForm(
                  phone: phone,
                  category: category,
                  amount: amount,
                  note: note,
                  onAdd: _add,
                ),
                const SizedBox(height: 16),
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
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _ExpenseTile(
                            record: rows[index],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExpenseForm extends StatelessWidget {
  const _ExpenseForm({
    required this.phone,
    required this.category,
    required this.amount,
    required this.note,
    required this.onAdd,
  });

  final bool phone;
  final TextEditingController category;
  final TextEditingController amount;
  final TextEditingController note;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      TextField(
        controller: category,
        decoration: const InputDecoration(
          labelText: 'التصنيف',
        ),
      ),
      TextField(
        controller: amount,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: const InputDecoration(
          labelText: 'المبلغ',
        ),
      ),
      TextField(
        controller: note,
        decoration: const InputDecoration(
          labelText: 'ملاحظة',
        ),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(phone ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: phone
          ? Column(
              children: [
                ...fields.expand(
                  (field) => [
                    field,
                    const SizedBox(height: 10),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('إضافة المصروف'),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: 10),
                SizedBox(
                  width: 170,
                  child: fields[1],
                ),
                const SizedBox(width: 10),
                Expanded(child: fields[2]),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة'),
                ),
              ],
            ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.record});

  final ExpenseRecord record;

  @override
  Widget build(BuildContext context) {
    final dateText = record.createdAt
        .toLocal()
        .toString()
        .substring(0, 16);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 4,
        ),
        leading: const CircleAvatar(
          child: Icon(Icons.request_quote_rounded),
        ),
        title: Text(
          record.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          record.note.isEmpty
              ? dateText
              : record.note,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            record.amount.toStringAsFixed(0) + ' ر.ي',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}
