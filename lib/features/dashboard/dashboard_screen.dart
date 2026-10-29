import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/subscription/subscription_gate.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  static const modules = <_Module>[
    _Module('المبيعات', Icons.receipt_long_rounded, AppColors.navy),
    _Module('المشتريات', Icons.shopping_bag_rounded, AppColors.emerald),
    _Module('المخزون', Icons.inventory_2_rounded, Color(0xFFE7FAF5), darkIcon: AppColors.emeraldDark),
    _Module('العملاء', Icons.person_rounded, Color(0xFFE8F8F4), darkIcon: AppColors.emeraldDark),
    _Module('الموردون', Icons.local_shipping_rounded, AppColors.navy),
    _Module('الحسابات', Icons.calculate_rounded, AppColors.emerald),
    _Module('الصندوق', Icons.account_balance_wallet_rounded, AppColors.emerald),
    _Module('البنوك', Icons.account_balance_rounded, Color(0xFFEAF8F4), darkIcon: AppColors.emeraldDark),
    _Module('المصروفات', Icons.request_quote_rounded, AppColors.navy),
    _Module('القيود', Icons.menu_book_rounded, Color(0xFFE8F8F4), darkIcon: AppColors.navy),
    _Module('التقارير', Icons.bar_chart_rounded, AppColors.emerald),
    _Module('الإعدادات', Icons.settings_rounded, AppColors.navy),
  ];

  @override
  Widget build(BuildContext context) {
    final allowed = SubscriptionGate.canUseApp(hasActiveSubscription: false);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            return Row(
              children: [
                if (desktop) const _DesktopRail(),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          desktop ? 40 : 20,
                          24,
                          desktop ? 40 : 20,
                          28,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const _BrandHeader(),
                            const SizedBox(height: 26),
                            _TrialBanner(allowed: allowed),
                            const SizedBox(height: 18),
                            const _SearchBox(),
                            const SizedBox(height: 22),
                            const _KpiRow(),
                            const SizedBox(height: 26),
                            const Text(
                              'القائمة الرئيسية',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ]),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: desktop ? 40 : 20,
                        ),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: desktop ? 6 : 3,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 16,
                            childAspectRatio: desktop ? 1.05 : .82,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _ModuleCard(module: modules[index]),
                            childCount: modules.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 110)),
                    ],
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
              selectedIndex: currentIndex,
              onDestinationSelected: (value) => setState(() => currentIndex = value),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
                NavigationDestination(icon: Icon(Icons.search_rounded), label: 'بحث'),
                NavigationDestination(icon: Icon(Icons.notifications_none_rounded), label: 'إشعارات'),
                NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'حسابي'),
              ],
            ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _BookMark(),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'دفتري',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 38,
                height: .95,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'المحاسبي',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 21,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookMark extends StatelessWidget {
  const _BookMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.emerald],
        ),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.menu_book_rounded, color: Colors.white, size: 46),
          Positioned(
            left: 14,
            bottom: 13,
            child: Icon(Icons.bar_chart_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _TrialBanner extends StatelessWidget {
  const _TrialBanner({required this.allowed});
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F9F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCDEFE7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_rounded, color: AppColors.emeraldDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              allowed
                  ? 'نسخة تجريبية مفتوحة — الاشتراك غير مفعّل حالياً'
                  : 'يلزم اشتراك نشط لاستخدام النظام',
              style: const TextStyle(
                color: AppColors.emeraldDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        hintText: 'ابحث في النظام',
        prefixIcon: Icon(Icons.search_rounded, size: 30),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cards = [
          _KpiCard(
            label: 'مبيعات اليوم',
            value: '12,450',
            icon: Icons.bar_chart_rounded,
            tint: Color(0xFFEAF6FC),
            iconColor: AppColors.emeraldDark,
          ),
          _KpiCard(
            label: 'الرصيد النقدي',
            value: '86,200',
            icon: Icons.monetization_on_rounded,
            tint: Color(0xFFE7FAF5),
            iconColor: AppColors.emeraldDark,
          ),
        ];

        return Row(
          children: const [
            Expanded(child: cards[0]),
            SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.86),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 27,
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
  const _ModuleCard({required this.module});
  final _Module module;

  @override
  Widget build(BuildContext context) {
    final darkBackground =
        module.color == AppColors.navy || module.color == AppColors.emerald;
    final iconColor =
        module.darkIcon ?? (darkBackground ? Colors.white : AppColors.navy);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('سيتم فتح وحدة ' + module.title)),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: module.color,
                borderRadius: BorderRadius.circular(24),
                border: darkBackground
                    ? null
                    : Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withOpacity(.07),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(module.icon, size: 50, color: iconColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            module.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
        ],
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
          color: active ? const Color(0xFFE8F8F4) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.emeraldDark : AppColors.muted,
        ),
      ),
    );
  }
}

class _Module {
  const _Module(this.title, this.icon, this.color, {this.darkIcon});

  final String title;
  final IconData icon;
  final Color color;
  final Color? darkIcon;
}
