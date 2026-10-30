import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';
import 'barcode_scanner_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final searchController = TextEditingController();
  late Future<List<ProductRecord>> future;

  String query = '';
  String filter = 'all';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _reload() {
    future = AppDatabase.instance.getProducts();
  }

  List<ProductRecord> _applyFilters(
    List<ProductRecord> source,
  ) {
    final normalized = query.trim();

    return source.where((product) {
      final matchesQuery = normalized.isEmpty ||
          product.name.contains(normalized) ||
          product.sku.contains(normalized);

      final matchesFilter = switch (filter) {
        'low' => product.trackStock && product.stock <= 10,
        'available' => !product.trackStock || product.stock > 10,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<void> _openProductEditor({
    ProductRecord? product,
  }) async {
    final name = TextEditingController(
      text: product?.name ?? '',
    );
    final sku = TextEditingController(
      text: product?.sku ?? '',
    );
    final sale = TextEditingController(
      text: product == null
          ? ''
          : product.salePrice.toStringAsFixed(0),
    );
    final cost = TextEditingController(
      text: product == null
          ? ''
          : product.costPrice.toStringAsFixed(0),
    );
    final stock = TextEditingController(
      text: product == null
          ? '0'
          : product.stock.toStringAsFixed(0),
    );
    final category = TextEditingController(
      text: product?.category ?? '',
    );

    bool trackStock = product?.trackStock ?? true;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Container(
                constraints:
                    const BoxConstraints(maxHeight: 680),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  18,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius:
                              BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product == null
                                  ? 'إضافة صنف'
                                  : 'تحرير الصنف',
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.inventory_2_rounded,
                            color: AppColors.emeraldDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: name,
                        decoration:
                            const InputDecoration(
                          labelText: 'اسم الصنف',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: sku,
                              decoration:
                                  const InputDecoration(
                                labelText: 'الباركود / SKU',
                                prefixIcon: Icon(
                                  Icons.qr_code_rounded,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'مسح الباركود',
                            onPressed: () async {
                              final code =
                                  await Navigator.of(context)
                                      .push<String>(
                                MaterialPageRoute<String>(
                                  builder: (_) =>
                                      const BarcodeScannerScreen(
                                    title: 'باركود الصنف',
                                  ),
                                ),
                              );
                              if (code != null) {
                                sku.text = code;
                              }
                            },
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: category,
                        decoration:
                            const InputDecoration(
                          labelText: 'التصنيف',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: sale,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText: 'سعر البيع',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: cost,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText: 'التكلفة',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: stock,
                        enabled: trackStock,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText: 'الكمية',
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: trackStock,
                        onChanged: (value) {
                          setSheetState(() {
                            trackStock = value;
                          });
                        },
                        title:
                            const Text('متابعة المخزون'),
                        subtitle: const Text(
                          'أوقفها للوجبات والخدمات',
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            if (name.text.trim().isEmpty ||
                                sku.text.trim().isEmpty) {
                              return;
                            }

                            if (product == null) {
                              await AppDatabase.instance
                                  .addProduct(
                                name: name.text,
                                sku: sku.text,
                                salePrice:
                                    double.tryParse(
                                          sale.text,
                                        ) ??
                                        0,
                                costPrice:
                                    double.tryParse(
                                          cost.text,
                                        ) ??
                                        0,
                                stock: trackStock
                                    ? double.tryParse(
                                          stock.text,
                                        ) ??
                                        0
                                    : 0,
                                trackStock: trackStock,
                                category:
                                    category.text,
                              );
                            } else {
                              await AppDatabase.instance
                                  .updateProduct(
                                id: product.id,
                                name: name.text,
                                sku: sku.text,
                                salePrice:
                                    double.tryParse(
                                          sale.text,
                                        ) ??
                                        0,
                                costPrice:
                                    double.tryParse(
                                          cost.text,
                                        ) ??
                                        0,
                                stock: trackStock
                                    ? double.tryParse(
                                          stock.text,
                                        ) ??
                                        0
                                    : 0,
                                trackStock: trackStock,
                                category:
                                    category.text,
                              );
                            }

                            if (sheetContext.mounted) {
                              Navigator.pop(
                                sheetContext,
                                true,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.save_rounded,
                          ),
                          label: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: Text(
                              product == null
                                  ? 'إضافة الصنف'
                                  : 'حفظ التعديلات',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DiftiriAppBar(
        title: 'المخزون',
        subtitle: 'الأصناف والكميات والباركود',
        icon: Icons.inventory_2_rounded,
        tone: DiftiriTone.mint,
        actions: [
          IconButton(
            tooltip: 'إضافة صنف',
            onPressed: () => _openProductEditor(),
            icon: const Icon(
              Icons.add_circle_rounded,
              color: AppColors.emeraldDark,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => _openProductEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة صنف'),
      ),
      body: FutureBuilder<List<ProductRecord>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allProducts = snapshot.data!;
          final visible =
              _applyFilters(allProducts);
          final lowCount = allProducts
              .where(
                (product) =>
                    product.trackStock &&
                    product.stock <= 10,
              )
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  0,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                  decoration:
                      const InputDecoration(
                    hintText:
                        'ابحث عن صنف في المخزون',
                    prefixIcon:
                        Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    _InventoryFilter(
                      label: 'كل الأصناف',
                      value: 'all',
                      current: filter,
                      onTap: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                    ),
                    _InventoryFilter(
                      label: 'منخفض',
                      value: 'low',
                      current: filter,
                      onTap: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                    ),
                    _InventoryFilter(
                      label: 'متوفر',
                      value: 'available',
                      current: filter,
                      onTap: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _InventoryStatCard(
                        label: 'إجمالي الأصناف',
                        value:
                            allProducts.length.toString(),
                        icon:
                            Icons.inventory_2_rounded,
                        warning: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InventoryStatCard(
                        label: 'أصناف منخفضة',
                        value: lowCount.toString(),
                        icon:
                            Icons.warning_amber_rounded,
                        warning: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: visible.isEmpty
                    ? const DiftiriEmptyState(
                        icon: Icons.inventory_2_rounded,
                        title: 'لا توجد أصناف مطابقة',
                        message: 'جرّب تغيير البحث أو الفلتر، أو أضف صنفًا جديدًا.',
                      )
                    : ListView.separated(
                        key: const Key(
                          'inventory-list',
                        ),
                        padding:
                            const EdgeInsets.fromLTRB(
                          14,
                          0,
                          14,
                          90,
                        ),
                        itemCount: visible.length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          height: 9,
                        ),
                        itemBuilder:
                            (context, index) {
                          final item =
                              visible[index];
                          return _InventoryItem(
                            item: item,
                            onTap: () =>
                                _openProductEditor(
                              product: item,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InventoryFilter extends StatelessWidget {
  const _InventoryFilter({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = current == value;

    return Padding(
      padding:
          const EdgeInsetsDirectional.only(
        end: 8,
      ),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(value),
        selectedColor: AppColors.emerald,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? AppColors.emerald
              : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : AppColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InventoryStatCard extends StatelessWidget {
  const _InventoryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.warning,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final foreground = warning
        ? Colors.red.shade700
        : AppColors.emeraldDark;
    final background = warning
        ? const Color(0xFFFFECEC)
        : const Color(0xFFE8F8F4);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight:
                        FontWeight.w900,
                    fontSize: 25,
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

class _InventoryItem extends StatelessWidget {
  const _InventoryItem({
    required this.item,
    required this.onTap,
  });

  final ProductRecord item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final low =
        item.trackStock && item.stock <= 10;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              const DiftiriIconBox(
                icon: Icons.inventory_2_rounded,
                tone: DiftiriTone.mint,
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    Text(
                      'SKU: ' + item.sku,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    if (item.category.isNotEmpty)
                      Text(
                        item.category,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                              AppColors.emeraldDark,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  const Text(
                    'الكمية',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    item.trackStock
                        ? item.stock
                            .toStringAsFixed(0)
                        : '∞',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: low
                          ? const Color(
                              0xFFFFE8E8,
                            )
                          : const Color(
                              0xFFE3F8F1,
                            ),
                      borderRadius:
                          BorderRadius.circular(
                        999,
                      ),
                    ),
                    child: Text(
                      low ? 'منخفض' : 'متوفر',
                      style: TextStyle(
                        color: low
                            ? Colors.red.shade700
                            : AppColors
                                .emeraldDark,
                        fontWeight:
                            FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
