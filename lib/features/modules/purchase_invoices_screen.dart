import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';
import 'purchase_invoice_editor_screen.dart';

class PurchaseInvoicesScreen extends StatefulWidget {
  const PurchaseInvoicesScreen({super.key});

  @override
  State<PurchaseInvoicesScreen> createState() =>
      _PurchaseInvoicesScreenState();
}

class _PurchaseInvoicesScreenState
    extends State<PurchaseInvoicesScreen> {
  final searchController = TextEditingController();
  String query = '';
  String status = 'all';
  late Future<List<PurchaseInvoiceRecord>> future;

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
    future = AppDatabase.instance.getPurchaseInvoices(
      query: query,
      status: status,
    );
  }

  Future<void> _openEditor({int? purchaseId}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PurchaseInvoiceEditorScreen(
          purchaseId: purchaseId,
        ),
      ),
    );
    if (changed == true && mounted) {
      setState(_reload);
    }
  }

  void _setStatus(String value) {
    setState(() {
      status = value;
      _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DiftiriAppBar(
        title: 'فواتير المشتريات',
        subtitle: 'إدارة فواتير الموردين والطباعة',
        icon: Icons.shopping_bag_rounded,
        tone: DiftiriTone.emerald,
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('فاتورة شراء'),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              14,
              10,
              14,
              8,
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                query = value;
                setState(_reload);
              },
              decoration:
                  const InputDecoration(
                hintText:
                    'ابحث برقم الفاتورة أو المورد',
                prefixIcon:
                    Icon(Icons.search_rounded),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            child: Row(
              children: [
                _PurchaseFilter(
                  label: 'الكل',
                  value: 'all',
                  current: status,
                  onTap: _setStatus,
                ),
                _PurchaseFilter(
                  label: 'مدفوعة',
                  value: 'paid',
                  current: status,
                  onTap: _setStatus,
                ),
                _PurchaseFilter(
                  label: 'آجلة',
                  value: 'unpaid',
                  current: status,
                  onTap: _setStatus,
                ),
                _PurchaseFilter(
                  label: 'مسودة',
                  value: 'draft',
                  current: status,
                  onTap: _setStatus,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<
                List<PurchaseInvoiceRecord>>(
              future: future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final rows = snapshot.data!;
                if (rows.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد فواتير شراء مطابقة',
                      style: TextStyle(
                        color: AppColors.muted,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  key: const Key(
                    'purchase-invoices-list',
                  ),
                  padding:
                      const EdgeInsets.fromLTRB(
                    14,
                    6,
                    14,
                    90,
                  ),
                  itemCount: rows.length,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(
                    height: 10,
                  ),
                  itemBuilder:
                      (context, index) {
                    final invoice =
                        rows[index];
                    return _PurchaseCard(
                      invoice: invoice,
                      onTap: () =>
                          _openEditor(
                        purchaseId:
                            invoice.id,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseFilter extends StatelessWidget {
  const _PurchaseFilter({
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

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.invoice,
    required this.onTap,
  });

  final PurchaseInvoiceRecord invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = invoice.createdAt.toLocal();
    final dateText =
        date.year.toString() +
        '/' +
        date.month
            .toString()
            .padLeft(2, '0') +
        '/' +
        date.day
            .toString()
            .padLeft(2, '0');

    final label = invoice.status == 'paid'
        ? 'مدفوعة'
        : invoice.status == 'unpaid'
            ? 'آجلة'
            : 'مسودة';

    final color = invoice.status == 'paid'
        ? AppColors.emeraldDark
        : invoice.status == 'unpaid'
            ? Colors.red.shade700
            : const Color(0xFFE67E00);

    final background =
        invoice.status == 'paid'
            ? const Color(0xFFE3F8F1)
            : invoice.status == 'unpaid'
                ? const Color(0xFFFFE8E8)
                : const Color(
                    0xFFFFF1DD,
                  );

    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
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
                icon: Icons.shopping_bag_rounded,
                tone: DiftiriTone.emerald,
                size: 52,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invoice
                                .invoiceNumber,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: background,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              999,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: color,
                              fontWeight:
                                  FontWeight
                                      .w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice.supplierName
                              .isEmpty
                          ? 'مورد غير محدد'
                          : invoice
                              .supplierName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          dateText,
                          style:
                              const TextStyle(
                            color:
                                AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        FittedBox(
                          fit:
                              BoxFit.scaleDown,
                          child: Text(
                            invoice.total
                                    .toStringAsFixed(
                                  0,
                                ) +
                                ' ر.ي',
                            style:
                                const TextStyle(
                              color:
                                  AppColors.navy,
                              fontWeight:
                                  FontWeight
                                      .w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
