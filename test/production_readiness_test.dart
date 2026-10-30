import 'package:diftiri/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppDatabase.instance
        .initialize(inMemory: true)
        .timeout(const Duration(seconds: 10));
  });

  test('all business and UI settings persist exactly', () async {
    await AppDatabase.instance.saveBusinessSettings(
      businessName: 'مؤسسة اختبار الجاهزية',
      activityType: 'mixed',
      currency: 'SAR',
      uiScale: 1.08,
      fontScale: 1.16,
      invoiceColorHex: '7C3AED',
      invoicePaper: 'thermal',
      saleScannerEnabled: true,
      scannerSoundEnabled: false,
    );

    final settings =
        await AppDatabase.instance.getBusinessSettings();

    expect(settings.businessName, 'مؤسسة اختبار الجاهزية');
    expect(settings.activityType, 'mixed');
    expect(settings.currency, 'SAR');
    expect(settings.uiScale, closeTo(1.08, .001));
    expect(settings.fontScale, closeTo(1.16, .001));
    expect(settings.invoiceColorHex, '7C3AED');
    expect(settings.invoicePaper, 'thermal');
    expect(settings.saleScannerEnabled, isTrue);
    expect(settings.scannerSoundEnabled, isFalse);
  });

  test(
    'POS sale updates stock and posts a balanced accounting entry',
    () async {
      final productId = await AppDatabase.instance.addProduct(
        name: 'صنف اختبار كاشير',
        sku: 'READY-POS-001',
        salePrice: 100,
        costPrice: 60,
        stock: 20,
        trackStock: true,
        category: 'اختبارات',
      );

      await AppDatabase.instance.recordSale(
        {productId: 3},
        paymentMethod: 'cash',
      );

      final products = await AppDatabase.instance.getProducts();
      final product =
          products.firstWhere((row) => row.id == productId);
      expect(product.stock, 17);

      final history =
          await AppDatabase.instance.getSalesHistory();
      final sale = history.first;
      final items =
          await AppDatabase.instance.getSaleItems(sale.id);
      final line =
          items.firstWhere((row) => row.productId == productId);

      expect(line.quantity, 3);
      expect(line.total, 300);

      final journals =
          await AppDatabase.instance.getJournalLines();
      final saleLines = journals
          .where((row) => row.reference == 'SALE-${sale.id}')
          .toList();

      expect(saleLines, isNotEmpty);
      final debit = saleLines.fold<double>(
        0,
        (sum, row) => sum + row.debit,
      );
      final credit = saleLines.fold<double>(
        0,
        (sum, row) => sum + row.credit,
      );

      expect(debit, closeTo(credit, .001));
      expect(
        saleLines.any(
          (row) =>
              row.accountCode == '101' &&
              row.debit == 300,
        ),
        isTrue,
      );
      expect(
        saleLines.any(
          (row) =>
              row.accountCode == '401' &&
              row.credit == 300,
        ),
        isTrue,
      );
      expect(
        saleLines.any(
          (row) =>
              row.accountCode == '501' &&
              row.debit == 180,
        ),
        isTrue,
      );
      expect(
        saleLines.any(
          (row) =>
              row.accountCode == '120' &&
              row.credit == 180,
        ),
        isTrue,
      );
    },
  );

  test(
    'posted sales invoice can be safely edited and reposted once',
    () async {
      final productId = await AppDatabase.instance.addProduct(
        name: 'صنف اختبار تعديل فاتورة',
        sku: 'READY-EDIT-001',
        salePrice: 200,
        costPrice: 80,
        stock: 50,
        trackStock: true,
      );

      final invoiceId =
          await AppDatabase.instance.saveSalesInvoice(
        lines: [
          InvoiceLineInput(
            productId: productId,
            quantity: 2,
            unitPrice: 200,
          ),
        ],
        createdAt: DateTime.now(),
        paymentMethod: 'cash',
        status: 'paid',
      );

      var products = await AppDatabase.instance.getProducts();
      var product =
          products.firstWhere((row) => row.id == productId);
      expect(product.stock, 48);

      await AppDatabase.instance.saveSalesInvoice(
        saleId: invoiceId,
        lines: [
          InvoiceLineInput(
            productId: productId,
            quantity: 5,
            unitPrice: 210,
          ),
        ],
        createdAt: DateTime.now(),
        paymentMethod: 'cash',
        status: 'paid',
      );

      products = await AppDatabase.instance.getProducts();
      product =
          products.firstWhere((row) => row.id == productId);
      expect(
        product.stock,
        45,
        reason:
            'التعديل يجب أن يعيد كمية الفاتورة القديمة ثم يخصم الجديدة',
      );

      final invoice =
          await AppDatabase.instance.getSalesInvoice(invoiceId);
      expect(invoice, isNotNull);
      expect(invoice!.total, 1050);

      final journals =
          await AppDatabase.instance.getJournalLines();
      final invoiceLines = journals
          .where(
            (row) => row.reference == 'INV-$invoiceId',
          )
          .toList();

      expect(
        invoiceLines.length,
        4,
        reason:
            'يجب حذف قيد الفاتورة السابق قبل إعادة الترحيل',
      );
      final debit = invoiceLines.fold<double>(
        0,
        (sum, row) => sum + row.debit,
      );
      final credit = invoiceLines.fold<double>(
        0,
        (sum, row) => sum + row.credit,
      );
      expect(debit, closeTo(credit, .001));
    },
  );

  test(
    'sales return restores stock, blocks over-return and locks later edit',
    () async {
      final productId = await AppDatabase.instance.addProduct(
        name: 'صنف اختبار مرتجع',
        sku: 'READY-RETURN-001',
        salePrice: 150,
        costPrice: 90,
        stock: 12,
        trackStock: true,
      );

      final invoiceId =
          await AppDatabase.instance.saveSalesInvoice(
        lines: [
          InvoiceLineInput(
            productId: productId,
            quantity: 4,
            unitPrice: 150,
          ),
        ],
        createdAt: DateTime.now(),
        paymentMethod: 'cash',
        status: 'paid',
      );

      var products = await AppDatabase.instance.getProducts();
      expect(
        products.firstWhere((row) => row.id == productId).stock,
        8,
      );

      final items =
          await AppDatabase.instance.getSaleItems(invoiceId);
      final item = items.single;

      await AppDatabase.instance.recordSaleReturn(
        saleId: invoiceId,
        quantitiesBySaleItem: {item.id: 1},
      );

      products = await AppDatabase.instance.getProducts();
      expect(
        products.firstWhere((row) => row.id == productId).stock,
        9,
      );

      await expectLater(
        AppDatabase.instance.recordSaleReturn(
          saleId: invoiceId,
          quantitiesBySaleItem: {item.id: 4},
        ),
        throwsStateError,
      );

      await expectLater(
        AppDatabase.instance.saveSalesInvoice(
          saleId: invoiceId,
          lines: [
            InvoiceLineInput(
              productId: productId,
              quantity: 2,
              unitPrice: 150,
            ),
          ],
          createdAt: DateTime.now(),
          paymentMethod: 'cash',
          status: 'paid',
        ),
        throwsStateError,
      );
    },
  );

  test(
    'unpaid customer invoice creates receivable and payment clears it',
    () async {
      final customerId = await AppDatabase.instance.addParty(
        type: 'customer',
        name: 'عميل اختبار الجاهزية',
        phone: '777000001',
      );
      final serviceId = await AppDatabase.instance.addProduct(
        name: 'خدمة اختبار',
        sku: 'READY-SERVICE-001',
        salePrice: 500,
        costPrice: 0,
        stock: 0,
        trackStock: false,
      );

      await AppDatabase.instance.saveSalesInvoice(
        lines: [
          InvoiceLineInput(
            productId: serviceId,
            quantity: 2,
            unitPrice: 500,
          ),
        ],
        customerId: customerId,
        createdAt: DateTime.now(),
        paymentMethod: 'cash',
        status: 'unpaid',
      );

      var customers =
          await AppDatabase.instance.getParties('customer');
      var customer =
          customers.firstWhere((row) => row.id == customerId);
      expect(customer.balance, 1000);

      await AppDatabase.instance.recordPartyPayment(
        partyId: customerId,
        type: 'customer',
        amount: 1000,
      );

      customers =
          await AppDatabase.instance.getParties('customer');
      customer =
          customers.firstWhere((row) => row.id == customerId);
      expect(customer.balance, 0);
    },
  );

  test(
    'unpaid purchase updates stock and supplier payable then payment clears it',
    () async {
      final supplierId = await AppDatabase.instance.addParty(
        type: 'supplier',
        name: 'مورد اختبار الجاهزية',
        phone: '777000002',
      );
      final productId = await AppDatabase.instance.addProduct(
        name: 'صنف اختبار شراء',
        sku: 'READY-PURCHASE-001',
        salePrice: 120,
        costPrice: 50,
        stock: 0,
        trackStock: true,
      );

      final purchaseId =
          await AppDatabase.instance.savePurchaseInvoice(
        lines: [
          PurchaseLineInput(
            productId: productId,
            quantity: 4,
            unitCost: 75,
          ),
        ],
        supplierId: supplierId,
        createdAt: DateTime.now(),
        paymentMethod: 'cash',
        status: 'unpaid',
      );

      final products = await AppDatabase.instance.getProducts();
      final product =
          products.firstWhere((row) => row.id == productId);
      expect(product.stock, 4);
      expect(product.costPrice, 75);

      var suppliers =
          await AppDatabase.instance.getParties('supplier');
      var supplier =
          suppliers.firstWhere((row) => row.id == supplierId);
      expect(supplier.balance, 300);

      await expectLater(
        AppDatabase.instance.savePurchaseInvoice(
          purchaseId: purchaseId,
          lines: [
            PurchaseLineInput(
              productId: productId,
              quantity: 5,
              unitCost: 75,
            ),
          ],
          supplierId: supplierId,
          createdAt: DateTime.now(),
          paymentMethod: 'cash',
          status: 'paid',
        ),
        throwsStateError,
      );

      await AppDatabase.instance.recordPartyPayment(
        partyId: supplierId,
        type: 'supplier',
        amount: 300,
      );

      suppliers =
          await AppDatabase.instance.getParties('supplier');
      supplier =
          suppliers.firstWhere((row) => row.id == supplierId);
      expect(supplier.balance, 0);
    },
  );

  test('manual journals reject imbalance and preserve double entry', () async {
    final accounts = await AppDatabase.instance.getAccounts();
    expect(accounts.length, greaterThanOrEqualTo(2));

    await expectLater(
      AppDatabase.instance.recordManualJournal(
        date: DateTime.now(),
        memo: 'اختبار قيد مرفوض',
        lines: [
          JournalInputLine(
            accountCode: accounts[0].code,
            debit: 250,
            credit: 0,
          ),
          JournalInputLine(
            accountCode: accounts[1].code,
            debit: 0,
            credit: 200,
          ),
        ],
      ),
      throwsArgumentError,
    );

    final id = await AppDatabase.instance.recordManualJournal(
      date: DateTime.now(),
      memo: 'اختبار قيد متوازن',
      lines: [
        JournalInputLine(
          accountCode: accounts[0].code,
          debit: 250,
          credit: 0,
        ),
        JournalInputLine(
          accountCode: accounts[1].code,
          debit: 0,
          credit: 250,
        ),
      ],
    );
    expect(id, greaterThan(0));

    final journals =
        await AppDatabase.instance.getJournalLines();
    final lines = journals
        .where((row) => row.memo == 'اختبار قيد متوازن')
        .toList();
    final debit =
        lines.fold<double>(0, (sum, row) => sum + row.debit);
    final credit =
        lines.fold<double>(0, (sum, row) => sum + row.credit);
    expect(debit, closeTo(credit, .001));
  });

  test(
    'reports, accounts and dashboard remain numerically valid after full flow',
    () async {
      final now = DateTime.now();
      final summary = await AppDatabase.instance.getReportSummary(
        from: now.subtract(const Duration(days: 1)),
        to: now.add(const Duration(days: 1)),
      );
      final trend =
          await AppDatabase.instance.getMonthlySalesTrend();
      final accounts =
          await AppDatabase.instance.getAccounts();
      final dashboard =
          await AppDatabase.instance.getDashboardStats();

      expect(summary.sales.isFinite, isTrue);
      expect(summary.netSales.isFinite, isTrue);
      expect(summary.netProfit.isFinite, isTrue);
      expect(summary.inventoryValue, greaterThanOrEqualTo(0));
      expect(trend.length, 6);
      expect(trend.every((point) => point.value.isFinite), isTrue);
      expect(accounts, isNotEmpty);
      expect(
        accounts.every((account) => account.balance.isFinite),
        isTrue,
      );
      expect(dashboard.salesToday.isFinite, isTrue);
      expect(dashboard.cashBalance.isFinite, isTrue);
      expect(dashboard.lowStockCount, greaterThanOrEqualTo(0));
    },
  );
}
