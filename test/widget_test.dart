import 'package:diftiri/app.dart';
import 'package:diftiri/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppDatabase.instance.initialize();
  });

  testWidgets(
    'dashboard renders Arabic product identity',
    (tester) async {
      await tester.pumpWidget(const DiftiriApp());
      await tester.pumpAndSettle();

      expect(find.text('القائمة الرئيسية'), findsOneWidget);
      expect(find.text('المبيعات'), findsOneWidget);
      expect(find.text('المخزون'), findsOneWidget);
      expect(
        find.text(
          'نسخة تجريبية مفتوحة — الاشتراك غير مفعّل حالياً',
        ),
        findsOneWidget,
      );
    },
  );
}
