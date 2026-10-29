import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'demo_store.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final Map<int, int> quantities = {};

  double get total {
    var value = 0.0;
    quantities.forEach((index, quantity) {
      value += DemoStore.products[index].price * quantity;
    });
    return value;
  }

  void add(int index) {
    setState(() {
      quantities[index] = (quantities[index] ?? 0) + 1;
    });
  }

  void remove(int index) {
    setState(() {
      final current = quantities[index] ?? 0;
      if (current <= 1) {
        quantities.remove(index);
      } else {
        quantities[index] = current - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;

    final products = GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: DemoStore.products.length,
      itemBuilder: (context, index) {
        final item = DemoStore.products[index];
        return InkWell(
          onTap: () => add(index),
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
                  item.price.toStringAsFixed(0) + ' ر.ي',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    final cart = _CartPanel(
      quantities: quantities,
      total: total,
      onAdd: add,
      onRemove: remove,
      onClear: () => setState(quantities.clear),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('نقطة البيع')),
      body: desktop
          ? Row(
              children: [
                Expanded(flex: 3, child: products),
                SizedBox(width: 380, child: cart),
              ],
            )
          : Column(
              children: [
                Expanded(child: products),
                SizedBox(height: 270, child: cart),
              ],
            ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({
    required this.quantities,
    required this.total,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
  });

  final Map<int, int> quantities;
  final double total;
  final ValueChanged<int> onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onClear;

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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(onPressed: onClear, child: const Text('مسح')),
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
                      final item = DemoStore.products[entry.key];
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            onPressed: () => onRemove(entry.key),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w900),
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
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
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
              onPressed: quantities.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تسجيل عملية بيع تجريبية'),
                        ),
                      );
                    },
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
