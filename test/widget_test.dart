import 'package:diftiri/app.dart';
import 'package:diftiri/core/database/app_database.dart';
import 'package:diftiri/core/ui/diftiri_ui.dart';
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
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(
          const Duration(milliseconds: 60),
        );
      });
      await tester.pump();

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    throw TestFailure(
      'Widget did not appear within timeout: $finder',
    );
  }

  Future<void> disposeApp(
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
    'dashboard renders accounting sections on 390x844',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(390, 844),
      );

      await pumpUntil(
        tester,
        find.text('القائمة الرئيسية'),
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
        find.text('الإعدادات'),
        findsWidgets,
      );
      expect(find.text('المبيعات'), findsNothing);
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

      await pumpUntil(
        tester,
        find.byKey(const Key('dashboard-search')),
      );

      expect(
        find.byKey(const Key('dashboard-search')),
        findsOneWidget,
      );
      expect(find.text('المبيعات'), findsOneWidget);
      expect(find.text('المشتريات'), findsOneWidget);
      expect(find.text('المخزون'), findsOneWidget);
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

      await pumpUntil(
        tester,
        find.byKey(const Key('dashboard-search')),
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
        find.text('المخزون'),
        findsWidgets,
      );
      expect(find.text('المبيعات'), findsNothing);
      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'brand logo is small, crisp widget and anchored to the left',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(390, 844),
      );

      await pumpUntil(
        tester,
        find.byType(DiftiriBrandLogo),
      );

      final logoFinder = find.byType(DiftiriBrandLogo);
      expect(logoFinder, findsOneWidget);

      final logo = tester.widget<DiftiriBrandLogo>(
        logoFinder,
      );
      expect(logo.width, lessThanOrEqualTo(180));
      expect(logo.height, lessThanOrEqualTo(70));
      expect(logo.alignment, Alignment.centerLeft);

      final icons = tester
          .widgetList<DiftiriIconBox>(
            find.byType(DiftiriIconBox),
          )
          .toList();
      final tones = icons.map((icon) => icon.tone).toSet();
      expect(
        tones.length,
        greaterThanOrEqualTo(5),
        reason:
            'الواجهة الرئيسية يجب أن تستخدم مجموعة ألوان متنوعة للأيقونات',
      );
      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'dashboard remains stable on compact 320x568 phone',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(320, 568),
      );

      await pumpUntil(
        tester,
        find.byKey(const Key('dashboard-search')),
      );

      expect(find.text('المبيعات'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byKey(const Key('dashboard-scroll')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'dashboard remains stable in 844x390 landscape',
    (tester) async {
      await pumpAtSize(
        tester,
        const Size(844, 390),
      );

      await pumpUntil(
        tester,
        find.byKey(const Key('dashboard-search')),
      );

      expect(find.text('المبيعات'), findsOneWidget);
      expect(find.text('المشتريات'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    },
  );

}
