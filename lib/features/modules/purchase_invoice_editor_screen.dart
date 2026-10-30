import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import 'invoice_document_screen.dart';

class PurchaseInvoiceEditorScreen extends StatefulWidget {
  const PurchaseInvoiceEditorScreen({
    super.key,
    this.purchaseId,
  });

  final int? purchaseId;

  @override
  State<PurchaseInvoiceEditorScreen> createState() =>
      _PurchaseInvoiceEditorScreenState();
}

class _PurchaseInvoiceEditorScreenState
    extends State<PurchaseInvoiceEditorScreen> {
  final notes = TextEditingController();
  final discount = TextEditingController(text: '0');
  final taxRate = TextEditingController(text: '0');

  List<ProductRecord> products = [];
  List<PartyRecord> suppliers = [];
  final List<_PurchaseLine> lines = [];

  int? supplierId;
  DateTime issueDate = DateTime.now();
  DateTime? dueDate;
  String paymentMethod = 'cash';
  String postingStatus = 'paid';
  String invoiceNumber = 'جديدة';
  bool loading = true;
  bool posted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    notes.dispose();
    discount.dispose();
    taxRate.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    products = await AppDatabase.instance.getProducts();
    suppliers =
        await AppDatabase.instance.getParties('supplier');

    if (widget.purchaseId != null) {
      final invoice = await AppDatabase.instance
          .getPurchaseInvoice(widget.purchaseId!);
      final items = await AppDatabase.instance
          .getPurchaseItems(widget.purchaseId!);

      if (invoice != null) {
        invoiceNumber = invoice.invoiceNumber;
        supplierId = invoice.supplierId;
        issueDate = invoice.createdAt;
        dueDate = invoice.dueDate;
        paymentMethod = invoice.paymentMethod;
        postingStatus =
            invoice.status == 'draft' ? 'paid' : invoice.status;
        notes.text = invoice.notes;
        discount.text = invoice.discount.toStringAsFixed(0);
        taxRate.text = invoice.taxRate.toStringAsFixed(0);
        posted = invoice.posted;

        lines.addAll(
          items.map(
            (item) => _PurchaseLine(
              productId: item.productId,
              quantity: item.quantity,
              unitCost: item.unitCost,
            ),
          ),
        );
      }
    }

    if (lines.isEmpty && products.isNotEmpty) {
      lines.add(
        _PurchaseLine(
          productId: products.first.id,
          quantity: 1,
          unitCost: products.first.costPrice,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  double get subtotal => lines.fold<double>(
        0,
        (sum, line) => sum + line.quantity * line.unitCost,
      );

  double get discountValue =>
      double.tryParse(discount.text) ?? 0;

  double get taxRateValue =>
      double.tryParse(taxRate.text) ?? 0;

  double get taxable => (subtotal - discountValue)
      .clamp(0.0, subtotal)
      .toDouble();

  double get taxAmount =>
      taxable * taxRateValue / 100;

  double get total => taxable + taxAmount;

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return date.year.toString() +
        '/' +
        date.month.toString().padLeft(2, '0') +
        '/' +
        date.day.toString().padLeft(2, '0');
  }

  Future<DateTime?> _pickDate(
    DateTime initial,
  ) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }

  void _addLine() {
    if (products.isEmpty) return;
    setState(() {
      lines.add(
        _PurchaseLine(
          productId: products.first.id,
          quantity: 1,
          unitCost: products.first.costPrice,
        ),
      );
    });
  }

  Future<void> _openDocument() async {
    if (widget.purchaseId == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => InvoiceDocumentScreen(
          purchaseId: widget.purchaseId!,
        ),
      ),
    );
  }

  Future<void> _save({
    required bool draft,
  }) async {
    try {
      final id = await AppDatabase.instance
          .savePurchaseInvoice(
        purchaseId: widget.purchaseId,
        lines: lines
            .map(
              (line) => PurchaseLineInput(
                productId: line.productId,
                quantity: line.quantity,
                unitCost: line.unitCost,
              ),
            )
            .toList(),
        supplierId: supplierId,
        createdAt: issueDate,
        dueDate: dueDate,
        paymentMethod: paymentMethod,
        status:
            draft ? 'draft' : postingStatus,
        notes: notes.text,
        taxRate: taxRateValue,
        discount: discountValue,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            draft
                ? 'تم حفظ مسودة المشتريات'
                : 'تم حفظ وترحيل فاتورة الشراء رقم ' +
                    id.toString(),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          posted
              ? 'تفاصيل فاتورة الشراء'
              : 'تحرير فاتورة الشراء',
        ),
        actions: [
          if (posted)
            IconButton(
              tooltip: 'PDF والطباعة',
              onPressed: _openDocument,
              icon: const Icon(Icons.picture_as_pdf_rounded),
            ),
        ],
      ),
      body: ListView(
        key: const Key(
          'purchase-invoice-editor-scroll',
        ),
        padding:
            const EdgeInsets.fromLTRB(
          14,
          10,
          14,
          110,
        ),
        children: [
          _PurchaseSectionCard(
            title: 'معلومات الفاتورة',
            icon: Icons.description_rounded,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText:
                              'رقم الفاتورة',
                        ),
                        child: Text(
                          invoiceNumber,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child:
                          DropdownButtonFormField<
                              int?>(
                        isExpanded: true,
                        initialValue: supplierId,
                        decoration:
                            const InputDecoration(
                          labelText: 'المورد',
                        ),
                        items: [
                          const DropdownMenuItem<
                              int?>(
                            value: null,
                            child:
                                Text('بدون مورد'),
                          ),
                          ...suppliers.map(
                            (supplier) =>
                                DropdownMenuItem<
                                    int?>(
                              value:
                                  supplier.id,
                              child: Text(
                                supplier.name,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: posted
                            ? null
                            : (value) {
                                setState(() {
                                  supplierId =
                                      value;
                                });
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PurchaseDateField(
                        label:
                            'تاريخ الفاتورة',
                        value: _formatDate(
                          issueDate,
                        ),
                        onTap: posted
                            ? null
                            : () async {
                                final picked =
                                    await _pickDate(
                                  issueDate,
                                );
                                if (picked !=
                                        null &&
                                    mounted) {
                                  setState(() {
                                    issueDate =
                                        picked;
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PurchaseDateField(
                        label:
                            'تاريخ الاستحقاق',
                        value:
                            _formatDate(dueDate),
                        onTap: posted
                            ? null
                            : () async {
                                final picked =
                                    await _pickDate(
                                  dueDate ??
                                      issueDate,
                                );
                                if (picked !=
                                        null &&
                                    mounted) {
                                  setState(() {
                                    dueDate =
                                        picked;
                                  });
                                }
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child:
                          DropdownButtonFormField<
                              String>(
                        isExpanded: true,
                        initialValue:
                            paymentMethod,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'طريقة الدفع',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'cash',
                            child: Text('نقدي'),
                          ),
                          DropdownMenuItem(
                            value: 'bank',
                            child: Text(
                              'تحويل بنكي',
                            ),
                          ),
                        ],
                        onChanged: posted
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }
                                setState(() {
                                  paymentMethod =
                                      value;
                                });
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child:
                          DropdownButtonFormField<
                              String>(
                        isExpanded: true,
                        initialValue:
                            postingStatus,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'حالة الدفع',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'paid',
                            child:
                                Text('مدفوعة'),
                          ),
                          DropdownMenuItem(
                            value: 'unpaid',
                            child: Text('آجلة'),
                          ),
                        ],
                        onChanged: posted
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }
                                setState(() {
                                  postingStatus =
                                      value;
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PurchaseSectionCard(
            title: 'أصناف المشتريات',
            icon: Icons.inventory_2_rounded,
            child: Column(
              children: [
                for (var i = 0;
                    i < lines.length;
                    i++) ...[
                  _PurchaseLineEditor(
                    line: lines[i],
                    products: products,
                    readOnly: posted,
                    onChanged: () =>
                        setState(() {}),
                    onDelete: posted ||
                            lines.length == 1
                        ? null
                        : () {
                            setState(() {
                              lines.removeAt(i);
                            });
                          },
                  ),
                  if (i !=
                      lines.length - 1)
                    const Divider(
                      height: 18,
                    ),
                ],
                if (!posted) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        OutlinedButton.icon(
                      onPressed: _addLine,
                      icon: const Icon(
                        Icons
                            .add_circle_rounded,
                      ),
                      label: const Text(
                        'إضافة صنف',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PurchaseSectionCard(
            title: 'ملخص الفاتورة',
            icon: Icons.calculate_rounded,
            child: Column(
              children: [
                if (!posted)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              discount,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) =>
                              setState(() {}),
                          decoration:
                              const InputDecoration(
                            labelText:
                                'الخصم',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextField(
                          controller:
                              taxRate,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) =>
                              setState(() {}),
                          decoration:
                              const InputDecoration(
                            labelText:
                                'الضريبة %',
                          ),
                        ),
                      ),
                    ],
                  ),
                if (!posted)
                  const SizedBox(
                    height: 14,
                  ),
                _PurchaseTotalRow(
                  label:
                      'الإجمالي الفرعي',
                  value: subtotal,
                ),
                _PurchaseTotalRow(
                  label: 'الخصم',
                  value: -discountValue,
                ),
                _PurchaseTotalRow(
                  label: 'الضريبة',
                  value: taxAmount,
                ),
                const Divider(),
                _PurchaseTotalRow(
                  label: 'الإجمالي',
                  value: total,
                  emphasized: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PurchaseSectionCard(
            title: 'ملاحظات',
            icon: Icons.notes_rounded,
            child: TextField(
              controller: notes,
              enabled: !posted,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                hintText:
                    'ملاحظات فاتورة الشراء',
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: posted
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: _openDocument,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      'عرض PDF / طباعة',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            )
          : SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  14,
                  9,
                  14,
                  10,
                ),
                decoration:
                    const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed: () =>
                            _save(
                          draft: true,
                        ),
                        child: const Padding(
                          padding: EdgeInsets
                              .symmetric(
                            vertical: 13,
                          ),
                          child: Text(
                            'حفظ مسودة',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child:
                          FilledButton.icon(
                        onPressed: () =>
                            _save(
                          draft: false,
                        ),
                        icon: const Icon(
                          Icons.save_rounded,
                        ),
                        label: const Padding(
                          padding: EdgeInsets
                              .symmetric(
                            vertical: 13,
                          ),
                          child: Text(
                            'حفظ وترحيل',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w900,
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
  }
}

class _PurchaseLine {
  _PurchaseLine({
    required this.productId,
    required this.quantity,
    required this.unitCost,
  });

  int productId;
  double quantity;
  double unitCost;
}

class _PurchaseLineEditor
    extends StatelessWidget {
  const _PurchaseLineEditor({
    required this.line,
    required this.products,
    required this.readOnly,
    required this.onChanged,
    this.onDelete,
  });

  final _PurchaseLine line;
  final List<ProductRecord> products;
  final bool readOnly;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: line.productId,
          decoration:
              const InputDecoration(
            labelText: 'الصنف',
          ),
          items: products
              .map(
                (product) =>
                    DropdownMenuItem<int>(
                  value: product.id,
                  child: Text(
                    product.name,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: readOnly
              ? null
              : (value) {
                  if (value == null) return;
                  final product =
                      products.firstWhere(
                    (item) =>
                        item.id == value,
                  );
                  line.productId = value;
                  line.unitCost =
                      product.costPrice;
                  onChanged();
                },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue:
                    line.quantity
                        .toStringAsFixed(
                  line.quantity % 1 == 0
                      ? 0
                      : 2,
                ),
                enabled: !readOnly,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'الكمية',
                ),
                onChanged: (value) {
                  line.quantity =
                      double.tryParse(
                            value,
                          ) ??
                          0;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue:
                    line.unitCost
                        .toStringAsFixed(
                  line.unitCost % 1 == 0
                      ? 0
                      : 2,
                ),
                enabled: !readOnly,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText:
                      'تكلفة الوحدة',
                ),
                onChanged: (value) {
                  line.unitCost =
                      double.tryParse(
                            value,
                          ) ??
                          0;
                  onChanged();
                },
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons
                      .delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'المجموع: ' +
                (line.quantity *
                        line.unitCost)
                    .toStringAsFixed(0) +
                ' ر.ي',
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _PurchaseSectionCard
    extends StatelessWidget {
  const _PurchaseSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                    AppColors.emeraldDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PurchaseDateField
    extends StatelessWidget {
  const _PurchaseDateField({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
          ),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _PurchaseTotalRow
    extends StatelessWidget {
  const _PurchaseTotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: emphasized
                    ? FontWeight.w900
                    : FontWeight.w600,
                fontSize:
                    emphasized ? 17 : 14,
              ),
            ),
          ),
          Text(
            value.toStringAsFixed(1) +
                ' ر.ي',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight:
                  FontWeight.w900,
              fontSize:
                  emphasized ? 20 : 15,
            ),
          ),
        ],
      ),
    );
  }
}
