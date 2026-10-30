import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';
import 'invoice_editor_screen.dart';
import 'sales_screen.dart';

class SalesInvoicesScreen extends StatefulWidget {
  const SalesInvoicesScreen({super.key});

  @override
  State<SalesInvoicesScreen> createState() => _SalesInvoicesScreenState();
}

class _SalesInvoicesScreenState extends State<SalesInvoicesScreen> {
  final searchController = TextEditingController();
  String query = '';
  String status = 'all';
  late Future<List<SalesInvoiceRecord>> future;

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
    future = AppDatabase.instance.getSalesInvoices(
      query: query,
      status: status,
    );
  }

  Future<void> _openEditor({int? saleId}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InvoiceEditorScreen(saleId: saleId),
      ),
    );
    if (changed == true && mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DiftiriAppBar(
        title: 'فواتير المبيعات',
        subtitle: 'إنشاء، مراجعة، تعديل وطباعة فواتير البيع',
        icon: Icons.receipt_long_rounded,
        tone: DiftiriTone.navy,
        actions: [
          IconButton(
            tooltip: 'نقطة البيع',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SalesScreen(),
                ),
              );
              if (mounted) setState(_reload);
            },
            icon: const Icon(Icons.point_of_sale_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('فاتورة جديدة'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                query = value;
                setState(_reload);
              },
              decoration: const InputDecoration(
                hintText: 'ابحث برقم الفاتورة أو العميل',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _FilterChip(label: 'الكل', value: 'all', current: status, onTap: _setStatus),
                _FilterChip(label: 'مدفوعة', value: 'paid', current: status, onTap: _setStatus),
                _FilterChip(label: 'غير مدفوعة', value: 'unpaid', current: status, onTap: _setStatus),
                _FilterChip(label: 'معلقة', value: 'draft', current: status, onTap: _setStatus),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<SalesInvoiceRecord>>(
              future: future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rows = snapshot.data!;
                if (rows.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد فواتير مطابقة',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }
                return ListView.separated(
                  key: const Key('sales-invoices-list'),
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 90),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final invoice = rows[index];
                    return _InvoiceCard(
                      invoice: invoice,
                      onTap: () => _openEditor(saleId: invoice.id),
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

  void _setStatus(String value) {
    setState(() {
      status = value;
      _reload();
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(value),
        selectedColor: AppColors.emerald,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.emerald : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.onTap,
  });

  final SalesInvoiceRecord invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = invoice.createdAt.toLocal();
    final dateText = date.year.toString() +
        '/' +
        date.month.toString().padLeft(2, '0') +
        '/' +
        date.day.toString().padLeft(2, '0');

    final label = invoice.status == 'paid'
        ? 'مدفوعة'
        : invoice.status == 'unpaid'
            ? 'غير مدفوعة'
            : 'معلقة';
    final foreground = invoice.status == 'paid'
        ? AppColors.emeraldDark
        : invoice.status == 'unpaid'
            ? Colors.red.shade700
            : const Color(0xFFE67E00);
    final background = invoice.status == 'paid'
        ? const Color(0xFFE3F8F1)
        : invoice.status == 'unpaid'
            ? const Color(0xFFFFE8E8)
            : const Color(0xFFFFF1DD);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const DiftiriIconBox(
                    icon: Icons.receipt_long_rounded,
                    tone: DiftiriTone.navy,
                    size: 52,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber.isEmpty
                              ? 'فاتورة #' +
                                  invoice.id.toString()
                              : invoice.invoiceNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          invoice.customerName.isEmpty
                              ? 'عميل نقدي'
                              : invoice.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  _InvoiceStatusPill(
                    label: label,
                    foreground: foreground,
                    background: background,
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        invoice.total.toStringAsFixed(0) +
                            ' ر.ي',
                        maxLines: 1,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.muted,
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

class _InvoiceStatusPill extends StatelessWidget {
  const _InvoiceStatusPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 110,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
