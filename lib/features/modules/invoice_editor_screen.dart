import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';
import 'invoice_document_screen.dart';
import 'sales_return_screen.dart';

class InvoiceEditorScreen extends StatefulWidget {
  const InvoiceEditorScreen({super.key, this.saleId});

  final int? saleId;

  @override
  State<InvoiceEditorScreen> createState() => _InvoiceEditorScreenState();
}

class _InvoiceEditorScreenState extends State<InvoiceEditorScreen> {
  final notes = TextEditingController();
  final discount = TextEditingController(text: '0');
  final taxRate = TextEditingController(text: '0');

  List<ProductRecord> products = [];
  List<PartyRecord> customers = [];
  final List<_InvoiceLine> lines = [];

  int? customerId;
  DateTime issueDate = DateTime.now();
  DateTime? dueDate;
  String paymentMethod = 'cash';
  String postingStatus = 'paid';
  String invoiceNumber = 'جديدة';
  bool loading = true;
  bool posted = false;
  bool editMode = false;

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
    customers = await AppDatabase.instance.getParties('customer');

    if (widget.saleId != null) {
      final invoice =
          await AppDatabase.instance.getSalesInvoice(widget.saleId!);
      final items =
          await AppDatabase.instance.getSaleItems(widget.saleId!);

      if (invoice != null) {
        invoiceNumber = invoice.invoiceNumber;
        customerId = invoice.customerId;
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
            (item) => _InvoiceLine(
              productId: item.productId,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          ),
        );
      }
    }

    if (lines.isEmpty && products.isNotEmpty) {
      lines.add(
        _InvoiceLine(
          productId: products.first.id,
          quantity: 1,
          unitPrice: products.first.salePrice,
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
        (sum, line) => sum + line.quantity * line.unitPrice,
      );

  double get discountValue => double.tryParse(discount.text) ?? 0;
  double get taxRateValue => double.tryParse(taxRate.text) ?? 0;

  double get taxable => (subtotal - discountValue)
      .clamp(0.0, subtotal)
      .toDouble();

  double get taxAmount => taxable * taxRateValue / 100;
  double get total => taxable + taxAmount;
  bool get readOnly => posted && !editMode;

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return date.year.toString() +
        '/' +
        date.month.toString().padLeft(2, '0') +
        '/' +
        date.day.toString().padLeft(2, '0');
  }

  Future<DateTime?> _pickDate(DateTime initial) {
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
        _InvoiceLine(
          productId: products.first.id,
          quantity: 1,
          unitPrice: products.first.salePrice,
        ),
      );
    });
  }

  Future<void> _save({required bool draft}) async {
    try {
      final id = await AppDatabase.instance.saveSalesInvoice(
        saleId: widget.saleId,
        lines: lines
            .map(
              (line) => InvoiceLineInput(
                productId: line.productId,
                quantity: line.quantity,
                unitPrice: line.unitPrice,
              ),
            )
            .toList(),
        customerId: customerId,
        createdAt: issueDate,
        dueDate: dueDate,
        paymentMethod: paymentMethod,
        status: draft ? 'draft' : postingStatus,
        notes: notes.text,
        taxRate: taxRateValue,
        discount: discountValue,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            draft
                ? 'تم حفظ المسودة'
                : 'تم حفظ وترحيل الفاتورة رقم ' + id.toString(),
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _openDocument() async {
    if (widget.saleId == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => InvoiceDocumentScreen(
          saleId: widget.saleId!,
        ),
      ),
    );
  }

  Future<void> _openReturn() async {
    if (widget.saleId == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SalesReturnScreen(saleId: widget.saleId!),
      ),
    );
    if (changed == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: DiftiriAppBar(
        title: readOnly
            ? 'تفاصيل الفاتورة'
            : posted
                ? 'تعديل الفاتورة'
                : 'تحرير الفاتورة',
        subtitle: 'بنود، خصم، ضريبة، ترحيل وطباعة',
        icon: Icons.receipt_long_rounded,
        tone: DiftiriTone.navy,
        actions: [
          if (posted)
            IconButton(
              tooltip: 'PDF والطباعة',
              onPressed: _openDocument,
              icon: const Icon(Icons.picture_as_pdf_rounded),
            ),
          if (posted && readOnly)
            IconButton(
              tooltip: 'تعديل الفاتورة',
              onPressed: () {
                setState(() => editMode = true);
              },
              icon: const Icon(Icons.edit_rounded),
            ),
          if (posted)
            IconButton(
              tooltip: 'مرتجع',
              onPressed: _openReturn,
              icon: const Icon(Icons.assignment_return_rounded),
            ),
        ],
      ),
      body: ListView(
        key: const Key('invoice-editor-scroll'),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 110),
        children: [
          _SectionCard(
            title: 'معلومات الفاتورة',
            icon: Icons.description_rounded,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ReadOnlyField(
                        label: 'رقم الفاتورة',
                        value: invoiceNumber,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        isExpanded: true,
                        initialValue: customerId,
                        decoration: const InputDecoration(
                          labelText: 'العميل',
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('عميل نقدي'),
                          ),
                          ...customers.map(
                            (customer) => DropdownMenuItem<int?>(
                              value: customer.id,
                              child: Text(
                                customer.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: readOnly
                            ? null
                            : (value) {
                                setState(() {
                                  customerId = value;
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
                      child: _DateField(
                        label: 'تاريخ الإصدار',
                        value: _formatDate(issueDate),
                        onTap: readOnly
                            ? null
                            : () async {
                                final picked =
                                    await _pickDate(issueDate);
                                if (picked != null && mounted) {
                                  setState(() {
                                    issueDate = picked;
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateField(
                        label: 'تاريخ الاستحقاق',
                        value: _formatDate(dueDate),
                        onTap: readOnly
                            ? null
                            : () async {
                                final picked =
                                    await _pickDate(dueDate ?? issueDate);
                                if (picked != null && mounted) {
                                  setState(() {
                                    dueDate = picked;
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
                      child: DropdownButtonFormField<String>(
                isExpanded: true,
                        initialValue: paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'طريقة الدفع',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'cash',
                            child: Text('نقدي'),
                          ),
                          DropdownMenuItem(
                            value: 'bank',
                            child: Text('تحويل بنكي'),
                          ),
                        ],
                        onChanged: readOnly
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() {
                                  paymentMethod = value;
                                });
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                isExpanded: true,
                        initialValue: postingStatus,
                        decoration: const InputDecoration(
                          labelText: 'حالة الدفع',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'paid',
                            child: Text('مدفوعة'),
                          ),
                          DropdownMenuItem(
                            value: 'unpaid',
                            child: Text('غير مدفوعة'),
                          ),
                        ],
                        onChanged: readOnly
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() {
                                  postingStatus = value;
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
          _SectionCard(
            title: 'أصناف الفاتورة',
            icon: Icons.inventory_2_rounded,
            child: Column(
              children: [
                for (var i = 0; i < lines.length; i++) ...[
                  _InvoiceLineEditor(
                    line: lines[i],
                    products: products,
                    readOnly: readOnly,
                    onChanged: () => setState(() {}),
                    onDelete: readOnly || lines.length == 1
                        ? null
                        : () {
                            setState(() {
                              lines.removeAt(i);
                            });
                          },
                  ),
                  if (i != lines.length - 1)
                    const Divider(height: 18),
                ],
                if (!readOnly) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addLine,
                      icon: const Icon(Icons.add_circle_rounded),
                      label: const Text('إضافة صنف'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'ملخص الفاتورة',
            icon: Icons.calculate_rounded,
            child: Column(
              children: [
                if (!readOnly)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: discount,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'الخصم',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: taxRate,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'الضريبة %',
                          ),
                        ),
                      ),
                    ],
                  ),
                if (!readOnly) const SizedBox(height: 14),
                _TotalRow(label: 'الإجمالي الفرعي', value: subtotal),
                _TotalRow(label: 'الخصم', value: -discountValue),
                _TotalRow(label: 'الضريبة', value: taxAmount),
                const Divider(),
                _TotalRow(
                  label: 'الإجمالي',
                  value: total,
                  emphasized: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'ملاحظات',
            icon: Icons.notes_rounded,
            child: TextField(
              controller: notes,
              enabled: !readOnly,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'أدخل أي ملاحظات على الفاتورة',
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: readOnly
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openDocument,
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          child: Text('PDF / طباعة'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openReturn,
                        icon: const Icon(Icons.assignment_return_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          child: Text('مرتجع'),
                        ),
                      ),
                    ),
                  ],
                )
              : posted
                  ? FilledButton.icon(
                      onPressed: () => _save(draft: false),
                      icon: const Icon(Icons.save_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'حفظ التعديلات وإعادة الترحيل',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _save(draft: true),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 13),
                              child: Text('حفظ مسودة'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: () => _save(draft: false),
                            icon: const Icon(Icons.save_rounded),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 13),
                              child: Text(
                                'حفظ وترحيل',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
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

class _InvoiceLine {
  _InvoiceLine({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  int productId;
  double quantity;
  double unitPrice;
}

class _InvoiceLineEditor extends StatelessWidget {
  const _InvoiceLineEditor({
    required this.line,
    required this.products,
    required this.readOnly,
    required this.onChanged,
    this.onDelete,
  });

  final _InvoiceLine line;
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
          decoration: const InputDecoration(labelText: 'الصنف'),
          items: products
              .map(
                (product) => DropdownMenuItem<int>(
                  value: product.id,
                  child: Text(
                    product.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: readOnly
              ? null
              : (value) {
                  if (value == null) return;
                  final product =
                      products.firstWhere((item) => item.id == value);
                  line.productId = value;
                  line.unitPrice = product.salePrice;
                  onChanged();
                },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: line.quantity.toStringAsFixed(
                  line.quantity % 1 == 0 ? 0 : 2,
                ),
                enabled: !readOnly,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'الكمية'),
                onChanged: (value) {
                  line.quantity = double.tryParse(value) ?? 0;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: line.unitPrice.toStringAsFixed(
                  line.unitPrice % 1 == 0 ? 0 : 2,
                ),
                enabled: !readOnly,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'سعر الوحدة'),
                onChanged: (value) {
                  line.unitPrice = double.tryParse(value) ?? 0;
                  onChanged();
                },
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'حذف السطر',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
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
                (line.quantity * line.unitPrice).toStringAsFixed(0) +
                ' ر.ي',
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.emeraldDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
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

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
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
      borderRadius: BorderRadius.circular(18),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    emphasized ? FontWeight.w900 : FontWeight.w600,
                fontSize: emphasized ? 17 : 14,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toStringAsFixed(1) + ' ر.ي',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w900,
                fontSize: emphasized ? 20 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
