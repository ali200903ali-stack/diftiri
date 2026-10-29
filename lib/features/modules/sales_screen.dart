import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final Map<int, int> quantities = {};
  List<ProductRecord> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final result = await AppDatabase.instance.getProducts();
    if (!mounted) return;

    setState(() {
      products = result;
      loading = false;
    });
  }

  double get total {
    var value = 0.0;
    for (final entry in quantities.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);
      value += product.salePrice * entry.value;
    }
    return value;
  }

  void add(ProductRecord product) {
    final current = quantities[product.id] ?? 0;

    if (product.trackStock && current >= product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('المخزون غير كافٍ للصنف ' + product.name),
        ),
      );
      return;
    }

    setState(() {
      quantities[product.id] = current + 1;
    });
  }

  void remove(int productId) {
    setState(() {
      final current = quantities[productId] ?? 0;
      if (current <= 1) {
        quantities.remove(productId);
      } else {
        quantities[productId] = current - 1;
      }
    });
  }

  Future<void> _completeSale() async {
    try {
      await AppDatabase.instance.recordSale(quantities);

      if (!mounted) return;
      setState(quantities.clear);
      await _loadProducts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل البيع والقيد المحاسبي وتحديث المخزون',
          ),
        ),
      );
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

    final desktop = MediaQuery.sizeOf(context).width >= 900;

    final productsGrid = GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final item = products[index];

        return InkWell(
          onTap: () => add(item),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shopping_basket_rounded,
                  color: AppColors.emeraldDark,
                  size: 34,
                ),
                const Spacer(),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  item.salePrice.toStringAsFixed(0) + ' ر.ي',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (item.trackStock)
                  Text(
                    'متوفر ' + item.stock.toStringAsFixed(0),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    final cart = _CartPanel(
      products: products,
      quantities: quantities,
      total: total,
      onAdd: (id) {
        add(products.firstWhere((p) => p.id == id));
      },
      onRemove: remove,
      onClear: () {
        setState(quantities.clear);
      },
      onComplete: _completeSale,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('نقطة البيع')),
      body: desktop
          ? Row(
              children: [
                Expanded(flex: 3, child: productsGrid),
                SizedBox(width: 390, child: cart),
              ],
            )
          : Column(
              children: [
                Expanded(child: productsGrid),
                SizedBox(height: 285, child: cart),
              ],
            ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({
    required this.products,
    required this.quantities,
    required this.total,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
    required this.onComplete,
  });

  final List<ProductRecord> products;
  final Map<int, int> quantities;
  final double total;
  final ValueChanged<int> onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onClear;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'السلة',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('مسح'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: quantities.isEmpty
                ? const Center(
                    child: Text(
                      'اضغط على صنف لإضافته',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView(
                    children: quantities.entries.map((entry) {
                      final item = products.firstWhere(
                        (p) => p.id == entry.key,
                      );

                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => onRemove(entry.key),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          IconButton(
                            onPressed: () => onAdd(entry.key),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                total.toStringAsFixed(0) + ' ر.ي',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: quantities.isEmpty ? null : onComplete,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'إتمام البيع',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
