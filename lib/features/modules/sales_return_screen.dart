import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({
    super.key,
    required this.saleId,
  });

  final int saleId;

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  List<SaleItemRecord> items = [];
  final Map<int, double> quantities = {};
  final note = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    items = await AppDatabase.instance.getSaleItems(widget.saleId);
    for (final item in items) {
      quantities[item.id] = 0;
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  double get total {
    var value = 0.0;
    for (final item in items) {
      value += (quantities[item.id] ?? 0) * item.unitPrice;
    }
    return value;
  }

  void _returnAll() {
    setState(() {
      for (final item in items) {
        quantities[item.id] = item.returnableQuantity;
      }
    });
  }

  Future<void> _save() async {
    final selected = <int, double>{};
    for (final entry in quantities.entries) {
      if (entry.value > 0) selected[entry.key] = entry.value;
    }

    try {
      await AppDatabase.instance.recordSaleReturn(
        saleId: widget.saleId,
        quantitiesBySaleItem: selected,
        note: note.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل المرتجع وتحديث المخزون والحسابات',
          ),
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
        title: const Text('مرتجع مبيعات'),
        actions: [
          TextButton(
            onPressed: _returnAll,
            child: const Text('إرجاع الكل'),
          ),
        ],
      ),
      body: ListView(
        key: const Key('sales-return-list'),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFE67E00),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'حدد الكميات المراد إرجاعها. لا يمكن تجاوز الكمية المتاحة للمرتجع.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            _ReturnItemCard(
              item: item,
              value: quantities[item.id] ?? 0,
              onChanged: (value) {
                setState(() {
                  quantities[item.id] = value
                      .clamp(0.0, item.returnableQuantity)
                      .toDouble();
                });
              },
            ),
          const SizedBox(height: 12),
          TextField(
            controller: note,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'ملاحظة المرتجع',
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'إجمالي المرتجع',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    total.toStringAsFixed(0) + ' ر.ي',
                    style: const TextStyle(
                      fontSize: 22,
                      color: AppColors.navy,
                      fontWeight: FontWeight.w900,
                    ),
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
            onPressed: total <= 0 ? null : _save,
            icon: const Icon(Icons.assignment_return_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text(
                'حفظ المرتجع',
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

class _ReturnItemCard extends StatelessWidget {
  const _ReturnItemCard({
    required this.item,
    required this.value,
    required this.onChanged,
  });

  final SaleItemRecord item;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE8F8F4),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.emeraldDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'مباع ' +
                          item.quantity.toStringAsFixed(0) +
                          ' • متاح ' +
                          item.returnableQuantity.toStringAsFixed(0),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.unitPrice.toStringAsFixed(0) + ' ر.ي',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed:
                    value <= 0 ? null : () => onChanged(value - 1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: Text(
                  value.toStringAsFixed(0),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: value >= item.returnableQuantity
                    ? null
                    : () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
