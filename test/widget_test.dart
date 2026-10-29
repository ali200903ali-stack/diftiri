import 'package:diftiri/app.dart';
import 'package:diftiri/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppDatabase.instance.initialize(
      inMemory: true,
    );
  });

  Future<void> pumpAtSize(
    WidgetTester tester,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const DiftiriApp());

    for (var i = 0; i < 8; i++) {
      await tester.pump(
        const Duration(milliseconds: 80),
      );
    }
  }

  Future<void> disposeApp(
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
    'dashboard renders accounting sections on 390x844',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(390, 844),
      );

      expect(
        find.text('القائمة الرئيسية'),
        findsOneWidget,
      );
      expect(find.text('المبيعات'), findsOneWidget);
      expect(find.text('المشتريات'), findsOneWidget);
      expect(find.text('المخزون'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('dashboard-search')),
        'الإعدادات',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(
        const Duration(milliseconds: 150),
      );

      expect(
        find.bySemanticsLabel('الإعدادات'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'dashboard has no overflow on 360x800 phone',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(360, 800),
      );

      expect(
        find.text('نسخة تجريبية'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dashboard-search')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byKey(const Key('dashboard-scroll')),
        const Offset(0, -700),
      );
      await tester.pump(
        const Duration(milliseconds: 350),
      );

      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'dashboard search filters modules without layout errors',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(390, 844),
      );

      await tester.enterText(
        find.byKey(const Key('dashboard-search')),
        'المخزون',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(
        const Duration(milliseconds: 150),
      );

      expect(
        find.bySemanticsLabel('المخزون'),
        findsOneWidget,
      );
      expect(find.text('المبيعات'), findsNothing);
      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    },
  );
}
