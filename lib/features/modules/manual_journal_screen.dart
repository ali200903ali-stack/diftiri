import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class ManualJournalScreen extends StatefulWidget {
  const ManualJournalScreen({super.key});

  @override
  State<ManualJournalScreen> createState() => _ManualJournalScreenState();
}

class _ManualJournalScreenState extends State<ManualJournalScreen> {
  final memo = TextEditingController();
  List<AccountRecord> accounts = [];
  final List<_JournalDraftLine> lines = [];
  DateTime date = DateTime.now();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    memo.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    accounts = await AppDatabase.instance.getAccounts();
    if (accounts.isNotEmpty) {
      lines
        ..add(
          _JournalDraftLine(
            accountCode: accounts.first.code,
          ),
        )
        ..add(
          _JournalDraftLine(
            accountCode:
                accounts.length > 1 ? accounts[1].code : accounts.first.code,
          ),
        );
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  double get totalDebit => lines.fold<double>(
        0,
        (sum, line) => sum + line.debit,
      );

  double get totalCredit => lines.fold<double>(
        0,
        (sum, line) => sum + line.credit,
      );

  bool get balanced =>
      totalDebit > 0 &&
      (totalDebit - totalCredit).abs() < 0.001;

  String get dateText =>
      date.year.toString() +
      '/' +
      date.month.toString().padLeft(2, '0') +
      '/' +
      date.day.toString().padLeft(2, '0');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        date = picked;
      });
    }
  }

  void _addLine() {
    if (accounts.isEmpty) return;
    setState(() {
      lines.add(
        _JournalDraftLine(
          accountCode: accounts.first.code,
        ),
      );
    });
  }

  Future<void> _save() async {
    try {
      await AppDatabase.instance.recordManualJournal(
        date: date,
        memo: memo.text,
        lines: lines
            .map(
              (line) => JournalInputLine(
                accountCode: line.accountCode,
                debit: line.debit,
                credit: line.credit,
              ),
            )
            .toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ وترحيل القيد'),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('قيد بسيط'),
        actions: [
          IconButton(
            tooltip: 'حفظ',
            onPressed: balanced ? _save : null,
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: ListView(
        key: const Key('manual-journal-scroll'),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(18),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'التاريخ',
                      suffixIcon:
                          Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(dateText),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: memo,
                  decoration: const InputDecoration(
                    labelText: 'البيان',
                    hintText: 'مثال: سداد مصروف كهرباء',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < lines.length; i++) ...[
                  _JournalLineEditor(
                    number: i + 1,
                    line: lines[i],
                    accounts: accounts,
                    onChanged: () => setState(() {}),
                    onDelete: lines.length <= 2
                        ? null
                        : () {
                            setState(() {
                              lines.removeAt(i);
                            });
                          },
                  ),
                  if (i != lines.length - 1)
                    const Divider(height: 18),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add_circle_rounded),
                    label: const Text('إضافة سطر جديد'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: balanced
                  ? const Color(0xFFE3F8F1)
                  : const Color(0xFFFFF1DD),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TotalBox(
                    label: 'إجمالي المدين',
                    value: totalDebit,
                  ),
                ),
                Container(
                  width: 1,
                  height: 46,
                  color: AppColors.border,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        balanced
                            ? Icons.check_circle_rounded
                            : Icons.warning_amber_rounded,
                        color: balanced
                            ? AppColors.emeraldDark
                            : const Color(0xFFE67E00),
                      ),
                      Text(
                        balanced ? 'متوازن' : 'غير متوازن',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: balanced
                              ? AppColors.emeraldDark
                              : const Color(0xFFE67E00),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 46,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _TotalBox(
                    label: 'إجمالي الدائن',
                    value: totalCredit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FilledButton.icon(
            onPressed: balanced ? _save : null,
            icon: const Icon(Icons.save_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text(
                'حفظ القيد',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalDraftLine {
  _JournalDraftLine({
    required this.accountCode,
  });

  String accountCode;
  double debit = 0;
  double credit = 0;
}

class _JournalLineEditor extends StatelessWidget {
  const _JournalLineEditor({
    required this.number,
    required this.line,
    required this.accounts,
    required this.onChanged,
    this.onDelete,
  });

  final int number;
  final _JournalDraftLine line;
  final List<AccountRecord> accounts;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFFEAF3FA),
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: line.accountCode,
                decoration: const InputDecoration(
                  labelText: 'الحساب',
                ),
                items: accounts
                    .map(
                      (account) => DropdownMenuItem<String>(
                        value: account.code,
                        child: Text(
                          account.code + ' - ' + account.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  line.accountCode = value;
                  onChanged();
                },
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: line.debit == 0
                    ? ''
                    : line.debit.toStringAsFixed(0),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'المدين',
                ),
                onChanged: (value) {
                  line.debit = double.tryParse(value) ?? 0;
                  if (line.debit > 0) line.credit = 0;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: line.credit == 0
                    ? ''
                    : line.credit.toStringAsFixed(0),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'الدائن',
                ),
                onChanged: (value) {
                  line.credit = double.tryParse(value) ?? 0;
                  if (line.credit > 0) line.debit = 0;
                  onChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TotalBox extends StatelessWidget {
  const _TotalBox({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}
