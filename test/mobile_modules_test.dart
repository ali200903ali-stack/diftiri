import 'package:diftiri/core/database/app_database.dart';
import 'package:diftiri/core/theme/app_theme.dart';
import 'package:diftiri/features/modules/accounting_screen.dart';
import 'package:diftiri/features/modules/banks_screen.dart';
import 'package:diftiri/features/modules/cash_screen.dart';
import 'package:diftiri/features/modules/expenses_screen.dart';
import 'package:diftiri/features/modules/inventory_screen.dart';
import 'package:diftiri/features/modules/parties_screen.dart';
import 'package:diftiri/features/modules/purchase_screen.dart';
import 'package:diftiri/features/modules/reports_screen.dart';
import 'package:diftiri/features/modules/sales_screen.dart';
import 'package:diftiri/features/modules/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppDatabase.instance.initialize(
      inMemory: true,
    );
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

    for (var i = 0; i < 10; i++) {
      await tester.pump(
        const Duration(milliseconds: 80),
      );
    }

    expect(tester.takeException(), isNull);
  }

  Future<void> disposeScreen(
    WidgetTester tester,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpWidget(
      const SizedBox.shrink(),
    );
    await tester.pump(
      const Duration(milliseconds: 200),
    );
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

      expect(
        find.text('المخزون والمنتجات'),
        findsOneWidget,
      );

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

      expect(
        find.text('حفظ فاتورة الشراء'),
        findsOneWidget,
      );

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

      expect(
        find.text('حفظ الإعدادات'),
        findsOneWidget,
      );

      await disposeScreen(tester);
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

      await disposeScreen(tester);
    },
  );
}
