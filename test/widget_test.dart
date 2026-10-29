import 'package:diftiri/app.dart';
import 'package:diftiri/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppDatabase.instance.initialize();
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
    await tester.pumpAndSettle();
  }

  testWidgets(
    'dashboard renders all accounting sections',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(390, 844),
      );

      expect(find.text('القائمة الرئيسية'), findsOneWidget);
      expect(find.text('المبيعات'), findsOneWidget);
      expect(find.text('المشتريات'), findsOneWidget);
      expect(find.text('المخزون'), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('dashboard-scroll')),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();

      expect(find.text('القيود'), findsOneWidget);
      expect(find.text('التقارير'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dashboard has no overflow on 360x800 phone',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(360, 800),
      );

      expect(find.text('نسخة تجريبية'), findsOneWidget);
      expect(
        find.byKey(const Key('dashboard-search')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byKey(const Key('dashboard-scroll')),
        const Offset(0, -1100),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
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
      await tester.pumpAndSettle();

      expect(find.text('المخزون'), findsOneWidget);
      expect(find.text('المبيعات'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
