import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';
import '../../core/theme/app_ui_preferences.dart';
import 'barcode_scanner_screen.dart';
import 'sales_history_screen.dart';
import 'restaurant_tables_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({
    super.key,
    this.activityTypeOverride,
  });

  final String? activityTypeOverride;

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final Map<int, int> quantities = {};
  final searchController = TextEditingController();

  List<ProductRecord> products = [];
  List<RestaurantTableRecord> restaurantTables = [];
  BusinessSettingsRecord? businessSettings;
  bool loading = true;
  String query = '';
  String orderType = 'retail';
  int? selectedTableId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final result = await AppDatabase.instance.getProducts();
    final settings = widget.activityTypeOverride == null
        ? await AppDatabase.instance.getBusinessSettings()
        : BusinessSettingsRecord(
            businessName: 'منشأتي',
            activityType: widget.activityTypeOverride!,
            currency: 'YER',
          );
    final tables =
        await AppDatabase.instance.getRestaurantTables();

    if (!mounted) return;

    final restaurantEnabled =
        settings.activityType == 'restaurant' ||
        settings.activityType == 'mixed';

    setState(() {
      products = result;
      businessSettings = settings;
      restaurantTables = tables;

      if (restaurantEnabled && orderType == 'retail') {
        orderType = 'takeaway';
      }

      if (!restaurantEnabled) {
        orderType = 'retail';
        selectedTableId = null;
      } else if (selectedTableId == null &&
          tables.isNotEmpty) {
        selectedTableId = tables.first.id;
      }

      loading = false;
    });
  }

  List<ProductRecord> get visibleProducts {
    final normalized = query.trim();
    if (normalized.isEmpty) return products;

    return products
        .where(
          (product) =>
              product.name.contains(normalized) ||
              product.sku.contains(normalized),
        )
        .toList();
  }

  bool get restaurantEnabled {
    final activity = businessSettings?.activityType;
    return activity == 'restaurant' ||
        activity == 'mixed';
  }

  String get selectedTableName {
    if (selectedTableId == null) return '';

    for (final table in restaurantTables) {
      if (table.id == selectedTableId) {
        return table.name;
      }
    }

    return '';
  }

  int get cartCount {
    return quantities.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
  }

  double get total {
    var value = 0.0;

    for (final entry in quantities.entries) {
      final product = products.firstWhere(
        (item) => item.id == entry.key,
      );
      value += product.salePrice * entry.value;
    }

    return value;
  }

  void add(ProductRecord product) {
    final current = quantities[product.id] ?? 0;

    if (product.trackStock && current >= product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'المخزون غير كافٍ للصنف ' + product.name,
          ),
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

  Future<bool> _completeSale() async {
    try {
      if (restaurantEnabled &&
          orderType == 'dine_in' &&
          selectedTableId == null) {
        throw StateError('اختر الطاولة قبل إتمام الطلب');
      }

      await AppDatabase.instance.recordSale(
        quantities,
        orderType: orderType,
        tableName: orderType == 'dine_in'
            ? selectedTableName
            : '',
      );

      if (!mounted) return false;

      setState(quantities.clear);
      await _loadProducts();

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل البيع وتحديث المخزون والقيد المحاسبي',
          ),
        ),
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );

      return false;
    }
  }

  Future<bool> _addBarcode(String code) async {
    ProductRecord? matched;
    for (final product in products) {
      if (product.sku.trim() == code.trim()) {
        matched = product;
        break;
      }
    }

    if (matched == null) {
      return false;
    }

    add(matched);
    return true;
  }

  Future<void> _openBarcodeScanner() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BarcodeScannerScreen(
          title: 'ماسح الكاشير',
          onBarcode: _addBarcode,
        ),
      ),
    );
  }

  Future<void> _showMobileCart() async {
    if (quantities.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void refresh(VoidCallback action) {
              action();
              setSheetState(() {});
            }

            return FractionallySizedBox(
              heightFactor: .72,
              child: _CartPanel(
                products: products,
                quantities: quantities,
                total: total,
                onAdd: (id) {
                  refresh(
                    () => add(
                      products.firstWhere(
                        (product) => product.id == id,
                      ),
                    ),
                  );
                },
                onRemove: (id) {
                  refresh(() => remove(id));
                },
                onClear: () {
                  refresh(() {
                    setState(quantities.clear);
                  });
                },
                onComplete: () async {
                  final success = await _completeSale();
                  if (success && sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                  return success;
                },
                sheetMode: true,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;
    final veryNarrow = width < 350;
    final productColumns = desktop ? 4 : (veryNarrow ? 1 : 2);

    final content = Column(
      children: [
        if (restaurantEnabled)
          _RestaurantOrderControls(
            orderType: orderType,
            tables: restaurantTables,
            selectedTableId: selectedTableId,
            onOrderTypeChanged: (value) {
              setState(() {
                orderType = value;
                if (value == 'dine_in' &&
                    selectedTableId == null &&
                    restaurantTables.isNotEmpty) {
                  selectedTableId =
                      restaurantTables.first.id;
                }
              });
            },
            onTableChanged: (value) {
              setState(() {
                selectedTableId = value;
              });
            },
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            desktop ? 20 : 14,
            desktop ? 18 : 10,
            desktop ? 20 : 14,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('sales-search'),
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن صنف أو باركود',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              if (AppUiPreferences.instance.saleScannerEnabled) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 54,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.navy,
                    ),
                    onPressed: _openBarcodeScanner,
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 27,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: visibleProducts.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد أصناف مطابقة',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : GridView.builder(
                  key: const Key('sales-products-grid'),
                  padding: EdgeInsets.fromLTRB(
                    desktop ? 20 : 14,
                    6,
                    desktop ? 20 : 14,
                    18,
                  ),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: productColumns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: desktop ? 1.18 : 1.12,
                  ),
                  itemCount: visibleProducts.length,
                  itemBuilder: (context, index) {
                    final item = visibleProducts[index];

                    return _ProductCard(
                      product: item,
                      quantity: quantities[item.id] ?? 0,
                      onTap: () => add(item),
                    );
                  },
                ),
        ),
      ],
    );

    return Scaffold(
      appBar: DiftiriAppBar(
        title: 'نقطة البيع',
        subtitle: 'كاشير سريع، باركود وسلة مباشرة',
        icon: Icons.point_of_sale_rounded,
        tone: DiftiriTone.navy,
        actions: [
          IconButton(
            tooltip: 'سجل المبيعات',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const SalesHistoryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.history_rounded,
            ),
          ),
          if (restaurantEnabled)
            IconButton(
              tooltip: 'الطاولات',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const RestaurantTablesScreen(),
                  ),
                );
                await _loadProducts();
              },
              icon: const Icon(
                Icons.table_restaurant_rounded,
              ),
            ),
          if (!desktop)
            IconButton(
              tooltip: 'السلة',
              onPressed: quantities.isEmpty
                  ? null
                  : _showMobileCart,
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text(cartCount.toString()),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                ),
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: desktop
          ? Row(
              children: [
                Expanded(flex: 3, child: content),
                SizedBox(
                  width: 390,
                  child: _CartPanel(
                    products: products,
                    quantities: quantities,
                    total: total,
                    onAdd: (id) {
                      add(
                        products.firstWhere(
                          (product) => product.id == id,
                        ),
                      );
                    },
                    onRemove: remove,
                    onClear: () {
                      setState(quantities.clear);
                    },
                    onComplete: _completeSale,
                  ),
                ),
              ],
            )
          : content,
      bottomNavigationBar: desktop
          ? null
          : _MobileCartBar(
              itemCount: cartCount,
              total: total,
              onTap: _showMobileCart,
            ),
    );
  }
}

