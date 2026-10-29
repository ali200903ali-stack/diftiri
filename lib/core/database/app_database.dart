import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProductRecord {
  const ProductRecord({
    required this.id,
    required this.name,
    required this.sku,
    required this.salePrice,
    required this.costPrice,
    required this.stock,
    required this.trackStock,
    required this.category,
  });

  final int id;
  final String name;
  final String sku;
  final double salePrice;
  final double costPrice;
  final double stock;
  final bool trackStock;
  final String category;

  factory ProductRecord.fromMap(Map<String, Object?> map) => ProductRecord(
        id: map['id'] as int,
        name: map['name'] as String,
        sku: map['sku'] as String,
        salePrice: (map['sale_price'] as num).toDouble(),
        costPrice: (map['cost_price'] as num).toDouble(),
        stock: (map['stock'] as num).toDouble(),
        trackStock: (map['track_stock'] as int) == 1,
        category: (map['category'] as String?) ?? '',
      );
}

class ExpenseRecord {
  const ExpenseRecord({
    required this.id,
    required this.createdAt,
    required this.category,
    required this.amount,
    required this.note,
  });

  final int id;
  final DateTime createdAt;
  final String category;
  final double amount;
  final String note;

  factory ExpenseRecord.fromMap(Map<String, Object?> map) => ExpenseRecord(
        id: map['id'] as int,
        createdAt: DateTime.parse(map['created_at'] as String),
        category: map['category'] as String,
        amount: (map['amount'] as num).toDouble(),
        note: (map['note'] as String?) ?? '',
      );
}

class PartyRecord {
  const PartyRecord({
    required this.id,
    required this.type,
    required this.name,
    required this.phone,
    required this.balance,
  });

  final int id;
  final String type;
  final String name;
  final String phone;
  final double balance;

  factory PartyRecord.fromMap(Map<String, Object?> map) => PartyRecord(
        id: map['id'] as int,
        type: map['type'] as String,
        name: map['name'] as String,
        phone: (map['phone'] as String?) ?? '',
        balance: (map['balance'] as num).toDouble(),
      );
}

class JournalLineRecord {
  const JournalLineRecord({
    required this.createdAt,
    required this.reference,
    required this.memo,
    required this.accountCode,
    required this.accountName,
    required this.debit,
    required this.credit,
  });

  final DateTime createdAt;
  final String reference;
  final String memo;
  final String accountCode;
  final String accountName;
  final double debit;
  final double credit;

  factory JournalLineRecord.fromMap(Map<String, Object?> map) =>
      JournalLineRecord(
        createdAt: DateTime.parse(map['created_at'] as String),
        reference: (map['reference'] as String?) ?? '',
        memo: (map['memo'] as String?) ?? '',
        accountCode: map['account_code'] as String,
        accountName: map['account_name'] as String,
        debit: (map['debit'] as num).toDouble(),
        credit: (map['credit'] as num).toDouble(),
      );
}

class DashboardStats {
  const DashboardStats({
    required this.salesToday,
    required this.expensesToday,
    required this.cashBalance,
    required this.lowStockCount,
  });

  final double salesToday;
  final double expensesToday;
  final double cashBalance;
  final int lowStockCount;

  double get netToday => salesToday - expensesToday;
}


class BankAccountRecord {
  const BankAccountRecord({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.accountCode,
    required this.balance,
  });

  final int id;
  final String name;
  final String accountNumber;
  final String accountCode;
  final double balance;

  factory BankAccountRecord.fromMap(
    Map<String, Object?> map,
  ) {
    return BankAccountRecord(
      id: map['id'] as int,
      name: map['name'] as String,
      accountNumber:
          (map['account_number'] as String?) ?? '',
      accountCode: map['account_code'] as String,
      balance: (map['balance'] as num).toDouble(),
    );
  }
}

class BusinessSettingsRecord {
  const BusinessSettingsRecord({
    required this.businessName,
    required this.activityType,
    required this.currency,
  });

