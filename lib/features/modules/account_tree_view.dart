import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class AccountTreeView extends StatelessWidget {
  const AccountTreeView({super.key});

  static const _groups = <_AccountGroup>[
    _AccountGroup(
      type: 'asset',
      title: 'الأصول',
      subtitle: 'النقدية والبنوك والعملاء والمخزون',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.emerald,
      light: Color(0xFFE8FBF6),
    ),
    _AccountGroup(
      type: 'liability',
      title: 'الخصوم',
      subtitle: 'الموردون والالتزامات والضرائب',
      icon: Icons.payments_rounded,
      color: AppColors.navy,
      light: Color(0xFFEDF7FC),
    ),
    _AccountGroup(
      type: 'equity',
      title: 'حقوق الملكية',
      subtitle: 'رأس المال والأرصدة الافتتاحية',
      icon: Icons.assured_workload_rounded,
      color: Color(0xFF6D4CC8),
      light: Color(0xFFF2EEFC),
    ),
    _AccountGroup(
      type: 'revenue',
      title: 'الإيرادات',
      subtitle: 'المبيعات والإيرادات الأخرى',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF0B8F73),
      light: Color(0xFFE7F8F4),
    ),
    _AccountGroup(
      type: 'expense',
      title: 'المصروفات والتكلفة',
      subtitle: 'تكلفة المبيعات والمصروفات التشغيلية',
      icon: Icons.trending_down_rounded,
      color: Color(0xFFC05A24),
      light: Color(0xFFFFF2E9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AccountRecord>>(
      future: AppDatabase.instance.getAccounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final accounts = snapshot.data!;
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            return ListView(
              key: const Key('account-tree-list'),
              padding: EdgeInsets.fromLTRB(
                wide ? 28 : 14,
                14,
                wide ? 28 : 14,
                100,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      children: [
                        const _TreeRoot(),
                        const _TreeStem(height: 22),
                        ..._groups.map((group) {
                          final rows = accounts
                              .where((item) => item.type == group.type)
                              .toList();
                          return _TreeBranch(
                            group: group,
                            accounts: rows,
                            wide: wide,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TreeRoot extends StatelessWidget {
  const _TreeRoot();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            AppColors.navyDark,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x32123E63),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          _RootIcon(),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شجرة الحسابات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'هيكل محاسبي مترابط يوضح المجموعات والحسابات وأرصدتها الحالية',
                  style: TextStyle(
                    color: Color(0xFFD7E7F0),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RootIcon extends StatelessWidget {
  const _RootIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: .18),
        ),
      ),
      child: const Icon(
        Icons.account_tree_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}

class _TreeStem extends StatelessWidget {
  const _TreeStem({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.navy,
            AppColors.emerald,
          ],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _TreeBranch extends StatelessWidget {
  const _TreeBranch({
    required this.group,
    required this.accounts,
    required this.wide,
  });

  final _AccountGroup group;
  final List<AccountRecord> accounts;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final total = accounts.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );

    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 760),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0E123E63),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                14,
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: group.light,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: group.color.withValues(alpha: .16),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  group.icon,
                  color: group.color,
                  size: 28,
                ),
              ),
              title: Text(
                group.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(
                group.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: group.light,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _money(total),
                  style: TextStyle(
                    color: group.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              children: [
                if (accounts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'لا توجد حسابات داخل هذه المجموعة',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                else
                  ...accounts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final account = entry.value;
                    return _AccountNode(
                      account: account,
                      color: group.color,
                      light: group.light,
                      isLast: index == accounts.length - 1,
                      wide: wide,
                    );
                  }),
              ],
            ),
          ),
        ),
        const _TreeStem(height: 18),
      ],
    );
  }

  static String _money(double value) {
    return value.abs() < .005
        ? '0'
        : value.toStringAsFixed(0);
  }
}

class _AccountNode extends StatelessWidget {
  const _AccountNode({
    required this.account,
    required this.color,
    required this.light,
    required this.isLast,
    required this.wide,
  });

  final AccountRecord account;
  final Color color;
  final Color light;
  final bool isLast;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final positive = account.balance >= 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : AppColors.border,
                ),
              ),
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .28),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : AppColors.border,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 16 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: light,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    account.code,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    account.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      account.balance.abs().toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: positive
                            ? AppColors.emeraldDark
                            : Colors.red.shade700,
                      ),
                    ),
                    const Text(
                      'الرصيد',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountGroup {
  const _AccountGroup({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.light,
  });

  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color light;
}
