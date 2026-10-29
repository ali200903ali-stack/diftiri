import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String query = '';
  late Future<List<ProductRecord>> productsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    productsFuture = AppDatabase.instance.getProducts(query: query);
  }

  Future<void> _showAddProduct() async {
    final name = TextEditingController();
    final sku = TextEditingController();
    final sale = TextEditingController();
    final cost = TextEditingController();
    final stock = TextEditingController(text: '0');
    bool trackStock = true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة صنف'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم الصنف')),
                  const SizedBox(height: 10),
                  TextField(controller: sku, decoration: const InputDecoration(labelText: 'الباركود / الكود')),
                  const SizedBox(height: 10),
                  TextField(controller: sale, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر البيع')),
                  const SizedBox(height: 10),
                  TextField(controller: cost, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر التكلفة')),
                  const SizedBox(height: 10),
                  TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الرصيد الافتتاحي')),
                  SwitchListTile(
                    value: trackStock,
                    onChanged: (value) {
                      setDialogState(() {
                        trackStock = value;
                      });
                    },
                    title: const Text('متابعة المخزون'),
                    subtitle: const Text('أوقفها للوجبات والخدمات'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || sku.text.trim().isEmpty) return;
                await AppDatabase.instance.addProduct(
                  name: name.text,
                  sku: sku.text,
                  salePrice: double.tryParse(sale.text) ?? 0,
                  costPrice: double.tryParse(cost.text) ?? 0,
                  stock: double.tryParse(stock.text) ?? 0,
                  trackStock: trackStock,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المخزون والمنتجات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProduct,
        icon: const Icon(Icons.add_rounded),
        label: const Text('صنف جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                query = value.trim();
                setState(_reload);
              },
              decoration: const InputDecoration(
                hintText: 'ابحث باسم الصنف أو الباركود',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<ProductRecord>>(
                future: productsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!;
                  if (products.isEmpty) {
                    return const Center(child: Text('لا توجد أصناف'));
                  }

                  return ListView.separated(
                    key: const Key('inventory-list'),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = products[index];
                      final low = item.trackStock && item.stock <= 10;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F8F4),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.inventory_2_rounded,
                                color: AppColors.emeraldDark,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    'باركود: ' + item.sku,
                                    style: const TextStyle(color: AppColors.muted),
                                  ),
                                  Text(
                                    'بيع ' +
                                        item.salePrice.toStringAsFixed(0) +
                                        ' ر.ي • تكلفة ' +
                                        item.costPrice.toStringAsFixed(0) +
                                        ' ر.ي',
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  item.trackStock
                                      ? item.stock.toStringAsFixed(0)
                                      : '∞',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    color: low
                                        ? Colors.red.shade700
                                        : AppColors.text,
                                  ),
                                ),
                                Text(
                                  item.trackStock ? 'متوفر' : 'غير مخزني',
                                  style: const TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
