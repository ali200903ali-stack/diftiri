import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';
import 'account_tree_view.dart';
import 'manual_journal_screen.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({
    super.key,
    this.initialTab = 0,
  });

  final int initialTab;

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<JournalLineRecord>> future;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    tabController.addListener(_handleTabChanged);
    _reload();
  }

  @override
  void dispose() {
    tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (!tabController.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  void _reload() {
    future = AppDatabase.instance.getJournalLines();
  }

  Future<void> _newJournal() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ManualJournalScreen(),
      ),
    );
    if (changed == true && mounted) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DiftiriAppBar(
        title: 'الحسابات والقيود',
        subtitle: 'شجرة حسابات، أرصدة وقيود يومية',
        icon: Icons.calculate_rounded,
        tone: DiftiriTone.emerald,
        bottom: TabBar(
          controller: tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: AppColors.emerald,
          labelColor: AppColors.emeraldDark,
          unselectedLabelColor: AppColors.muted,
          tabs: const [
            Tab(
              icon: Icon(Icons.account_tree_rounded),
              text: 'شجرة الحسابات',
            ),
            Tab(
              icon: Icon(Icons.menu_book_rounded),
              text: 'القيود اليومية',
            ),
          ],
        ),
      ),
      floatingActionButton: tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _newJournal,
              icon: const Icon(Icons.add_rounded),
              label: const Text('قيد جديد'),
            )
          : null,
      body: TabBarView(
        controller: tabController,
        children: [
          const AccountTreeView(),
          FutureBuilder<List<JournalLineRecord>>(
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
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'لا توجد قيود بعد. ابدأ بقيد بسيط أو سجّل عملية بيع أو شراء.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.separated(
                key: const Key('journal-lines-list'),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
                itemCount: rows.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _JournalLineCard(line: rows[index]);
                },
              );
            },
          ),
        ],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.accountCode + ' - ' + line.accountName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line.reference + ' • ' + line.memo,
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
              Text(
                amount.toStringAsFixed(0),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
