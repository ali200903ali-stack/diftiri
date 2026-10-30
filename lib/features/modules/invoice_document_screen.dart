import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/database/app_database.dart';
import '../../core/ui/diftiri_ui.dart';

class InvoiceDocumentScreen extends StatefulWidget {
  const InvoiceDocumentScreen({
    super.key,
    this.saleId,
    this.purchaseId,
  }) : assert(
          (saleId != null) != (purchaseId != null),
          'حدد فاتورة مبيعات أو مشتريات واحدة',
        );

  final int? saleId;
  final int? purchaseId;

  @override
  State<InvoiceDocumentScreen> createState() =>
      _InvoiceDocumentScreenState();
}

class _InvoiceDocumentScreenState
    extends State<InvoiceDocumentScreen> {
  _InvoiceDocData? invoice;
  BusinessSettingsRecord? settings;
  String paper = 'a4';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loadedSettings =
        await AppDatabase.instance.getBusinessSettings();
    _InvoiceDocData? loadedInvoice;

    if (widget.saleId != null) {
      final record = await AppDatabase.instance
          .getSalesInvoice(widget.saleId!);
      final items = await AppDatabase.instance
          .getSaleItems(widget.saleId!);

      if (record != null) {
        loadedInvoice = _InvoiceDocData(
          id: record.id,
          kind: 'sale',
          title: 'فاتورة مبيعات',
          invoiceNumber: record.invoiceNumber,
          createdAt: record.createdAt,
          partyLabel: 'العميل',
          partyName: record.customerName,
          status: record.status,
          paymentMethod: record.paymentMethod,
          subtotal: record.subtotal,
          taxAmount: record.taxAmount,
          discount: record.discount,
          total: record.total,
          notes: record.notes,
          lines: items
              .map(
                (item) => _InvoiceDocLine(
                  name: item.productName,
                  quantity: item.quantity,
                  unitPrice: item.unitPrice,
                  total: item.total,
                ),
              )
              .toList(),
        );
      }
    } else {
      final record = await AppDatabase.instance
          .getPurchaseInvoice(widget.purchaseId!);
      final items = await AppDatabase.instance
          .getPurchaseItems(widget.purchaseId!);

      if (record != null) {
        loadedInvoice = _InvoiceDocData(
          id: record.id,
          kind: 'purchase',
          title: 'فاتورة مشتريات',
          invoiceNumber: record.invoiceNumber,
          createdAt: record.createdAt,
          partyLabel: 'المورد',
          partyName: record.supplierName,
          status: record.status,
          paymentMethod: record.paymentMethod,
          subtotal: record.subtotal,
          taxAmount: record.taxAmount,
          discount: record.discount,
          total: record.total,
          notes: record.notes,
          lines: items
              .map(
                (item) => _InvoiceDocLine(
                  name: item.productName,
                  quantity: item.quantity,
                  unitPrice: item.unitCost,
                  total: item.total,
                ),
              )
              .toList(),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      invoice = loadedInvoice;
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
    final logoSvg = await rootBundle.loadString(
      'assets/branding/diftiri_logo_vector.svg',
    );

    final font = pw.Font.ttf(fontData);
    final accent = _pdfColor(currentSettings.invoiceColorHex);
    final theme = pw.ThemeData.withFont(
      base: font,
      bold: font,
    );
    final document = pw.Document();

    if (paper == 'thermal') {
      final heightMm = (118 + (currentInvoice.lines.length * 14))
          .clamp(150, 520)
          .toDouble();
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
              logoSvg: logoSvg,
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
              logoSvg: logoSvg,
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

  String _statusText(String value) {
    if (value == 'paid') return 'مدفوعة';
    if (value == 'unpaid') return 'آجلة';
    return 'مسودة';
  }

  String _paymentText(String value) {
    return value == 'bank' ? 'تحويل بنكي' : 'نقدي';
  }

  pw.Widget _a4Header({
    required _InvoiceDocData invoice,
    required BusinessSettingsRecord settings,
    required String logoSvg,
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
                    child: pw.SvgImage(svg: logoSvg, fit: pw.BoxFit.contain),
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
                    invoice.title,
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
    required _InvoiceDocData invoice,
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
                  invoice.partyLabel,
                  invoice.partyName.isEmpty
                      ? 'غير محدد'
                      : invoice.partyName,
                ),
              ),
              pw.Expanded(
                child: _pdfMeta(
                  'طريقة الدفع',
                  _paymentText(invoice.paymentMethod),
                ),
              ),
              pw.Expanded(
                child: _pdfMeta(
                  'الحالة',
                  _statusText(invoice.status),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 18),
        _invoiceTable(invoice.lines, accent),
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
    required _InvoiceDocData invoice,
    required BusinessSettingsRecord settings,
    required String logoSvg,
    required PdfColor accent,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(
          child: pw.SizedBox(
            height: 38,
            width: 120,
            child: pw.SvgImage(svg: logoSvg, fit: pw.BoxFit.contain),
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
          invoice.title +
              ' ' +
              (invoice.invoiceNumber.isEmpty
                  ? '#' + invoice.id.toString()
                  : invoice.invoiceNumber),
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
        ...invoice.lines.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    item.name,
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
          invoice.partyLabel +
              ': ' +
              (invoice.partyName.isEmpty
                  ? 'غير محدد'
                  : invoice.partyName),
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          invoice.kind == 'sale'
              ? 'شكرًا لتعاملكم معنا'
              : 'مستند مشتريات محفوظ في دفتري المحاسبي',
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
    List<_InvoiceDocLine> items,
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
            _tableCell(item.name),
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
    final current = invoice;
    if (current == null) return;
    final bytes = await _buildPdf();
    final number = current.invoiceNumber.isNotEmpty
        ? current.invoiceNumber
        : current.id.toString();
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

    final current = invoice;
    if (current == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الفاتورة')),
        body: const Center(child: Text('الفاتورة غير موجودة')),
      );
    }

    return Scaffold(
      appBar: DiftiriAppBar(
        title: 'عرض وطباعة ' + current.title,
        subtitle: 'PDF، مشاركة، A4 أو طباعة حرارية',
        icon: Icons.picture_as_pdf_rounded,
        tone: current.kind == 'sale'
            ? DiftiriTone.navy
            : DiftiriTone.emerald,
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
                  'diftiri-' + current.kind + '-' + current.id.toString() + '.pdf',
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

class _InvoiceDocData {
  const _InvoiceDocData({
    required this.id,
    required this.kind,
    required this.title,
    required this.invoiceNumber,
    required this.createdAt,
    required this.partyLabel,
    required this.partyName,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.taxAmount,
    required this.discount,
    required this.total,
    required this.notes,
    required this.lines,
  });

  final int id;
  final String kind;
  final String title;
  final String invoiceNumber;
  final DateTime createdAt;
  final String partyLabel;
  final String partyName;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double taxAmount;
  final double discount;
  final double total;
  final String notes;
  final List<_InvoiceDocLine> lines;
}

class _InvoiceDocLine {
  const _InvoiceDocLine({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  final String name;
  final double quantity;
  final double unitPrice;
  final double total;
}
