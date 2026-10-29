import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import 'accounting_screen.dart';
import 'inventory_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String period = 'month';

  DateTime get _from {
    final now = DateTime.now();
    switch (period) {
      case 'year':
        return DateTime(now.year, 1, 1);
      case '30':
        return now.subtract(const Duration(days: 30));
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  DateTime get _to {
    final now = DateTime.now();
    if (period == 'month') {
      return DateTime(now.year, now.month + 1, 1);
    }
    if (period == 'year') {
      return DateTime(now.year + 1, 1, 1);
    }
    return now.add(const Duration(days: 1));
  }

  Future<_ReportBundle> _load() async {
    final summary = await AppDatabase.instance.getReportSummary(
      from: _from,
      to: _to,
    );
    final trend =
        await AppDatabase.instance.getMonthlySalesTrend();
    return _ReportBundle(summary, trend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: period,
                borderRadius: BorderRadius.circular(18),
                items: const [
                  DropdownMenuItem(
                    value: 'month',
                    child: Text('هذا الشهر'),
                  ),
                  DropdownMenuItem(
                    value: '30',
                    child: Text('آخر 30 يوم'),
                  ),
                  DropdownMenuItem(
                    value: 'year',
                    child: Text('هذه السنة'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    period = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<_ReportBundle>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final bundle = snapshot.data!;
          final summary = bundle.summary;

          return ListView(
            key: const Key('reports-scroll'),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
            children: [
              const Text(
                'نظرة شاملة على أداء أعمالك',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'إجمالي المبيعات',
                      value: summary.netSales,
                      icon: Icons.monetization_on_rounded,
                      tint: const Color(0xFFE8F8F4),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _SummaryCard(
                      label: 'صافي الربح',
                      value: summary.netProfit,
                      icon: Icons.bar_chart_rounded,
                      tint: const Color(0xFFEAF3FA),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _SummaryCard(
                      label: 'المصروفات',
                      value: summary.expenses,
                      icon: Icons.pie_chart_rounded,
                      tint: const Color(0xFFF0FBF7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اتجاه المبيعات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'صافي المبيعات خلال آخر 6 أشهر',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 210,
                      child: _TrendChart(
                        points: bundle.trend,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'التقارير السريعة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  _QuickReportCard(
                    label: 'الأرباح والخسائر',
                    icon: Icons.show_chart_rounded,
                    onTap: () => _showProfitDialog(summary),
                  ),
                  _QuickReportCard(
                    label: 'كشف الحساب',
                    icon: Icons.receipt_long_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const AccountingScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickReportCard(
                    label: 'المخزون',
                    icon: Icons.inventory_2_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const InventoryScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickReportCard(
                    label: 'الميزانية المختصرة',
                    icon: Icons.donut_large_rounded,
                    onTap: () => _showBalanceDialog(summary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(
                label: 'مردودات المبيعات',
                value: summary.returnsValue,
                icon: Icons.assignment_return_rounded,
              ),
              _InfoRow(
                label: 'تكلفة المبيعات',
                value: summary.costOfGoods,
                icon: Icons.shopping_cart_checkout_rounded,
              ),
              _InfoRow(
                label: 'ذمم العملاء',
                value: summary.receivables,
                icon: Icons.groups_rounded,
              ),
              _InfoRow(
                label: 'قيمة المخزون',
                value: summary.inventoryValue,
                icon: Icons.warehouse_rounded,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showProfitDialog(
    ReportSummary summary,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الأرباح والخسائر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogLine('صافي المبيعات', summary.netSales),
            _DialogLine('تكلفة المبيعات', -summary.costOfGoods),
            _DialogLine('المصروفات', -summary.expenses),
            const Divider(),
            _DialogLine(
              'صافي الربح',
              summary.netProfit,
              emphasized: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBalanceDialog(
    ReportSummary summary,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الميزانية المختصرة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogLine(
              'قيمة المخزون',
              summary.inventoryValue,
            ),
            _DialogLine(
              'ذمم العملاء',
              summary.receivables,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class _ReportBundle {
  const _ReportBundle(
    this.summary,
    this.trend,
  );

  final ReportSummary summary;
  final List<ReportPoint> trend;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.emeraldDark,
            size: 25,
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 22,
                color: AppColors.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Text(
            'ر.ي',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReportCard extends StatelessWidget {
  const _QuickReportCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F4),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: AppColors.emeraldDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.emeraldDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toStringAsFixed(0) + ' ر.ي',
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogLine extends StatelessWidget {
  const _DialogLine(
    this.label,
    this.value, {
    this.emphasized = false,
  });

  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: emphasized
                    ? FontWeight.w900
                    : FontWeight.w600,
              ),
            ),
          ),
          Text(
            value.toStringAsFixed(0) + ' ر.ي',
            style: TextStyle(
              color: value < 0
                  ? Colors.red.shade700
                  : AppColors.navy,
              fontWeight: FontWeight.w900,
              fontSize: emphasized ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.points,
  });

  final List<ReportPoint> points;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrendPainter(points),
      child: const SizedBox.expand(),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.points);

  final List<ReportPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxValue = math.max(
      1.0,
      points
          .map((point) => point.value)
          .fold<double>(0, math.max),
    );

    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    final barPaint = Paint()
      ..color = AppColors.emerald.withValues(alpha: .75);

    final linePaint = Paint()
      ..color = AppColors.emeraldDark
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.emeraldDark;

    final chartHeight = size.height - 34;
    final slot = size.width / points.length;
    final path = Path();

    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      axisPaint,
    );

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final ratio = point.value / maxValue;
      final barHeight = math.max(
        4.0,
        ratio * (chartHeight - 20),
      );
      final centerX = slot * i + slot / 2;
      final width = math.min(34.0, slot * .55);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - width / 2,
          chartHeight - barHeight,
          width,
          barHeight,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, barPaint);

      final pointOffset = Offset(
        centerX,
        chartHeight - barHeight - 5,
      );
      if (i == 0) {
        path.moveTo(
          pointOffset.dx,
          pointOffset.dy,
        );
      } else {
        path.lineTo(
          pointOffset.dx,
          pointOffset.dy,
        );
      }
      canvas.drawCircle(
        pointOffset,
        4,
        dotPaint,
      );

      final painter = TextPainter(
        text: TextSpan(
          text: point.label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: slot);

      painter.paint(
        canvas,
        Offset(
          centerX - painter.width / 2,
          chartHeight + 8,
        ),
      );
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(
    covariant _TrendPainter oldDelegate,
  ) {
    return oldDelegate.points != points;
  }
}
