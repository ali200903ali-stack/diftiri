import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import 'purchase_history_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<ProductRecord> products = [];
  int? productId;
  final qty = TextEditingController(text: '1');
  final cost = TextEditingController();
  final supplier = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await AppDatabase.instance.getProducts();
    if (!mounted) return;

    setState(() {
      products = result.where((p) => p.trackStock).toList();
      if (productId == null && products.isNotEmpty) {
        productId = products.first.id;
      }
      if (productId != null) {
        final product = products.firstWhere((p) => p.id == productId);
        cost.text = product.costPrice.toStringAsFixed(0);
      }
    });
  }

  Future<void> _save() async {
    if (productId == null) return;

    try {
      await AppDatabase.instance.recordPurchase(
        productId: productId!,
        quantity: double.tryParse(qty.text) ?? 0,
        unitCost: double.tryParse(cost.text) ?? 0,
        supplierName: supplier.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل الشراء وتحديث المخزون والقيد المحاسبي',
          ),
        ),
      );

      qty.text = '1';
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المشتريات'),
        actions: [
          IconButton(
            tooltip: 'سجل المشتريات',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const PurchaseHistoryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.history_rounded,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: productId,
                  decoration: const InputDecoration(labelText: 'الصنف'),
                  items: products
                      .map(
                        (p) => DropdownMenuItem<int>(
                          value: p.id,
                          child: Text(p.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      productId = value;
                      if (value != null) {
                        cost.text = products
                            .firstWhere((p) => p.id == value)
                            .costPrice
                            .toStringAsFixed(0);
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qty,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cost,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'تكلفة الوحدة'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: supplier,
                  decoration: const InputDecoration(
                    labelText: 'اسم المورد - اختياري',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text('حفظ فاتورة الشراء'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