class _RestaurantOrderControls
    extends StatelessWidget {
  const _RestaurantOrderControls({
    required this.orderType,
    required this.tables,
    required this.selectedTableId,
    required this.onOrderTypeChanged,
    required this.onTableChanged,
  });

  final String orderType;
  final List<RestaurantTableRecord> tables;
  final int? selectedTableId;
  final ValueChanged<String> onOrderTypeChanged;
  final ValueChanged<int?> onTableChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('restaurant-order-controls'),
      margin: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _OrderTypeButton(
                  label: 'سفري',
                  icon: Icons.takeout_dining_rounded,
                  selected:
                      orderType == 'takeaway',
                  onTap: () =>
                      onOrderTypeChanged(
                    'takeaway',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OrderTypeButton(
                  label: 'محلي',
                  icon:
                      Icons.table_restaurant_rounded,
                  selected:
                      orderType == 'dine_in',
                  onTap: () =>
                      onOrderTypeChanged(
                    'dine_in',
                  ),
                ),
              ),
            ],
          ),
          if (orderType == 'dine_in') ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: selectedTableId,
              decoration: const InputDecoration(
                labelText: 'الطاولة',
                prefixIcon: Icon(
                  Icons.table_restaurant_rounded,
                ),
              ),
              items: tables
                  .map(
                    (table) =>
                        DropdownMenuItem<int>(
                      value: table.id,
                      child: Text(table.name),
                    ),
                  )
                  .toList(),
              onChanged: tables.isEmpty
                  ? null
                  : onTableChanged,
            ),
            if (tables.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'أضف طاولة من زر الطاولات أعلى الشاشة',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OrderTypeButton extends StatelessWidget {
  const _OrderTypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFFE8F8F4)
          : AppColors.canvas,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? AppColors.emeraldDark
                    : AppColors.muted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: selected
                      ? AppColors.emeraldDark
                      : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.onTap,
  });

  final ProductRecord product;
  final int quantity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F4),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.shopping_basket_rounded,
                    color: AppColors.emeraldDark,
                    size: 25,
                  ),
                ),
                const Spacer(),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    product.salePrice.toStringAsFixed(0) + ' ر.ي',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (product.trackStock)
                  Text(
                    'متوفر ' + product.stock.toStringAsFixed(0),
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
          if (quantity > 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 27,
                  minHeight: 27,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileCartBar extends StatelessWidget {
  const _MobileCartBar({
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  final int itemCount;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: FilledButton(
          onPressed: itemCount == 0 ? null : onTap,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: Row(
            children: [
              Badge(
                isLabelVisible: itemCount > 0,
                label: Text(itemCount.toString()),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'عرض السلة',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                total.toStringAsFixed(0) + ' ر.ي',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
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
    this.sheetMode = false,
  });

  final List<ProductRecord> products;
  final Map<int, int> quantities;
  final double total;
  final ValueChanged<int> onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onClear;
  final Future<bool> Function() onComplete;
  final bool sheetMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: sheetMode
          ? EdgeInsets.zero
          : const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: sheetMode
            ? const BorderRadius.vertical(
                top: Radius.circular(28),
              )
            : BorderRadius.circular(26),
        border: sheetMode
            ? null
            : Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (sheetMode) ...[
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              const Expanded(
                child: Text(
                  'السلة',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: quantities.isEmpty
                    ? null
                    : onClear,
                child: const Text('مسح'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: quantities.isEmpty
                ? const Center(
                    child: Text(
                      'السلة فارغة',
                      style: TextStyle(
                        color: AppColors.muted,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: quantities.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry =
                          quantities.entries.elementAt(index);
                      final item = products.firstWhere(
                        (product) => product.id == entry.key,
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
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
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    item.salePrice.toStringAsFixed(0) + ' ر.ي',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              visualDensity:
                                  VisualDensity.compact,
                              onPressed: () =>
                                  onRemove(entry.key),
                              icon: const Icon(
                                Icons.remove_circle_outline,
                              ),
                            ),
                            SizedBox(
                              width: 28,
                              child: Text(
                                entry.value.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity:
                                  VisualDensity.compact,
                              onPressed: () =>
                                  onAdd(entry.key),
                              icon: const Icon(
                                Icons.add_circle_outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                    fontSize: 17,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  total.toStringAsFixed(0) + ' ر.ي',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    color: AppColors.navy,
                  ),
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
                  : () async {
                      await onComplete();
                    },
              icon: const Icon(
                Icons.check_circle_rounded,
              ),
              label: const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'إتمام البيع',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
