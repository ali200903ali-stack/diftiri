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
}
