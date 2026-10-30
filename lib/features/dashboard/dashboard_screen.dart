import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';
import '../modules/module_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  late Future<DashboardStats> statsFuture;
  String query = '';
  String activityType = 'grocery';

  static const modules = <_Module>[
    _Module(
      'المبيعات',
      Icons.receipt_long_rounded,
      _ModuleTone.navy,
    ),
    _Module(
      'المشتريات',
      Icons.shopping_bag_rounded,
      _ModuleTone.emerald,
    ),
    _Module(
      'المخزون',
      Icons.inventory_2_rounded,
      _ModuleTone.mint,
    ),
    _Module(
      'العملاء',
      Icons.person_rounded,
      _ModuleTone.mint,
    ),
    _Module(
      'الموردون',
      Icons.local_shipping_rounded,
      _ModuleTone.navy,
    ),
    _Module(
      'الحسابات',
      Icons.calculate_rounded,
      _ModuleTone.emerald,
    ),
    _Module(
      'الصندوق',
      Icons.account_balance_wallet_rounded,
      _ModuleTone.emerald,
    ),
    _Module(
      'البنوك',
      Icons.account_balance_rounded,
      _ModuleTone.mint,
    ),
    _Module(
      'المصروفات',
      Icons.request_quote_rounded,
      _ModuleTone.navy,
    ),
    _Module(
      'القيود',
      Icons.edit_note_rounded,
      _ModuleTone.mint,
    ),
    _Module(
      'التقارير',
      Icons.bar_chart_rounded,
      _ModuleTone.emerald,
    ),
    _Module(
      'الإعدادات',
      Icons.settings_rounded,
      _ModuleTone.navy,
    ),
  ];

  @override
  void initState() {
    super.initState();
    statsFuture =
        AppDatabase.instance.getDashboardStats();
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

  void _refreshStats() {
    setState(() {
      statsFuture =
          AppDatabase.instance.getDashboardStats();
    });
  }

  Future<void> _openModule(String title) async {
    await ModuleRouter.open(context, title);
    if (!mounted) return;
    _refreshStats();
    await _loadActivityType();
  }

  void _handleBottomAction(int index) {
    switch (index) {
      case 0:
        FocusScope.of(context).unfocus();
        break;
      case 1:
        searchFocusNode.requestFocus();
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد إشعارات جديدة'),
          ),
        );
        break;
      case 3:
        _openModule('الإعدادات');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allModules = <_Module>[
      ...modules,
      if (activityType == 'restaurant' ||
          activityType == 'mixed')
        const _Module(
          'الطاولات',
          Icons.table_restaurant_rounded,
          _ModuleTone.mint,
        ),
    ];

    final normalized = query.trim();
    final visibleModules = normalized.isEmpty
        ? allModules
        : allModules
            .where(
              (item) => item.title.contains(normalized),
            )
            .toList();

    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 1180),
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshStats();
                await _loadActivityType();
              },
              child: CustomScrollView(
                key: const Key('dashboard-scroll'),
                physics:
                    const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      desktop ? 34 : 14,
                      desktop ? 22 : 8,
                      desktop ? 34 : 14,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _BrandHeader(desktop: desktop),
                        SizedBox(
                          height: desktop ? 14 : 6,
                        ),
                        _SearchBar(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          onChanged: (value) {
                            setState(() => query = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        FutureBuilder<DashboardStats>(
                          future: statsFuture,
                          builder: (context, snapshot) {
                            final stats =
                                snapshot.data ??
                                const DashboardStats(
                                  salesToday: 0,
                                  expensesToday: 0,
                                  cashBalance: 0,
                                  lowStockCount: 0,
                                );
                            return _KpiRow(stats: stats);
                          },
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'القائمة الرئيسية',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ),
                            if (visibleModules.length !=
                                allModules.length)
                              Text(
                                visibleModules.length
                                        .toString() +
                                    ' نتائج',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                          ],
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        desktop ? 34 : 14,
                        0,
                        desktop ? 34 : 14,
                        26,
                      ),
                      sliver: SliverLayoutBuilder(
                        builder: (
                          context,
                          constraints,
                        ) {
                          final cross =
                              constraints
                                  .crossAxisExtent;
                          final columns = cross >= 1000
                              ? 6
                              : cross >= 650
                                  ? 4
                                  : 3;
                          final gap =
                              cross < 350 ? 8.0 : 12.0;

                          return SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: gap,
                              mainAxisSpacing: 14,
                              childAspectRatio:
                                  columns >= 4
                                      ? .94
                                      : cross < 350
                                          ? .72
                                          : .78,
                            ),
                            delegate:
                                SliverChildBuilderDelegate(
                              (context, index) {
                                final module =
                                    visibleModules[index];
                                return _ModuleCard(
                                  module: module,
                                  onTap: () => _openModule(
                                    module.title,
                                  ),
                                );
                              },
                              childCount:
                                  visibleModules.length,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: desktop
          ? null
          : DiftiriBottomNav(
              selectedIndex: 0,
              onSelected: _handleBottomAction,
            ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: desktop ? 4 : 0,
          bottom: desktop ? 2 : 0,
        ),
        child: SizedBox(
          width: desktop ? 430 : 286,
          height: desktop ? 112 : 84,
          child: Image.asset(
            'assets/branding/diftiri_logo.jpg',
            fit: BoxFit.contain,
            semanticLabel: 'دفتري المحاسبي',
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10123E63),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        key: const Key('dashboard-search'),
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'ابحث في النظام',
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 28,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'مبيعات اليوم',
            value: stats.salesToday,
            icon: Icons.bar_chart_rounded,
            tint: AppColors.ice,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            label: 'الرصيد النقدي',
            value: stats.cashBalance,
            icon: Icons.monetization_on_rounded,
            tint: AppColors.mint,
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
  });

  final String label;
  final double value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final narrow =
        MediaQuery.sizeOf(context).width < 360;

    return Container(
      height: narrow ? 92 : 104,
      padding: EdgeInsets.all(narrow ? 10 : 13),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12123E63),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: narrow ? 42 : 50,
            height: narrow ? 42 : 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x17000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.emeraldDark,
              size: narrow ? 25 : 30,
            ),
          ),
          SizedBox(width: narrow ? 7 : 10),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment:
                      Alignment.centerRight,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: narrow ? 12 : 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment:
                      Alignment.centerRight,
                  child: Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      color: AppColors.navyDark,
                      fontSize: narrow ? 21 : 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .3,
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
    final colors = switch (module.tone) {
      _ModuleTone.navy => const [
          Color(0xFF174F78),
          AppColors.navyDark,
        ],
      _ModuleTone.emerald => const [
          Color(0xFF13C29C),
          Color(0xFF07836A),
        ],
      _ModuleTone.mint => const [
          Color(0xFFF3FFFC),
          Color(0xFFDDF8F1),
        ],
    };

    final light =
        module.tone == _ModuleTone.mint;
    final iconColor = light
        ? AppColors.emeraldDark
        : Colors.white;
    final width =
        MediaQuery.sizeOf(context).width;
    final iconBox = width < 350 ? 76.0 : 92.0;

    return Semantics(
      button: true,
      label: module.title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start,
          children: [
            DiftiriIconBox(
              icon: module.icon,
              tone: switch (module.tone) {
                _ModuleTone.navy => DiftiriTone.navy,
                _ModuleTone.emerald => DiftiriTone.emerald,
                _ModuleTone.mint => DiftiriTone.mint,
              },
              size: iconBox,
              iconSize: iconBox * .50,
            ),
            const SizedBox(height: 9),
            Flexible(
              child: Text(
                module.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: width < 350 ? 12 : 14.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ModuleTone {
  navy,
  emerald,
  mint,
}

class _Module {
  const _Module(
    this.title,
    this.icon,
    this.tone,
  );

  final String title;
  final IconData icon;
  final _ModuleTone tone;
}
