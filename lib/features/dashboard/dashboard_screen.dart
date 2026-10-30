import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/subscription/subscription_gate.dart';
import '../../core/theme/app_theme.dart';
import '../modules/module_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  late Future<DashboardStats> statsFuture;
  String query = '';
  String activityType = 'grocery';

  static const modules = <_Module>[
    _Module('المبيعات', Icons.receipt_long_rounded, AppColors.navy),
    _Module('المشتريات', Icons.shopping_bag_rounded, AppColors.emerald),
    _Module(
      'المخزون',
      Icons.inventory_2_rounded,
      Color(0xFFE7FAF5),
      darkIcon: AppColors.emeraldDark,
    ),
    _Module(
      'العملاء',
      Icons.person_rounded,
      Color(0xFFE8F8F4),
      darkIcon: AppColors.emeraldDark,
    ),
    _Module('الموردون', Icons.local_shipping_rounded, AppColors.navy),
    _Module('الحسابات', Icons.calculate_rounded, AppColors.emerald),
    _Module(
      'الصندوق',
      Icons.account_balance_wallet_rounded,
      AppColors.emerald,
    ),
    _Module(
      'البنوك',
      Icons.account_balance_rounded,
      Color(0xFFEAF8F4),
      darkIcon: AppColors.emeraldDark,
    ),
    _Module('المصروفات', Icons.request_quote_rounded, AppColors.navy),
    _Module(
      'القيود',
      Icons.menu_book_rounded,
      Color(0xFFE8F8F4),
      darkIcon: AppColors.navy,
    ),
    _Module('التقارير', Icons.bar_chart_rounded, AppColors.emerald),
    _Module('الإعدادات', Icons.settings_rounded, AppColors.navy),
  ];

  @override
  void initState() {
    super.initState();
    statsFuture = AppDatabase.instance.getDashboardStats();
    _loadActivityType();
  }

  Future<void> _loadActivityType() async {
    final settings =
        await AppDatabase.instance.getBusinessSettings();
    if (!mounted) return;
    setState(() {
      activityType = settings.activityType;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void refreshStats() {
    setState(() {
      statsFuture = AppDatabase.instance.getDashboardStats();
    });
  }

  Future<void> openModule(String title) async {
    await ModuleRouter.open(context, title);
    if (mounted) {
      refreshStats();
    }
  }

  void handleBottomAction(int index) {
    switch (index) {
      case 0:
        FocusScope.of(context).unfocus();
        break;
      case 1:
        searchFocusNode.requestFocus();
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد إشعارات جديدة')),
        );
        break;
      case 3:
        openModule('الإعدادات');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowed = SubscriptionGate.canUseApp(
      hasActiveSubscription: false,
    );

    final allModules = <_Module>[
      ...modules,
      if (activityType == 'restaurant' ||
          activityType == 'mixed')
        const _Module(
          'الطاولات',
          Icons.table_restaurant_rounded,
          Color(0xFFE8F8F4),
          darkIcon: AppColors.emeraldDark,
        ),
    ];

    final normalizedQuery = query.trim();
    final visibleModules = normalizedQuery.isEmpty
        ? allModules
        : allModules
            .where(
              (module) =>
                  module.title.contains(normalizedQuery),
            )
            .toList();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final desktop = width >= 900;
            final compactPhone = width < 370;
            final horizontalPadding = desktop ? 40.0 : 16.0;
            final columnCount = desktop ? 6 : (width < 340 ? 2 : 3);
            final gap = desktop ? 18.0 : 12.0;

            return Row(
              children: [
                if (desktop) const _DesktopRail(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      refreshStats();
                    },
                    child: CustomScrollView(
                      key: const Key('dashboard-scroll'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            desktop ? 24 : 12,
                            horizontalPadding,
                            18,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _BrandHeader(
                                compact: !desktop,
                                availableWidth:
                                    math.max(220.0, width - horizontalPadding * 2),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: _TrialBadge(allowed: allowed),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                key: const Key('dashboard-search'),
                                controller: searchController,
                                focusNode: searchFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    query = value;
                                  });
                                },
                                textInputAction: TextInputAction.search,
                                decoration: const InputDecoration(
                                  hintText: 'ابحث في النظام',
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              FutureBuilder<DashboardStats>(
                                future: statsFuture,
                                builder: (context, snapshot) {
                                  final stats = snapshot.data ??
                                      const DashboardStats(
                                        salesToday: 0,
                                        expensesToday: 0,
                                        cashBalance: 0,
                                        lowStockCount: 0,
                                      );
                                  return _KpiRow(
                                    stats: stats,
                                    compact: compactPhone,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'القائمة الرئيسية',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ]),
                          ),
                        ),
                        if (visibleModules.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'لا يوجد قسم مطابق للبحث',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columnCount,
                                mainAxisSpacing: gap,
                                crossAxisSpacing: gap,
                                childAspectRatio: desktop ? 1.02 : (width < 370 ? .76 : .82),
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _ModuleCard(
                                  module: visibleModules[index],
                                  onTap: () =>
                                      openModule(visibleModules[index].title),
                                ),
                                childCount: visibleModules.length,
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width >= 900
          ? null
          : NavigationBar(
              height: 68,
              selectedIndex: 0,
              onDestinationSelected: handleBottomAction,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'بحث',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_none_rounded),
                  label: 'إشعارات',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'حسابي',
                ),
              ],
            ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.compact,
    required this.availableWidth,
  });

  final bool compact;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final maxWidth = compact
        ? math.min(availableWidth * .82, 340.0)
        : math.min(availableWidth, 430.0);

    return Center(
      child: SizedBox(
        width: maxWidth,
        height: compact ? 92 : 130,
        child: Image.asset(
          'assets/branding/diftiri_logo.jpg',
          fit: BoxFit.contain,
          semanticLabel: 'دفتري المحاسبي',
        ),
      ),
    );
  }
}

class _TrialBadge extends StatelessWidget {
  const _TrialBadge({required this.allowed});

  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F9F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFCDEFE7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.science_rounded,
            size: 17,
            color: AppColors.emeraldDark,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              allowed
                  ? 'نسخة تجريبية'
                  : 'يلزم اشتراك نشط',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.emeraldDark,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.stats,
    required this.compact,
  });

  final DashboardStats stats;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'مبيعات اليوم',
            value: stats.salesToday.toStringAsFixed(0),
            icon: Icons.bar_chart_rounded,
            tint: const Color(0xFFEAF6FC),
            compact: compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            label: 'الرصيد النقدي',
            value: stats.cashBalance.toStringAsFixed(0),
            icon: Icons.monetization_on_rounded,
            tint: const Color(0xFFE7FAF5),
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.compact,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: EdgeInsets.all(compact ? 11 : 13),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.emeraldDark,
              size: compact ? 24 : 27,
            ),
          ),
          SizedBox(width: compact ? 7 : 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: compact ? 21 : 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.onTap,
  });

  final _Module module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final darkBackground =
        module.color == AppColors.navy ||
        module.color == AppColors.emerald;
    final iconColor =
        module.darkIcon ??
        (darkBackground ? Colors.white : AppColors.navy);

    return Semantics(
      button: true,
      label: module.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: module.color,
                  borderRadius: BorderRadius.circular(22),
                  border: darkBackground
                      ? null
                      : Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: .07),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final iconSize = math.min(
                      46.0,
                      math.max(34.0, constraints.maxWidth * .42),
                    );
                    return Icon(
                      module.icon,
                      size: iconSize,
                      color: iconColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 22,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  module.title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopRail extends StatelessWidget {
  const _DesktopRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RailIcon(Icons.home_rounded, active: true),
          _RailIcon(Icons.search_rounded),
          _RailIcon(Icons.notifications_none_rounded),
          _RailIcon(Icons.person_outline_rounded),
        ],
      ),
    );
  }
}

class _RailIcon extends StatelessWidget {
  const _RailIcon(this.icon, {this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFE8F8F4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: active
              ? AppColors.emeraldDark
              : AppColors.muted,
        ),
      ),
    );
  }
}

class _Module {
  const _Module(
    this.title,
    this.icon,
    this.color, {
    this.darkIcon,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Color? darkIcon;
}
