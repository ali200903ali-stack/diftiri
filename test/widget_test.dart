import 'package:diftiri/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard renders Arabic product identity', (tester) async {
    await tester.pumpWidget(const DiftiriApp());

    expect(find.text('دفتري'), findsOneWidget);
    expect(find.text('المحاسبي'), findsOneWidget);
    expect(find.text('المبيعات'), findsOneWidget);
    expect(find.text('المخزون'), findsOneWidget);
    expect(
      find.text('نسخة تجريبية مفتوحة — الاشتراك غير مفعّل حالياً'),
      findsOneWidget,
    );
  });
}
