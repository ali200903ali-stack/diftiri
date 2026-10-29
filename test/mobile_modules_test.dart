import 'package:diftiri/core/database/app_database.dart';
import 'package:diftiri/core/theme/app_theme.dart';
import 'package:diftiri/features/modules/accounting_screen.dart';
import 'package:diftiri/features/modules/expenses_screen.dart';
import 'package:diftiri/features/modules/inventory_screen.dart';
import 'package:diftiri/features/modules/parties_screen.dart';
import 'package:diftiri/features/modules/purchase_screen.dart';
import 'package:diftiri/features/modules/reports_screen.dart';
import 'package:diftiri/features/modules/sales_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppDatabase.instance.initialize();
  });

  Future<void> pumpPhone(
    WidgetTester tester,
    Widget screen,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: screen,
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets(
    'sales screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const SalesScreen(),
      );

      expect(
        find.byKey(const Key('sales-search')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('sales-products-grid')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'inventory screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const InventoryScreen(),
      );

      expect(
        find.text('المخزون والمنتجات'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'purchase screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const PurchaseScreen(),
      );

      expect(
        find.text('حفظ فاتورة الشراء'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'expenses screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const ExpensesScreen(),
      );

      expect(
        find.text('إضافة المصروف'),
        findsOneWidget,
      );
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

      expect(
        find.text('العملاء'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'accounting screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const AccountingScreen(),
      );

      expect(
        find.text('الحسابات والقيود'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'reports screen is stable on phone',
    (tester) async {
      await pumpPhone(
        tester,
        const ReportsScreen(),
      );

      expect(
        find.text('التقارير'),
        findsOneWidget,
      );
    },
  );
}
