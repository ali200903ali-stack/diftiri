import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';

class RestaurantTablesScreen
    extends StatefulWidget {
  const RestaurantTablesScreen({super.key});

  @override
  State<RestaurantTablesScreen> createState() =>
      _RestaurantTablesScreenState();
}

class _RestaurantTablesScreenState
    extends State<RestaurantTablesScreen> {
  late Future<List<RestaurantTableRecord>> future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    future =
        AppDatabase.instance.getRestaurantTables();
  }

  Future<void> _addTable() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة طاولة'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'اسم الطاولة',
              hintText: 'مثال: طاولة 5',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.pop(
                  dialogContext,
                  value,
                );
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name == null) return;

    try {
      await AppDatabase.instance
          .addRestaurantTable(name);

      if (!mounted) return;
      setState(_reload);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اسم الطاولة موجود مسبقاً',
          ),
        ),
      );
    }
  }

  Future<void> _removeTable(
    RestaurantTableRecord table,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعطيل الطاولة'),
          content: Text(
            'هل تريد تعطيل ' +
                table.name +
                '؟',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                true,
              ),
              child: const Text('تعطيل'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await AppDatabase.instance
        .deactivateRestaurantTable(table.id);

    if (!mounted) return;
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DiftiriAppBar(
        title: 'طاولات المطعم',
        subtitle: 'إدارة الطاولات والطلبات المحلية',
        icon: Icons.table_restaurant_rounded,
        tone: DiftiriTone.mint,
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addTable,
        icon: const Icon(Icons.add_rounded),
        label: const Text('طاولة جديدة'),
      ),
      body:
          FutureBuilder<List<RestaurantTableRecord>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final tables = snapshot.data!;
          if (tables.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'لا توجد طاولات. أضف أول طاولة من الزر بالأسفل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            key: const Key('restaurant-tables-grid'),
            padding: const EdgeInsets.fromLTRB(
              14,
              14,
              14,
              90,
            ),
            gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 190,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons
                                .table_restaurant_rounded,
                            size: 38,
                            color:
                                AppColors.emeraldDark,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            table.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 2,
                      left: 2,
                      child: IconButton(
                        tooltip: 'تعطيل',
                        visualDensity:
                            VisualDensity.compact,
                        onPressed: () =>
                            _removeTable(table),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 19,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
