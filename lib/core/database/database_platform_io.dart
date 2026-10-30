import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<DatabaseFactory> diftiriDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    return databaseFactoryFfi;
  }
  return sqflite.databaseFactory;
}

Future<String> diftiriDatabasePath({
  required bool inMemory,
}) async {
  if (inMemory) return ':memory:';

  try {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    return p.join(dir.path, 'diftiri.db');
  } catch (_) {
    final dir = await Directory.systemTemp.createTemp('diftiri_');
    return p.join(dir.path, 'diftiri.db');
  }
}
