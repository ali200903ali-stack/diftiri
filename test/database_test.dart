import 'package:diftiri/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppDatabase.instance.initialize(
      inMemory: true,
    ).timeout(const Duration(seconds: 5));
  });

  test(
    'business activity setting switches to restaurant',
    () async {
      await AppDatabase.instance
          .saveBusinessSettings(
        businessName: 'منشأتي',
        activityType: 'restaurant',
        currency: 'YER',
      )
          .timeout(const Duration(seconds: 5));

      final settings = await AppDatabase.instance
          .getBusinessSettings()
          .timeout(const Duration(seconds: 5));

      expect(settings.activityType, 'restaurant');

      await AppDatabase.instance
          .saveBusinessSettings(
        businessName: 'منشأتي',
        activityType: 'grocery',
        currency: 'YER',
      )
          .timeout(const Duration(seconds: 5));
    },
  );

  test(
    'restaurant tables load without database lock',
    () async {
      final tables = await AppDatabase.instance
          .getRestaurantTables()
          .timeout(const Duration(seconds: 5));

      expect(tables, isNotEmpty);
    },
  );

  test(
    'invoice draft can be edited then posted',
    () async {
      final products =
          await AppDatabase.instance.getProducts();
      expect(products, isNotEmpty);

      final product = products.first;

      final draftId = await AppDatabase.instance
          .saveSalesInvoice(
        lines: [
          InvoiceLineInput(
            productId: product.id,
            quantity: 1,
            unitPrice: product.salePrice,
          ),
        ],
        createdAt: DateTime.now(),
        paymentMethod: 'cash',
        status: 'draft',
      );

      var invoice = await AppDatabase.instance
          .getSalesInvoice(draftId);
      expect(invoice, isNotNull);
      expect(invoice!.posted, isFalse);

      await AppDatabase.instance.saveSalesInvoice(
        saleId: draftId,
        lines: [
          InvoiceLineInput(
            productId: product.id,
            quantity: 1,
            unitPrice: product.salePrice,
          ),
        ],
        createdAt: DateTime.now(),
        paymentMethod: 'cash',
        status: 'paid',
      );

      invoice = await AppDatabase.instance
          .getSalesInvoice(draftId);
      expect(invoice, isNotNull);
      expect(invoice!.posted, isTrue);
      expect(invoice.status, 'paid');
    },
  );

  test(
    'posted invoice supports partial return',
    () async {
      final invoices =
          await AppDatabase.instance.getSalesInvoices(
        status: 'paid',
      );
      expect(invoices, isNotEmpty);

      final invoice = invoices.first;
      final items = await AppDatabase.instance
          .getSaleItems(invoice.id);
      expect(items, isNotEmpty);

      final item = items.first;
      final quantity = item.returnableQuantity >= 1
          ? 1.0
          : item.returnableQuantity;

      if (quantity > 0) {
        await AppDatabase.instance.recordSaleReturn(
          saleId: invoice.id,
          quantitiesBySaleItem: {
            item.id: quantity,
          },
        );

        final refreshed = await AppDatabase.instance
            .getSaleItems(invoice.id);
        final refreshedItem = refreshed.firstWhere(
          (row) => row.id == item.id,
        );

        expect(
          refreshedItem.returnedQuantity,
          greaterThan(0),
        );
      }
    },
  );

  test(
    'manual journal requires balance and saves balanced lines',
    () async {
      final accounts =
          await AppDatabase.instance.getAccounts();
      expect(accounts.length, greaterThanOrEqualTo(2));

      expect(
        () => AppDatabase.instance.recordManualJournal(
          date: DateTime.now(),
          memo: 'قيد غير متوازن',
          lines: [
            JournalInputLine(
              accountCode: accounts[0].code,
              debit: 100,
              credit: 0,
            ),
            JournalInputLine(
              accountCode: accounts[1].code,
              debit: 0,
              credit: 50,
            ),
          ],
        ),
        throwsArgumentError,
      );

      final id = await AppDatabase.instance
          .recordManualJournal(
        date: DateTime.now(),
        memo: 'قيد اختبار',
        lines: [
          JournalInputLine(
            accountCode: accounts[0].code,
            debit: 100,
            credit: 0,
          ),
          JournalInputLine(
            accountCode: accounts[1].code,
            debit: 0,
            credit: 100,
          ),
        ],
      );

      expect(id, greaterThan(0));
    },
  );

  test(
    'report summary and trend use stored accounting data',
    () async {
      final summary = await AppDatabase.instance
          .getReportSummary();
      final trend = await AppDatabase.instance
          .getMonthlySalesTrend();

      expect(summary.sales, greaterThanOrEqualTo(0));
      expect(trend.length, 6);
    },
  );

}