  final String businessName;
  final String activityType;
  final String currency;
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<void> initialize() async {
    if (_db != null) return;

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    try {
      final dir = await getApplicationSupportDirectory();
      await dir.create(recursive: true);
      dbPath = p.join(dir.path, 'diftiri.db');
    } catch (_) {
      final dir = await Directory.systemTemp.createTemp('diftiri_');
      dbPath = p.join(dir.path, 'diftiri.db');
    }

    _db = await openDatabase(
      dbPath,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createVersion2Tables(db);
          await _seedVersion2(db);
        }
      },
    );
  }

  Database get db {
    final value = _db;
    if (value == null) {
      throw StateError('Database is not initialized');
    }
    return value;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sku TEXT NOT NULL UNIQUE,
        sale_price REAL NOT NULL DEFAULT 0,
        cost_price REAL NOT NULL DEFAULT 0,
        stock REAL NOT NULL DEFAULT 0,
        track_stock INTEGER NOT NULL DEFAULT 1,
        category TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty REAL NOT NULL,
        unit_price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        supplier_name TEXT NOT NULL DEFAULT '',
        total REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty REAL NOT NULL,
        unit_cost REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE parties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL CHECK(type IN ('customer', 'supplier')),
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        balance REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts (
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        reference TEXT NOT NULL DEFAULT '',
        memo TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE journal_lines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL,
        account_code TEXT NOT NULL,
        debit REAL NOT NULL DEFAULT 0,
        credit REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
        FOREIGN KEY (account_code) REFERENCES accounts(code)
      )
    ''');
  }

  Future<void> _createVersion2Tables(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bank_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        account_number TEXT NOT NULL DEFAULT '',
        account_code TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedVersion2(Database db) async {
    await db.insert(
      'app_settings',
      {'key': 'business_name', 'value': 'منشأتي'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.insert(
      'app_settings',
      {'key': 'activity_type', 'value': 'grocery'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.insert(
      'app_settings',
      {'key': 'currency', 'value': 'YER'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> _seed(Database db) async {
    final batch = db.batch();

    const accounts = [
      ['101', 'الصندوق', 'asset'],
      ['120', 'المخزون', 'asset'],
      ['201', 'الموردون', 'liability'],
      ['301', 'رأس المال', 'equity'],
      ['401', 'المبيعات', 'revenue'],
      ['501', 'تكلفة المبيعات', 'expense'],
      ['510', 'المصروفات التشغيلية', 'expense'],
    ];

    for (final account in accounts) {
      batch.insert('accounts', {
        'code': account[0],
        'name': account[1],
        'type': account[2],
      });
    }

    const products = [
      {
        'name': 'مياه معدنية',
        'sku': '10001',
        'sale_price': 250.0,
        'cost_price': 160.0,
        'stock': 46.0,
        'track_stock': 1,
        'category': 'بقالة',
      },
      {
        'name': 'عصير برتقال',
        'sku': '10002',
        'sale_price': 700.0,
        'cost_price': 480.0,
        'stock': 18.0,
        'track_stock': 1,
        'category': 'بقالة',
      },
      {
        'name': 'أرز 5 كجم',
        'sku': '10003',
        'sale_price': 7200.0,
        'cost_price': 6100.0,
        'stock': 9.0,
        'track_stock': 1,
        'category': 'بقالة',
      },
      {
        'name': 'وجبة برجر',
        'sku': '20001',
        'sale_price': 2500.0,
        'cost_price': 1300.0,
        'stock': 0.0,
        'track_stock': 0,
        'category': 'مطعم',
      },
      {
        'name': 'شاورما عربي',
        'sku': '20002',
        'sale_price': 1800.0,
        'cost_price': 950.0,
        'stock': 0.0,
        'track_stock': 0,
        'category': 'مطعم',
      },
    ];

    for (final product in products) {
      batch.insert('products', product);
    }

    await batch.commit(noResult: true);
    await _createVersion2Tables(db);
    await _seedVersion2(db);
  }

  Future<List<ProductRecord>> getProducts({String query = ''}) async {
    final normalized = query.trim();
    final rows = await db.query(
      'products',
      where: normalized.isEmpty ? null : '(name LIKE ? OR sku LIKE ?)',
      whereArgs: normalized.isEmpty
          ? null
          : ['%' + normalized + '%', '%' + normalized + '%'],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(ProductRecord.fromMap).toList();
  }

  Future<int> addProduct({
    required String name,
    required String sku,
    required double salePrice,
    required double costPrice,
    required double stock,
    required bool trackStock,
    String category = '',
  }) {
    return db.insert('products', {
      'name': name.trim(),
      'sku': sku.trim(),
      'sale_price': salePrice,
      'cost_price': costPrice,
      'stock': stock,
      'track_stock': trackStock ? 1 : 0,
      'category': category.trim(),
    });
  }

  Future<void> recordSale(
    Map<int, int> quantities, {
    String paymentMethod = 'cash',
  }) async {
    if (quantities.isEmpty) return;

    await db.transaction((txn) async {
      double total = 0;
      double cogs = 0;
      final products = <int, ProductRecord>{};

      for (final item in quantities.entries) {
        final rows = await txn.query(
          'products',
          where: 'id = ?',
          whereArgs: [item.key],
          limit: 1,
        );
        if (rows.isEmpty) throw StateError('الصنف غير موجود');

        final product = ProductRecord.fromMap(rows.first);
        if (product.trackStock && product.stock < item.value) {
          throw StateError('الكمية غير كافية للصنف: ' + product.name);
        }

        products[item.key] = product;
        total += product.salePrice * item.value;
        if (product.trackStock) {
          cogs += product.costPrice * item.value;
        }
      }

      final now = DateTime.now().toIso8601String();
      final saleId = await txn.insert('sales', {
        'created_at': now,
        'total': total,
        'payment_method': paymentMethod,
      });

      for (final item in quantities.entries) {
        final product = products[item.key]!;
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': product.id,
          'qty': item.value,
          'unit_price': product.salePrice,
          'total': product.salePrice * item.value,
        });

        if (product.trackStock) {
          await txn.rawUpdate(
            'UPDATE products SET stock = stock - ? WHERE id = ?',
            [item.value, product.id],
          );
        }
      }

      final entryId = await _insertJournalEntry(
        txn,
        reference: 'SALE-' + saleId.toString(),
        memo: 'عملية بيع نقدي',
        createdAt: now,
      );

      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '101',
        debit: total,
      );
      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '401',
        credit: total,
      );

      if (cogs > 0) {
        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: '501',
          debit: cogs,
        );
        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: '120',
          credit: cogs,
        );
      }
    });
  }

  Future<void> recordPurchase({
    required int productId,
    required double quantity,
    required double unitCost,
    String supplierName = '',
  }) async {
    if (quantity <= 0 || unitCost < 0) {
      throw ArgumentError('بيانات الشراء غير صحيحة');
    }

    await db.transaction((txn) async {
      final total = quantity * unitCost;
      final now = DateTime.now().toIso8601String();

      final purchaseId = await txn.insert('purchases', {
        'created_at': now,
        'supplier_name': supplierName.trim(),
        'total': total,
      });

      await txn.insert('purchase_items', {
        'purchase_id': purchaseId,
        'product_id': productId,
        'qty': quantity,
        'unit_cost': unitCost,
        'total': total,
      });

      await txn.rawUpdate(
        'UPDATE products SET stock = stock + ?, cost_price = ? WHERE id = ?',
        [quantity, unitCost, productId],
      );

      final entryId = await _insertJournalEntry(
        txn,
        reference: 'PURCHASE-' + purchaseId.toString(),
        memo: 'شراء مخزون نقدي',
        createdAt: now,
      );

      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '120',
        debit: total,
      );
      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '101',
        credit: total,
      );
    });
  }

  Future<int> recordExpense({
    required String category,
    required double amount,
    String note = '',
  }) async {
    if (amount <= 0) throw ArgumentError('المبلغ يجب أن يكون أكبر من صفر');

    return db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final expenseId = await txn.insert('expenses', {
        'created_at': now,
        'category': category.trim(),
        'amount': amount,
        'note': note.trim(),
      });

      final entryId = await _insertJournalEntry(
        txn,
        reference: 'EXPENSE-' + expenseId.toString(),
        memo: category.trim(),
        createdAt: now,
      );

      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '510',
        debit: amount,
      );
      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '101',
        credit: amount,
      );

      return expenseId;
    });
  }

  Future<List<ExpenseRecord>> getExpenses() async {
    final rows = await db.query('expenses', orderBy: 'id DESC');
    return rows.map(ExpenseRecord.fromMap).toList();
  }

  Future<int> addParty({
    required String type,
    required String name,
    String phone = '',
  }) {
    return db.insert('parties', {
      'type': type,
      'name': name.trim(),
      'phone': phone.trim(),
      'balance': 0.0,
    });
  }

  Future<List<PartyRecord>> getParties(String type) async {
    final rows = await db.query(
      'parties',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(PartyRecord.fromMap).toList();
  }

  Future<List<JournalLineRecord>> getJournalLines() async {
    final rows = await db.rawQuery('''
      SELECT
        e.created_at,
        e.reference,
        e.memo,
        l.account_code,
        a.name AS account_name,
        l.debit,
        l.credit
      FROM journal_lines l
      JOIN journal_entries e ON e.id = l.entry_id
      JOIN accounts a ON a.code = l.account_code
      ORDER BY e.id DESC, l.id ASC
      LIMIT 250
    ''');

    return rows.map(JournalLineRecord.fromMap).toList();
  }

  Future<DashboardStats> getDashboardStats() async {
    final now = DateTime.now();
    final dayStart =
        DateTime(now.year, now.month, now.day).toIso8601String();

    final salesRow = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS value FROM sales WHERE created_at >= ?',
      [dayStart],
    );

    final expensesRow = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS value FROM expenses WHERE created_at >= ?',
      [dayStart],
    );

    final cashRow = await db.rawQuery('''
      SELECT COALESCE(SUM(debit - credit), 0) AS value
      FROM journal_lines
      WHERE account_code = '101'
    ''');

    final lowRow = await db.rawQuery('''
      SELECT COUNT(*) AS value
      FROM products
      WHERE track_stock = 1 AND stock <= 10
    ''');

    return DashboardStats(
      salesToday: (salesRow.first['value'] as num).toDouble(),
      expensesToday: (expensesRow.first['value'] as num).toDouble(),
      cashBalance: (cashRow.first['value'] as num).toDouble(),
      lowStockCount: (lowRow.first['value'] as num).toInt(),
    );
  }


  Future<List<JournalLineRecord>>
      getCashJournalLines() async {
    final rows = await getJournalLines();
    return rows
        .where((line) => line.accountCode == '101')
        .toList();
  }

  Future<List<BankAccountRecord>>
      getBankAccounts() async {
    final rows = await db.rawQuery('''
      SELECT
        b.id,
        b.name,
        b.account_number,
        b.account_code,
        COALESCE(SUM(j.debit - j.credit), 0) AS balance
      FROM bank_accounts b
      LEFT JOIN journal_lines j
        ON j.account_code = b.account_code
      GROUP BY
        b.id,
        b.name,
        b.account_number,
        b.account_code
      ORDER BY b.id ASC
    ''');

    return rows.map(BankAccountRecord.fromMap).toList();
  }

  Future<int> addBankAccount({
    required String name,
    String accountNumber = '',
    double openingBalance = 0,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('اسم البنك مطلوب');
    }

    return db.transaction((txn) async {
      final countRows = await txn.rawQuery(
        'SELECT COUNT(*) AS value FROM bank_accounts',
      );
      final nextNumber =
          (countRows.first['value'] as num).toInt() + 1;
      final accountCode =
          '102' + nextNumber.toString();

      await txn.insert('accounts', {
        'code': accountCode,
        'name': 'بنك - ' + name.trim(),
        'type': 'asset',
      });

      final id = await txn.insert('bank_accounts', {
        'name': name.trim(),
        'account_number': accountNumber.trim(),
        'account_code': accountCode,
      });

      if (openingBalance > 0) {
        final now = DateTime.now().toIso8601String();
        final entryId = await _insertJournalEntry(
          txn,
          reference: 'BANK-OPEN-' + id.toString(),
          memo: 'رصيد افتتاحي للبنك',
          createdAt: now,
        );

        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: accountCode,
          debit: openingBalance,
        );
        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: '301',
          credit: openingBalance,
        );
      }

      return id;
    });
  }

  Future<BusinessSettingsRecord>
      getBusinessSettings() async {
    final rows = await db.query('app_settings');
    final values = <String, String>{};

    for (final row in rows) {
      values[row['key'] as String] =
          row['value'] as String;
    }

    return BusinessSettingsRecord(
      businessName:
          values['business_name'] ?? 'منشأتي',
      activityType:
          values['activity_type'] ?? 'grocery',
      currency: values['currency'] ?? 'YER',
    );
  }

  Future<void> saveBusinessSettings({
    required String businessName,
    required String activityType,
    required String currency,
  }) async {
    final values = <String, String>{
      'business_name': businessName.trim().isEmpty
          ? 'منشأتي'
          : businessName.trim(),
      'activity_type': activityType,
      'currency': currency,
    };

    await db.transaction((txn) async {
      for (final entry in values.entries) {
        await txn.insert(
          'app_settings',
          {
            'key': entry.key,
            'value': entry.value,
          },
          conflictAlgorithm:
              ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<int> _insertJournalEntry(
    Transaction txn, {
    required String reference,
    required String memo,
    required String createdAt,
  }) {
    return txn.insert('journal_entries', {
      'created_at': createdAt,
      'reference': reference,
      'memo': memo,
    });
  }

  Future<void> _insertJournalLine(
    Transaction txn, {
    required int entryId,
    required String accountCode,
    double debit = 0,
    double credit = 0,
  }) async {
    await txn.insert('journal_lines', {
      'entry_id': entryId,
      'account_code': accountCode,
      'debit': debit,
      'credit': credit,
    });
  }
}
