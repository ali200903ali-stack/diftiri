import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<DatabaseFactory> diftiriDatabaseFactory() async {
  return databaseFactoryFfiWeb;
}

Future<String> diftiriDatabasePath({
  required bool inMemory,
}) async {
  return inMemory ? ':memory:' : 'diftiri.db';
}
