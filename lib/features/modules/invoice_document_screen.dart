import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/database/app_database.dart';

class InvoiceDocumentScreen extends StatefulWidget {
  const InvoiceDocumentScreen({
    super.key,
    required this.saleId,
  });

  final int saleId;

  @override
  State<InvoiceDocumentScreen> createState() =>
      _InvoiceDocumentScreenState();
}

class _InvoiceDocumentScreenState
    extends State<InvoiceDocumentScreen> {
  SalesInvoiceRecord? invoice;
  List<SaleItemRecord> items = const [];
  BusinessSettingsRecord? settings;
  String paper = 'a4';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loadedInvoice =
        await AppDatabase.instance.getSalesInvoice(widget.saleId);
    final loadedItems =
        await AppDatabase.instance.getSaleItems(widget.saleId);
    final loadedSettings =
        await AppDatabase.instance.getBusinessSettings();

    if (!mounted) return;
    setState(() {
      invoice = loadedInvoice;
      items = loadedItems;
      settings = loadedSettings;
      paper = loadedSettings.invoicePaper;
      loading = false;
    });
  }

  Future<Uint8List> _buildPdf() async {
    final currentInvoice = invoice;
    final currentSettings = settings;
    if (currentInvoice == null || currentSettings == null) {
      return Uint8List(0);
    }

    final fontData =
        await rootBundle.load('assets/fonts/Cairo.ttf');
    final logoData =
        await rootBundle.load('assets/branding/diftiri_logo.jpg');

    final font = pw.Font.ttf(fontData);
    final logo = pw.MemoryImage(
      logoData.buffer.asUint8List(
        logoData.offsetInBytes,
        logoData.lengthInBytes,
      ),
    );
    final accent = _pdfColor(currentSettings.invoiceColorHex);
    final theme = pw.ThemeData.withFont(
      base: font,
      bold: font,
    );
    final document = pw.Document();

    if (paper == 'thermal') {
      final heightMm =
          (118 + (items.length * 14)).clamp(150, 520).toDouble();
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            80 * PdfPageFormat.mm,
            heightMm * PdfPageFormat.mm,
            marginLeft: 4 * PdfPageFormat.mm,
            marginTop: 4 * PdfPageFormat.mm,
            marginRight: 4 * PdfPageFormat.mm,
            marginBottom: 4 * PdfPageFormat.mm,
          ),
          theme: theme,
          build: (context) => pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: _thermalReceipt(
              invoice: currentInvoice,
              settings: currentSettings,
              items: items,
              logo: logo,
              accent: accent,
            ),
          ),
        ),
      );
    } else {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: theme,
          header: (context) => pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: _a4Header(
              invoice: currentInvoice,
              settings: currentSettings,
              logo: logo,
              accent: accent,
            ),
          ),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'دفتري المحاسبي • صفحة ' +
                  context.pageNumber.toString() +
                  ' من ' +
                  context.pagesCount.toString(),
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            ),
          ),
          build: (context) => [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: _a4Body(
                invoice: currentInvoice,
                items: items,
                accent: accent,
              ),
            ),
          ],
        ),
      );
    }

    return document.save();
  }

  PdfColor _pdfColor(String hex) {
    final normalized = hex.replaceAll('#', '');
    final value = int.tryParse(normalized, radix: 16) ?? 0x0DB28E;
    final r = ((value >> 16) & 0xFF) / 255;
    final g = ((value >> 8) & 0xFF) / 255;
    final b = (value & 0xFF) / 255;
    return PdfColor(r, g, b);
  }

  String _dateText(DateTime date) {
    final local = date.toLocal();
    return local.year.toString() +
        '/' +
        local.month.toString().padLeft(2, '0') +
        '/' +
        local.day.toString().padLeft(2, '0');
  }

  pw.Widget _a4Header({
    required SalesInvoiceRecord invoice,
    required BusinessSettingsRecord settings,
    required pw.MemoryImage logo,
    required PdfColor accent,
  }) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    height: 64,
                    alignment: pw.Alignment.centerRight,
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    settings.businessName,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: 190,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: accent, width: .8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'فاتورة مبيعات',
                    style: pw.TextStyle(
                      color: accent,
                      fontSize: 19,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    invoice.invoiceNumber.isEmpty
                        ? '#' + invoice.id.toString()
                        : invoice.invoiceNumber,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'التاريخ: ' + _dateText(invoice.createdAt),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: accent, thickness: 1.3),
        pw.SizedBox(height: 12),
      ],
    );
  }

  pw.Widget _a4Body({
    required SalesInvoiceRecord invoice,
    required List<SaleItemRecord> items,
    required PdfColor accent,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: _pdfMeta(
                  'العميل',
                  invoice.customerName.isEmpty
                      ? 'عميل نقدي'
                      : invoice.customerName,
                ),
              ),
              pw.Expanded(
                child: _pdfMeta(
                  'طريقة الدفع',
                  invoice.paymentMethod == 'bank'
                      ? 'تحويل بنكي'
                      : 'نقدي',
                ),
              ),
              pw.Expanded(
                child: _pdfMeta(
                  'الحالة',
                  invoice.status == 'paid'
                      ? 'مدفوعة'
                      : invoice.status == 'unpaid'
                          ? 'غير مدفوعة'
                          : 'مسودة',
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 18),
        _invoiceTable(items, accent),
        pw.SizedBox(height: 18),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Container(
            width: 260,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              children: [
                _pdfTotalRow('الإجمالي الفرعي', invoice.subtotal),
                _pdfTotalRow('الخصم', -invoice.discount),
                _pdfTotalRow('الضريبة', invoice.taxAmount),
                pw.Divider(color: accent),
                _pdfTotalRow(
                  'الإجمالي',
                  invoice.total,
                  strong: true,
                  color: accent,
                ),
              ],
            ),
          ),
        ),
        if (invoice.notes.trim().isNotEmpty) ...[
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text('ملاحظات: ' + invoice.notes),
          ),
        ],
      ],
    );
  }

  pw.Widget _thermalReceipt({
    required SalesInvoiceRecord invoice,
    required BusinessSettingsRecord settings,
    required List<SaleItemRecord> items,
    required pw.MemoryImage logo,
    required PdfColor accent,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(
          child: pw.SizedBox(
            height: 38,
            width: 120,
            child: pw.Image(logo, fit: pw.BoxFit.contain),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          settings.businessName,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          invoice.invoiceNumber.isEmpty
              ? 'فاتورة #' + invoice.id.toString()
              : invoice.invoiceNumber,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 10,
            color: accent,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          _dateText(invoice.createdAt),
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.Divider(color: PdfColors.grey500),
        ...items.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    item.productName,
                    style: const pw.TextStyle(fontSize: 8.5),
                  ),
                ),
                pw.Text(
                  _num(item.quantity) +
                      ' × ' +
                      _money(item.unitPrice),
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  _money(item.total),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.Divider(color: PdfColors.grey500),
        _pdfTotalRow(
          'الإجمالي',
          invoice.total,
          strong: true,
          color: accent,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          invoice.customerName.isEmpty
              ? 'العميل: نقدي'
              : 'العميل: ' + invoice.customerName,
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'شكرًا لتعاملكم معنا',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _invoiceTable(
    List<SaleItemRecord> items,
    PdfColor accent,
  ) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: accent),
        children: [
          _tableCell('الصنف', header: true),
          _tableCell('الكمية', header: true),
          _tableCell('السعر', header: true),
          _tableCell('الإجمالي', header: true),
        ],
      ),
      ...items.map(
        (item) => pw.TableRow(
          children: [
            _tableCell(item.productName),
            _tableCell(_num(item.quantity)),
            _tableCell(_money(item.unitPrice)),
            _tableCell(_money(item.total)),
          ],
        ),
      ),
    ];

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: .6,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.5),
      },
      children: rows,
    );
  }

  pw.Widget _tableCell(String text, {bool header = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: header ? PdfColors.white : PdfColors.black,
          fontSize: header ? 9 : 8.5,
          fontWeight:
              header ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _pdfMeta(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            color: PdfColors.grey600,
            fontSize: 8,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfTotalRow(
    String label,
    double value, {
    bool strong = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: strong ? 11 : 9,
                color: color,
                fontWeight: strong
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Text(
            _money(value),
            style: pw.TextStyle(
              fontSize: strong ? 12 : 9,
              color: color,
              fontWeight: strong
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _num(double value) {
    return value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  String _money(double value) => value.toStringAsFixed(2);

  Future<void> _sharePdf() async {
    final bytes = await _buildPdf();
    final number = invoice?.invoiceNumber.isNotEmpty == true
        ? invoice!.invoiceNumber
        : widget.saleId.toString();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'diftiri-' + number + '.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الفاتورة')),
        body: const Center(child: Text('الفاتورة غير موجودة')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض وطباعة الفاتورة'),
        actions: [
          IconButton(
            tooltip: 'تصدير PDF',
            onPressed: _sharePdf,
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            color: Colors.white,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'a4',
                  icon: Icon(Icons.description_rounded),
                  label: Text('A4'),
                ),
                ButtonSegment(
                  value: 'thermal',
                  icon: Icon(Icons.receipt_rounded),
                  label: Text('حرارية'),
                ),
              ],
              selected: {paper},
              onSelectionChanged: (value) {
                setState(() => paper = value.first);
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PdfPreview(
              key: ValueKey(paper),
              build: (_) => _buildPdf(),
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName:
                  'diftiri-invoice-' + widget.saleId.toString() + '.pdf',
              loadingWidget: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
