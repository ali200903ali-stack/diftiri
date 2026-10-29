import 'package:diftiri/core/database/app_database.dart';
import 'package:diftiri/core/theme/app_theme.dart';
import 'package:diftiri/features/modules/accounting_screen.dart';
import 'package:diftiri/features/modules/banks_screen.dart';
import 'package:diftiri/features/modules/cash_screen.dart';
import 'package:diftiri/features/modules/expenses_screen.dart';
import 'package:diftiri/features/modules/inventory_screen.dart';
import 'package:diftiri/features/modules/invoice_editor_screen.dart';
import 'package:diftiri/features/modules/manual_journal_screen.dart';
import 'package:diftiri/features/modules/parties_screen.dart';
import 'package:diftiri/features/modules/purchase_screen.dart';
import 'package:diftiri/features/modules/purchase_invoices_screen.dart';
import 'package:diftiri/features/modules/purchase_invoice_editor_screen.dart';
import 'package:diftiri/features/modules/reports_screen.dart';
import 'package:diftiri/features/modules/restaurant_tables_screen.dart';
import 'package:diftiri/features/modules/sales_screen.dart';
import 'package:diftiri/features/modules/sales_invoices_screen.dart';
import 'package:diftiri/features/modules/sales_return_screen.dart';
import 'package:diftiri/features/modules/sales_history_screen.dart';
import 'package:diftiri/features/modules/purchase_history_screen.dart';
import 'package:diftiri/features/modules/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int returnSaleId;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppDatabase.instance.initialize(
      inMemory: true,
    );

    final products =
        await AppDatabase.instance.getProducts();
    if (products.isEmpty) {
      throw StateError(
        'لا توجد أصناف لتجهيز فاتورة اختبار المرتجع',
      );
    }

    await AppDatabase.instance.recordSale(
      {products.first.id: 1},
    );

    final sales =
        await AppDatabase.instance.getSalesHistory();
    if (sales.isEmpty) {
      throw StateError(
        'تعذر تجهيز فاتورة اختبار المرتجع',
      );
    }

    returnSaleId = sales.first.id;
  });

  Future<void> pumpPhone(
    WidgetTester tester,
    Widget screen,
  ) async {
    tester.view.physicalSize =
        const Size(360, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) =>
            Directionality(
          textDirection: TextDirection.rtl,
          child:
              child ?? const SizedBox.shrink(),
        ),
        home: screen,
      ),
    );

    await tester.runAsync(() async {
      await Future<void>.delayed(
        const Duration(milliseconds: 180),
      );
    });
    await tester.pump();
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder,
  ) async {
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(
          const Duration(milliseconds: 60),
        );
      });
      await tester.pump();

      if (finder.evaluate().isNotEmpty) {
        expect(tester.takeException(), isNull);
        return;
      }
    }

    throw TestFailure(
      'Widget did not appear within timeout: $finder',
    );
  }

  Future<void> disposeScreen(
    WidgetTester tester,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(
        const Duration(milliseconds: 80),
      );
    });
    await tester.pumpWidget(
      const SizedBox.shrink(),
    );
    await tester.pump();
  }

  testWidgets(
    'sales screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const SalesScreen(),
      );

      await pumpUntil(
        tester,
        find.byKey(const Key('sales-search')),
      );

      expect(
        find.byKey(
          const Key('sales-products-grid'),
        ),
        findsOneWidget,
      );

      await disposeScreen(tester);
    },
  );

  testWidgets(
    'inventory screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const InventoryScreen(),
      );

      await pumpUntil(
        tester,
        find.byKey(const Key('inventory-list')),
      );

      expect(
        find.text('المخزون'),
        findsOneWidget,
      );

      await disposeScreen(tester);
    },
  );


  testWidgets(
    'purchase invoices center is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const PurchaseInvoicesScreen(),
      );

      await pumpUntil(
        tester,
        find.text('فواتير المشتريات'),
      );

      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'purchase invoice editor is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const PurchaseInvoiceEditorScreen(),
      );

      await pumpUntil(
        tester,
        find.byKey(
          const Key(
            'purchase-invoice-editor-scroll',
          ),
        ),
      );

      expect(
        find.text('حفظ وترحيل'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'purchase screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const PurchaseScreen(),
      );

      await pumpUntil(
        tester,
        find.text('حفظ فاتورة الشراء'),
      );

      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'expenses screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const ExpensesScreen(),
      );

      await pumpUntil(
        tester,
        find.text('لا توجد مصروفات'),
      );

      expect(
        find.text('إضافة المصروف'),
        findsOneWidget,
      );

      await disposeScreen(tester);
    },
  );

  testWidgets(
    'customers screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const PartiesScreen(
          type: 'customer',
          title: 'العملاء',
        ),
      );

      await pumpUntil(
        tester,
        find.text('لا يوجد العملاء مطابقون'),
      );

      expect(
        find.text('العملاء'),
        findsOneWidget,
      );

      await disposeScreen(tester);
    },
  );

  testWidgets(
    'accounting screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const AccountingScreen(),
      );

      await pumpUntil(
        tester,
        find.byKey(
          const Key('journal-lines-list'),
        ),
      );

      expect(
        find.text('الحسابات والقيود'),
        findsOneWidget,
      );

      await disposeScreen(tester);
    },
  );

  testWidgets(
    'cash screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const CashScreen(),
      );

      await pumpUntil(
        tester,
        find.text('الرصيد النقدي'),
      );

      expect(
        find.text('الصندوق'),
        findsOneWidget,
      );

      await disposeScreen(tester);
    },
  );

  testWidgets(
    'banks screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const BanksScreen(),
      );

      await pumpUntil(
        tester,
        find.textContaining(
          'لا توجد حسابات بنكية',
        ),
      );

      expect(
        find.text('البنوك'),
        findsOneWidget,
      );

      await disposeScreen(tester);
    },
  );

  testWidgets(
    'settings screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const SettingsScreen(),
      );

      await pumpUntil(
        tester,
        find.text('حفظ الإعدادات'),
      );

      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );



  testWidgets(
    'sales invoices center is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const SalesInvoicesScreen(),
      );

      await pumpUntil(
        tester,
        find.text('فواتير المبيعات'),
      );

      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'new invoice editor is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const InvoiceEditorScreen(),
      );

      await pumpUntil(
        tester,
        find.byKey(
          const Key('invoice-editor-scroll'),
        ),
      );

      expect(
        find.text('حفظ وترحيل'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'manual journal editor is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const ManualJournalScreen(),
      );

      await pumpUntil(
        tester,
        find.byKey(
          const Key('manual-journal-scroll'),
        ),
      );

      expect(
        find.text('حفظ القيد'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'sales return screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        SalesReturnScreen(
          saleId: returnSaleId,
        ),
      );

      await pumpUntil(
        tester,
        find.byKey(
          const Key('sales-return-list'),
        ),
      );

      expect(
        find.text('حفظ المرتجع'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'sales history is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const SalesHistoryScreen(),
      );

      await pumpUntil(
        tester,
        find.text('سجل المبيعات'),
      );

      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'purchase history is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const PurchaseHistoryScreen(),
      );

      await pumpUntil(
        tester,
        find.text('سجل المشتريات'),
      );

      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );


  testWidgets(
    'restaurant tables screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const RestaurantTablesScreen(),
      );

      await pumpUntil(
        tester,
        find.byKey(
          const Key('restaurant-tables-grid'),
        ),
      );

      expect(tester.takeException(), isNull);
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'restaurant sale controls fit 360x800 phone',
    (tester) async {
      await pumpPhone(
        tester,
        const SalesScreen(
          activityTypeOverride: 'restaurant',
        ),
      );

      await pumpUntil(
        tester,
        find.byKey(
          const Key('restaurant-order-controls'),
        ),
      );

      expect(find.text('سفري'), findsOneWidget);
      expect(find.text('محلي'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reports screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const ReportsScreen(),
      );

      await pumpUntil(
        tester,
        find.text('إجمالي المبيعات'),
      );

      expect(
        find.text('التقارير'),
        findsOneWidget,
      );

      await disposeScreen(tester);
    },
  );
}
