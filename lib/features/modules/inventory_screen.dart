import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'demo_store.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = DemoStore.products
        .where((item) =>
            item.name.contains(query) || item.sku.contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('المخزون')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => query = value.trim()),
              decoration: const InputDecoration(
                hintText: 'ابحث باسم الصنف أو الباركود',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final low = item.stock < 10;
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
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              item.stock.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: low ? Colors.red.shade700 : AppColors.text,
                              ),
                            ),
                            const Text(
                              'متوفر',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ],
                    ),
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
