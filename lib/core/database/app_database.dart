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




class RestaurantTableRecord {
  const RestaurantTableRecord({
    required this.id,
    required this.name,
    required this.active,
  });

  final int id;
  final String name;
  final bool active;

  factory RestaurantTableRecord.fromMap(
    Map<String, Object?> map,
  ) {
    return RestaurantTableRecord(
      id: map['id'] as int,
      name: map['name'] as String,
      active: (map['active'] as int) == 1,
    );
  }
}

class SaleSummaryRecord {
  const SaleSummaryRecord({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.paymentMethod,
    required this.itemCount,
    required this.orderType,
    required this.tableName,
  });

  final int id;
  final DateTime createdAt;
  final double total;
  final String paymentMethod;
  final double itemCount;
  final String orderType;
  final String tableName;

  factory SaleSummaryRecord.fromMap(
    Map<String, Object?> map,
  ) {
    return SaleSummaryRecord(
      id: map['id'] as int,
      createdAt:
          DateTime.parse(map['created_at'] as String),
      total: (map['total'] as num).toDouble(),
      paymentMethod:
          (map['payment_method'] as String?) ?? 'cash',
      itemCount:
          (map['item_count'] as num).toDouble(),
      orderType:
          (map['order_type'] as String?) ?? 'retail',
      tableName:
          (map['table_name'] as String?) ?? '',
    );
  }
}

class PurchaseSummaryRecord {
  const PurchaseSummaryRecord({
    required this.id,
    required this.createdAt,
    required this.supplierName,
    required this.total,
    required this.itemCount,
  });

  final int id;
  final DateTime createdAt;
  final String supplierName;
  final double total;
  final double itemCount;

  factory PurchaseSummaryRecord.fromMap(
    Map<String, Object?> map,
  ) {
    return PurchaseSummaryRecord(
      id: map['id'] as int,
      createdAt:
          DateTime.parse(map['created_at'] as String),
      supplierName:
          (map['supplier_name'] as String?) ?? '',
      total: (map['total'] as num).toDouble(),
      itemCount:
          (map['item_count'] as num).toDouble(),
    );
  }
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




class PurchaseLineInput {
  const PurchaseLineInput({
    required this.productId,
    required this.quantity,
    required this.unitCost,
  });

  final int productId;
  final double quantity;
  final double unitCost;
}

class PurchaseInvoiceRecord {
  const PurchaseInvoiceRecord({
    required this.id,
    required this.invoiceNumber,
    required this.createdAt,
    required this.dueDate,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.discount,
    required this.total,
    required this.notes,
    required this.posted,
    required this.itemCount,
  });

  final int id;
  final String invoiceNumber;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int? supplierId;
  final String supplierName;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discount;
  final double total;
  final String notes;
  final bool posted;
  final double itemCount;

  factory PurchaseInvoiceRecord.fromMap(
    Map<String, Object?> map,
  ) {
    final rawDueDate = map['due_date'] as String?;
    return PurchaseInvoiceRecord(
      id: map['id'] as int,
      invoiceNumber:
          (map['invoice_number'] as String?) ?? '',
      createdAt:
          DateTime.parse(map['created_at'] as String),
      dueDate: rawDueDate == null || rawDueDate.isEmpty
          ? null
          : DateTime.parse(rawDueDate),
      supplierId: map['supplier_id'] as int?,
      supplierName:
          (map['supplier_name'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'paid',
      paymentMethod:
          (map['payment_method'] as String?) ?? 'cash',
      subtotal:
          (map['subtotal'] as num?)?.toDouble() ??
              (map['total'] as num).toDouble(),
      taxRate:
          (map['tax_rate'] as num?)?.toDouble() ?? 0,
      taxAmount:
          (map['tax_amount'] as num?)?.toDouble() ?? 0,
      discount:
          (map['discount'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num).toDouble(),
      notes: (map['notes'] as String?) ?? '',
      posted:
          ((map['posted'] as num?)?.toInt() ?? 1) == 1,
      itemCount:
          (map['item_count'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PurchaseItemRecord {
  const PurchaseItemRecord({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
    required this.total,
  });

  final int id;
  final int purchaseId;
  final int productId;
  final String productName;
  final double quantity;
  final double unitCost;
  final double total;

  factory PurchaseItemRecord.fromMap(
    Map<String, Object?> map,
  ) {
    return PurchaseItemRecord(
      id: map['id'] as int,
      purchaseId: map['purchase_id'] as int,
      productId: map['product_id'] as int,
      productName:
          (map['product_name'] as String?) ?? '',
      quantity: (map['qty'] as num).toDouble(),
      unitCost: (map['unit_cost'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
    );
  }
}

class ReportPoint {
  const ReportPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class ReportSummary {
  const ReportSummary({
    required this.sales,
    required this.returnsValue,
    required this.expenses,
    required this.costOfGoods,
    required this.receivables,
    required this.inventoryValue,
  });

  final double sales;
  final double returnsValue;
  final double expenses;
  final double costOfGoods;
  final double receivables;
  final double inventoryValue;

  double get netSales => sales - returnsValue;

  double get netProfit =>
      netSales - costOfGoods - expenses;
}

class AccountRecord {
  const AccountRecord({
    required this.code,
    required this.name,
    required this.type,
  });

  final String code;
  final String name;
  final String type;

  factory AccountRecord.fromMap(Map<String, Object?> map) {
    return AccountRecord(
      code: map['code'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
    );
  }
}

class InvoiceLineInput {
  const InvoiceLineInput({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  final int productId;
  final double quantity;
  final double unitPrice;
}

class JournalInputLine {
  const JournalInputLine({
    required this.accountCode,
    required this.debit,
    required this.credit,
  });

  final String accountCode;
  final double debit;
  final double credit;
}

class SalesInvoiceRecord {
  const SalesInvoiceRecord({
    required this.id,
    required this.invoiceNumber,
    required this.createdAt,
    required this.dueDate,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.discount,
    required this.total,
    required this.notes,
    required this.posted,
    required this.itemCount,
  });

  final int id;
  final String invoiceNumber;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int? customerId;
  final String customerName;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discount;
  final double total;
  final String notes;
  final bool posted;
  final double itemCount;

  factory SalesInvoiceRecord.fromMap(
    Map<String, Object?> map,
  ) {
    final rawDueDate = map['due_date'] as String?;
    return SalesInvoiceRecord(
      id: map['id'] as int,
      invoiceNumber:
          (map['invoice_number'] as String?) ?? '',
      createdAt:
          DateTime.parse(map['created_at'] as String),
      dueDate: rawDueDate == null || rawDueDate.isEmpty
          ? null
          : DateTime.parse(rawDueDate),
      customerId: map['customer_id'] as int?,
      customerName:
          (map['customer_name'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'paid',
      paymentMethod:
          (map['payment_method'] as String?) ?? 'cash',
      subtotal: (map['subtotal'] as num?)?.toDouble() ??
          (map['total'] as num).toDouble(),
      taxRate: (map['tax_rate'] as num?)?.toDouble() ?? 0,
      taxAmount:
          (map['tax_amount'] as num?)?.toDouble() ?? 0,
      discount:
          (map['discount'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num).toDouble(),
      notes: (map['notes'] as String?) ?? '',
      posted: ((map['posted'] as num?)?.toInt() ?? 1) == 1,
      itemCount:
          (map['item_count'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SaleItemRecord {
  const SaleItemRecord({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
    required this.total,
    required this.returnedQuantity,
  });

  final int id;
  final int saleId;
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double unitCost;
  final double total;
  final double returnedQuantity;

  double get returnableQuantity =>
      (quantity - returnedQuantity)
          .clamp(0.0, quantity)
          .toDouble();

  factory SaleItemRecord.fromMap(
    Map<String, Object?> map,
  ) {
    return SaleItemRecord(
      id: map['id'] as int,
      saleId: map['sale_id'] as int,
      productId: map['product_id'] as int,
      productName:
          (map['product_name'] as String?) ?? '',
      quantity: (map['qty'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      unitCost:
          (map['unit_cost'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num).toDouble(),
      returnedQuantity:
          (map['returned_qty'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SaleReturnSummaryRecord {
  const SaleReturnSummaryRecord({
    required this.id,
    required this.saleId,
    required this.createdAt,
    required this.total,
    required this.reference,
  });

  final int id;
  final int saleId;
  final DateTime createdAt;
  final double total;
  final String reference;

  factory SaleReturnSummaryRecord.fromMap(
    Map<String, Object?> map,
  ) {
    return SaleReturnSummaryRecord(
      id: map['id'] as int,
      saleId: map['sale_id'] as int,
      createdAt:
          DateTime.parse(map['created_at'] as String),
      total: (map['total'] as num).toDouble(),
      reference: (map['reference'] as String?) ?? '',
    );
  }
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<void> initialize({bool inMemory = false}) async {
    if (_db != null) return;

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (inMemory) {
      dbPath = inMemoryDatabasePath;
    } else {
      try {
        final dir = await getApplicationSupportDirectory();
        await dir.create(recursive: true);
        dbPath = p.join(dir.path, 'diftiri.db');
      } catch (_) {
        final dir = await Directory.systemTemp.createTemp('diftiri_');
        dbPath = p.join(dir.path, 'diftiri.db');
      }
    }

    _db = await openDatabase(
      dbPath,
      version: 5,
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
        if (oldVersion < 3) {
          await _createVersion3Tables(db);
          await _seedVersion3(db);
        }
        if (oldVersion < 4) {
          await _upgradeToVersion4(db);
        }
        if (oldVersion < 5) {
          await _upgradeToVersion5(db);
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
        payment_method TEXT NOT NULL,
        order_type TEXT NOT NULL DEFAULT 'retail',
        table_name TEXT NOT NULL DEFAULT '',
        invoice_number TEXT NOT NULL DEFAULT '',
        customer_id INTEGER,
        status TEXT NOT NULL DEFAULT 'paid',
        due_date TEXT,
        notes TEXT NOT NULL DEFAULT '',
        subtotal REAL NOT NULL DEFAULT 0,
        tax_rate REAL NOT NULL DEFAULT 0,
        tax_amount REAL NOT NULL DEFAULT 0,
        discount REAL NOT NULL DEFAULT 0,
        posted INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty REAL NOT NULL,
        unit_price REAL NOT NULL,
        unit_cost REAL NOT NULL DEFAULT 0,
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
        total REAL NOT NULL,
        invoice_number TEXT NOT NULL DEFAULT '',
        supplier_id INTEGER,
        status TEXT NOT NULL DEFAULT 'paid',
        due_date TEXT,
        notes TEXT NOT NULL DEFAULT '',
        subtotal REAL NOT NULL DEFAULT 0,
        tax_rate REAL NOT NULL DEFAULT 0,
        tax_amount REAL NOT NULL DEFAULT 0,
        discount REAL NOT NULL DEFAULT 0,
        posted INTEGER NOT NULL DEFAULT 1,
        payment_method TEXT NOT NULL DEFAULT 'cash'
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

  Future<void> _createVersion3Tables(
    Database db,
  ) async {
    await db.execute(
      "ALTER TABLE sales ADD COLUMN "
      "order_type TEXT NOT NULL DEFAULT 'retail'",
    );

    await db.execute(
      "ALTER TABLE sales ADD COLUMN "
      "table_name TEXT NOT NULL DEFAULT ''",
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS restaurant_tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }


  Future<void> _upgradeToVersion4(Database db) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info(sales)',
    );
    final names = columns
        .map((row) => row['name'] as String)
        .toSet();

    Future<void> addColumn(
      String name,
      String definition,
    ) async {
      if (!names.contains(name)) {
        await db.execute(
          'ALTER TABLE sales ADD COLUMN ' +
              name +
              ' ' +
              definition,
        );
        names.add(name);
      }
    }

    await addColumn(
      'invoice_number',
      "TEXT NOT NULL DEFAULT ''",
    );
    await addColumn('customer_id', 'INTEGER');
    await addColumn(
      'status',
      "TEXT NOT NULL DEFAULT 'paid'",
    );
    await addColumn('due_date', 'TEXT');
    await addColumn(
      'notes',
      "TEXT NOT NULL DEFAULT ''",
    );
    await addColumn(
      'subtotal',
      'REAL NOT NULL DEFAULT 0',
    );
    await addColumn(
      'tax_rate',
      'REAL NOT NULL DEFAULT 0',
    );
    await addColumn(
      'tax_amount',
      'REAL NOT NULL DEFAULT 0',
    );
    await addColumn(
      'discount',
      'REAL NOT NULL DEFAULT 0',
    );
    await addColumn(
      'posted',
      'INTEGER NOT NULL DEFAULT 1',
    );

    final itemColumns = await db.rawQuery(
      'PRAGMA table_info(sale_items)',
    );
    final itemNames = itemColumns
        .map((row) => row['name'] as String)
        .toSet();

    if (!itemNames.contains('unit_cost')) {
      await db.execute(
        'ALTER TABLE sale_items ADD COLUMN '
        'unit_cost REAL NOT NULL DEFAULT 0',
      );
    }

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_returns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        total REAL NOT NULL,
        reference TEXT NOT NULL DEFAULT '',
        note TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (sale_id)
          REFERENCES sales(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_return_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_id INTEGER NOT NULL,
        sale_item_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty REAL NOT NULL,
        unit_price REAL NOT NULL,
        unit_cost REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL,
        FOREIGN KEY (return_id)
          REFERENCES sale_returns(id)
          ON DELETE CASCADE,
        FOREIGN KEY (sale_item_id)
          REFERENCES sale_items(id),
        FOREIGN KEY (product_id)
          REFERENCES products(id)
      )
    ''');

    await db.execute(
      "UPDATE sales SET "
      "invoice_number = 'INV-' || id "
      "WHERE invoice_number = ''",
    );
    await db.execute(
      'UPDATE sales SET subtotal = total '
      'WHERE subtotal = 0',
    );
    await db.execute('''
      UPDATE sale_items
      SET unit_cost = COALESCE(
        (
          SELECT p.cost_price
          FROM products p
          WHERE p.id = sale_items.product_id
        ),
        0
      )
      WHERE unit_cost = 0
    ''');

    const extraAccounts = [
      ['110', 'العملاء', 'asset'],
      ['211', 'ضريبة مخرجات', 'liability'],
      ['402', 'مردودات المبيعات', 'contra_revenue'],
      ['130', 'ضريبة مدخلات', 'asset'],
    ];

    for (final account in extraAccounts) {
      await db.insert(
        'accounts',
        {
          'code': account[0],
          'name': account[1],
          'type': account[2],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }


  Future<void> _upgradeToVersion5(Database db) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info(purchases)',
    );
    final names = columns
        .map((row) => row['name'] as String)
        .toSet();

    Future<void> addColumn(
      String name,
      String definition,
    ) async {
      if (!names.contains(name)) {
        await db.execute(
          'ALTER TABLE purchases ADD COLUMN ' +
              name +
              ' ' +
              definition,
        );
        names.add(name);
      }
    }

    await addColumn(
      'invoice_number',
      "TEXT NOT NULL DEFAULT ''",
    );
    await addColumn('supplier_id', 'INTEGER');
    await addColumn(
      'status',
      "TEXT NOT NULL DEFAULT 'paid'",
    );
    await addColumn('due_date', 'TEXT');
    await addColumn(
      'notes',
      "TEXT NOT NULL DEFAULT ''",
    );
    await addColumn(
      'subtotal',
      'REAL NOT NULL DEFAULT 0',
    );
    await addColumn(
      'tax_rate',
      'REAL NOT NULL DEFAULT 0',
    );
    await addColumn(
      'tax_amount',
      'REAL NOT NULL DEFAULT 0',
    );
    await addColumn(
      'discount',
      'REAL NOT NULL DEFAULT 0',
    );
    await addColumn(
      'posted',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await addColumn(
      'payment_method',
      "TEXT NOT NULL DEFAULT 'cash'",
    );

    await db.execute(
      "UPDATE purchases SET "
      "invoice_number = 'PINV-' || id "
      "WHERE invoice_number = ''",
    );
    await db.execute(
      'UPDATE purchases SET subtotal = total '
      'WHERE subtotal = 0',
    );

    await db.insert(
      'accounts',
      {
        'code': '130',
        'name': 'ضريبة مدخلات',
        'type': 'asset',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> _seedVersion3(Database db) async {
    for (var i = 1; i <= 4; i++) {
      await db.insert(
        'restaurant_tables',
        {
          'name': 'طاولة ' + i.toString(),
          'active': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
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
      ['110', 'العملاء', 'asset'],
      ['211', 'ضريبة مخرجات', 'liability'],
      ['402', 'مردودات المبيعات', 'contra_revenue'],
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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS restaurant_tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await _seedVersion3(db);
    await _upgradeToVersion4(db);
    await _upgradeToVersion5(db);
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

  Future<void> updateProduct({
    required int id,
    required String name,
    required String sku,
    required double salePrice,
    required double costPrice,
    required double stock,
    required bool trackStock,
    String category = '',
  }) async {
    await db.update(
      'products',
      {
        'name': name.trim(),
        'sku': sku.trim(),
        'sale_price': salePrice,
        'cost_price': costPrice,
        'stock': stock,
        'track_stock': trackStock ? 1 : 0,
        'category': category.trim(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> recordSale(
    Map<int, int> quantities, {
    String paymentMethod = 'cash',
    String orderType = 'retail',
    String tableName = '',
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
        'order_type': orderType,
        'table_name': tableName,
      });

      for (final item in quantities.entries) {
        final product = products[item.key]!;
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': product.id,
          'qty': item.value,
          'unit_price': product.salePrice,
          'unit_cost': product.costPrice,
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
    double openingBalance = 0,
  }) async {
    return db.transaction((txn) async {
      final id = await txn.insert('parties', {
        'type': type,
        'name': name.trim(),
        'phone': phone.trim(),
        'balance': openingBalance,
      });

      if (openingBalance > 0) {
        final now = DateTime.now().toIso8601String();
        final entryId = await _insertJournalEntry(
          txn,
          reference: 'OPEN-PARTY-' + id.toString(),
          memo: 'رصيد افتتاحي - ' + name.trim(),
          createdAt: now,
        );

        if (type == 'customer') {
          await _insertJournalLine(
            txn,
            entryId: entryId,
            accountCode: '110',
            debit: openingBalance,
          );
          await _insertJournalLine(
            txn,
            entryId: entryId,
            accountCode: '301',
            credit: openingBalance,
          );
        } else {
          await _insertJournalLine(
            txn,
            entryId: entryId,
            accountCode: '301',
            debit: openingBalance,
          );
          await _insertJournalLine(
            txn,
            entryId: entryId,
            accountCode: '201',
            credit: openingBalance,
          );
        }
      }

      return id;
    });
  }

  Future<void> updateParty({
    required int id,
    required String name,
    String phone = '',
  }) async {
    await db.update(
      'parties',
      {
        'name': name.trim(),
        'phone': phone.trim(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
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




  Future<List<RestaurantTableRecord>>
      getRestaurantTables() async {
    final rows = await db.query(
      'restaurant_tables',
      where: 'active = 1',
      orderBy: 'id ASC',
    );

    return rows
        .map(RestaurantTableRecord.fromMap)
        .toList();
  }

  Future<int> addRestaurantTable(
    String name,
  ) {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('اسم الطاولة مطلوب');
    }

    return db.insert(
      'restaurant_tables',
      {
        'name': normalized,
        'active': 1,
      },
      conflictAlgorithm:
          ConflictAlgorithm.abort,
    );
  }

  Future<void> deactivateRestaurantTable(
    int id,
  ) async {
    await db.update(
      'restaurant_tables',
      {'active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SaleSummaryRecord>>
      getSalesHistory() async {
    final rows = await db.rawQuery('''
      SELECT
        s.id,
        s.created_at,
        s.total,
        s.payment_method,
        s.order_type,
        s.table_name,
        COALESCE(SUM(i.qty), 0) AS item_count
      FROM sales s
      LEFT JOIN sale_items i
        ON i.sale_id = s.id
      GROUP BY
        s.id,
        s.created_at,
        s.total,
        s.payment_method,
        s.order_type,
        s.table_name
      ORDER BY s.id DESC
      LIMIT 250
    ''');

    return rows
        .map(SaleSummaryRecord.fromMap)
        .toList();
  }

  Future<List<PurchaseSummaryRecord>>
      getPurchasesHistory() async {
    final rows = await db.rawQuery('''
      SELECT
        p.id,
        p.created_at,
        p.supplier_name,
        p.total,
        COALESCE(SUM(i.qty), 0) AS item_count
      FROM purchases p
      LEFT JOIN purchase_items i
        ON i.purchase_id = p.id
      GROUP BY
        p.id,
        p.created_at,
        p.supplier_name,
        p.total
      ORDER BY p.id DESC
      LIMIT 250
    ''');

    return rows
        .map(PurchaseSummaryRecord.fromMap)
        .toList();
  }

  Future<void> addCashOpeningBalance(
    double amount,
  ) async {
    if (amount <= 0) {
      throw ArgumentError(
        'الرصيد الافتتاحي يجب أن يكون أكبر من صفر',
      );
    }

    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final reference =
          'CASH-OPEN-' +
          DateTime.now()
              .millisecondsSinceEpoch
              .toString();

      final entryId = await _insertJournalEntry(
        txn,
        reference: reference,
        memo: 'رصيد افتتاحي للصندوق',
        createdAt: now,
      );

      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '101',
        debit: amount,
      );

      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '301',
        credit: amount,
      );
    });
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

    for (final entry in values.entries) {
      await db.insert(
        'app_settings',
        {
          'key': entry.key,
          'value': entry.value,
        },
        conflictAlgorithm:
            ConflictAlgorithm.replace,
      );
    }
  }


  Future<List<AccountRecord>> getAccounts() async {
    final rows = await db.query(
      'accounts',
      orderBy: 'code ASC',
    );
    return rows.map(AccountRecord.fromMap).toList();
  }

  Future<List<SalesInvoiceRecord>> getSalesInvoices({
    String query = '',
    String status = 'all',
  }) async {
    final filters = <String>[];
    final args = <Object?>[];

    if (status != 'all') {
      filters.add('s.status = ?');
      args.add(status);
    }

    final normalized = query.trim();
    if (normalized.isNotEmpty) {
      filters.add(
        '(s.invoice_number LIKE ? '
        'OR COALESCE(p.name, \'\') LIKE ?)',
      );
      args.add('%' + normalized + '%');
      args.add('%' + normalized + '%');
    }

    final where = filters.isEmpty
        ? ''
        : 'WHERE ' + filters.join(' AND ');

    final rows = await db.rawQuery('''
      SELECT
        s.id,
        s.invoice_number,
        s.created_at,
        s.due_date,
        s.customer_id,
        COALESCE(p.name, '') AS customer_name,
        s.status,
        s.payment_method,
        s.subtotal,
        s.tax_rate,
        s.tax_amount,
        s.discount,
        s.total,
        s.notes,
        s.posted,
        COALESCE(SUM(i.qty), 0) AS item_count
      FROM sales s
      LEFT JOIN parties p
        ON p.id = s.customer_id
      LEFT JOIN sale_items i
        ON i.sale_id = s.id
      $where
      GROUP BY
        s.id,
        s.invoice_number,
        s.created_at,
        s.due_date,
        s.customer_id,
        p.name,
        s.status,
        s.payment_method,
        s.subtotal,
        s.tax_rate,
        s.tax_amount,
        s.discount,
        s.total,
        s.notes,
        s.posted
      ORDER BY s.id DESC
      LIMIT 300
    ''', args);

    return rows
        .map(SalesInvoiceRecord.fromMap)
        .toList();
  }

  Future<SalesInvoiceRecord?> getSalesInvoice(
    int saleId,
  ) async {
    final rows = await db.rawQuery('''
      SELECT
        s.id,
        s.invoice_number,
        s.created_at,
        s.due_date,
        s.customer_id,
        COALESCE(p.name, '') AS customer_name,
        s.status,
        s.payment_method,
        s.subtotal,
        s.tax_rate,
        s.tax_amount,
        s.discount,
        s.total,
        s.notes,
        s.posted,
        COALESCE(SUM(i.qty), 0) AS item_count
      FROM sales s
      LEFT JOIN parties p
        ON p.id = s.customer_id
      LEFT JOIN sale_items i
        ON i.sale_id = s.id
      WHERE s.id = ?
      GROUP BY s.id
      LIMIT 1
    ''', [saleId]);

    if (rows.isEmpty) return null;
    return SalesInvoiceRecord.fromMap(rows.first);
  }

  Future<List<SaleItemRecord>> getSaleItems(
    int saleId,
  ) async {
    final rows = await db.rawQuery('''
      SELECT
        i.id,
        i.sale_id,
        i.product_id,
        p.name AS product_name,
        i.qty,
        i.unit_price,
        i.unit_cost,
        i.total,
        COALESCE(
          (
            SELECT SUM(ri.qty)
            FROM sale_return_items ri
            WHERE ri.sale_item_id = i.id
          ),
          0
        ) AS returned_qty
      FROM sale_items i
      JOIN products p
        ON p.id = i.product_id
      WHERE i.sale_id = ?
      ORDER BY i.id ASC
    ''', [saleId]);

    return rows.map(SaleItemRecord.fromMap).toList();
  }

  Future<int> saveSalesInvoice({
    int? saleId,
    required List<InvoiceLineInput> lines,
    int? customerId,
    required DateTime createdAt,
    DateTime? dueDate,
    required String paymentMethod,
    required String status,
    String notes = '',
    double taxRate = 0,
    double discount = 0,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('أضف صنفًا واحدًا على الأقل');
    }
    if (taxRate < 0 || discount < 0) {
      throw ArgumentError('قيم الضريبة والخصم غير صحيحة');
    }

    return db.transaction((txn) async {
      if (saleId != null) {
        final existing = await txn.query(
          'sales',
          columns: ['status', 'posted'],
          where: 'id = ?',
          whereArgs: [saleId],
          limit: 1,
        );
        if (existing.isEmpty) {
          throw StateError('الفاتورة غير موجودة');
        }
        final posted =
            (existing.first['posted'] as num).toInt() == 1;
        if (posted) {
          throw StateError(
            'الفاتورة المرحلة لا تُعدّل. استخدم المرتجع.',
          );
        }
      }

      double subtotal = 0;
      double totalCost = 0;
      final products = <int, ProductRecord>{};

      for (final line in lines) {
        if (line.quantity <= 0 || line.unitPrice < 0) {
          throw ArgumentError('بيانات الصنف غير صحيحة');
        }
        final rows = await txn.query(
          'products',
          where: 'id = ?',
          whereArgs: [line.productId],
          limit: 1,
        );
        if (rows.isEmpty) {
          throw StateError('أحد الأصناف غير موجود');
        }
        final product =
            ProductRecord.fromMap(rows.first);
        products[line.productId] = product;
        subtotal += line.quantity * line.unitPrice;
        if (product.trackStock) {
          totalCost += line.quantity * product.costPrice;
        }
      }

      final taxableBase =
          (subtotal - discount)
              .clamp(0.0, subtotal)
              .toDouble();
      final taxAmount = taxableBase * taxRate / 100;
      final total = taxableBase + taxAmount;
      final posted = status == 'draft' ? 0 : 1;
      final values = <String, Object?>{
        'created_at': createdAt.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
        'customer_id': customerId,
        'status': status,
        'payment_method': paymentMethod,
        'notes': notes.trim(),
        'subtotal': subtotal,
        'tax_rate': taxRate,
        'tax_amount': taxAmount,
        'discount': discount,
        'total': total,
        'posted': posted,
        'order_type': 'invoice',
        'table_name': '',
      };

      int id;
      if (saleId == null) {
        id = await txn.insert('sales', {
          ...values,
          'invoice_number': '',
        });
        await txn.update(
          'sales',
          {'invoice_number': 'INV-' + id.toString()},
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        id = saleId;
        await txn.update(
          'sales',
          values,
          where: 'id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'sale_items',
          where: 'sale_id = ?',
          whereArgs: [id],
        );
      }

      for (final line in lines) {
        final product = products[line.productId]!;
        await txn.insert('sale_items', {
          'sale_id': id,
          'product_id': line.productId,
          'qty': line.quantity,
          'unit_price': line.unitPrice,
          'unit_cost': product.costPrice,
          'total': line.quantity * line.unitPrice,
        });
      }

      if (posted == 1) {
        for (final line in lines) {
          final product = products[line.productId]!;
          if (product.trackStock) {
            if (product.stock < line.quantity) {
              throw StateError(
                'المخزون غير كافٍ للصنف: ' +
                    product.name,
              );
            }
            await txn.rawUpdate(
              'UPDATE products '
              'SET stock = stock - ? '
              'WHERE id = ?',
              [line.quantity, line.productId],
            );
          }
        }

        final entryId = await _insertJournalEntry(
          txn,
          reference: 'INV-' + id.toString(),
          memo: 'فاتورة مبيعات',
          createdAt: createdAt.toIso8601String(),
        );

        final receivableAccount =
            status == 'paid' ? '101' : '110';

        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: receivableAccount,
          debit: total,
        );
        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: '401',
          credit: taxableBase,
        );
        if (taxAmount > 0) {
          await _insertJournalLine(
            txn,
            entryId: entryId,
            accountCode: '211',
            credit: taxAmount,
          );
        }
        if (totalCost > 0) {
          await _insertJournalLine(
            txn,
            entryId: entryId,
            accountCode: '501',
            debit: totalCost,
          );
          await _insertJournalLine(
            txn,
            entryId: entryId,
            accountCode: '120',
            credit: totalCost,
          );
        }
      }

      return id;
    });
  }

  Future<int> recordSaleReturn({
    required int saleId,
    required Map<int, double> quantitiesBySaleItem,
    String note = '',
  }) async {
    if (quantitiesBySaleItem.isEmpty) {
      throw ArgumentError('حدد صنفًا للمرتجع');
    }

    return db.transaction((txn) async {
      final saleRows = await txn.query(
        'sales',
        where: 'id = ? AND posted = 1',
        whereArgs: [saleId],
        limit: 1,
      );
      if (saleRows.isEmpty) {
        throw StateError('لا يمكن إرجاع هذه الفاتورة');
      }

      final sale = saleRows.first;
      double refundTotal = 0;
      double returnedCost = 0;
      final validItems = <Map<String, Object?>>[];

      for (final entry in quantitiesBySaleItem.entries) {
        if (entry.value <= 0) continue;

        final itemRows = await txn.rawQuery('''
          SELECT
            i.id,
            i.product_id,
            i.qty,
            i.unit_price,
            i.unit_cost,
            p.track_stock,
            p.name,
            COALESCE(
              (
                SELECT SUM(ri.qty)
                FROM sale_return_items ri
                WHERE ri.sale_item_id = i.id
              ),
              0
            ) AS returned_qty
          FROM sale_items i
          JOIN products p
            ON p.id = i.product_id
          WHERE i.id = ? AND i.sale_id = ?
          LIMIT 1
        ''', [entry.key, saleId]);

        if (itemRows.isEmpty) {
          throw StateError('بند المرتجع غير موجود');
        }

        final item = itemRows.first;
        final soldQty =
            (item['qty'] as num).toDouble();
        final alreadyReturned =
            (item['returned_qty'] as num).toDouble();
        final available = soldQty - alreadyReturned;

        if (entry.value > available) {
          throw StateError(
            'كمية المرتجع أكبر من المسموح للصنف ' +
                (item['name'] as String),
          );
        }

        final unitPrice =
            (item['unit_price'] as num).toDouble();
        final unitCost =
            (item['unit_cost'] as num).toDouble();

        refundTotal += entry.value * unitPrice;
        returnedCost += entry.value * unitCost;

        validItems.add({
          'sale_item_id': entry.key,
          'product_id': item['product_id'],
          'qty': entry.value,
          'unit_price': unitPrice,
          'unit_cost': unitCost,
          'track_stock': item['track_stock'],
        });
      }

      if (validItems.isEmpty || refundTotal <= 0) {
        throw ArgumentError('حدد كمية مرتجع صحيحة');
      }

      final now = DateTime.now().toIso8601String();
      final returnId = await txn.insert(
        'sale_returns',
        {
          'sale_id': saleId,
          'created_at': now,
          'total': refundTotal,
          'reference': '',
          'note': note.trim(),
        },
      );
      final reference =
          'RET-' + returnId.toString();
      await txn.update(
        'sale_returns',
        {'reference': reference},
        where: 'id = ?',
        whereArgs: [returnId],
      );

      for (final item in validItems) {
        await txn.insert(
          'sale_return_items',
          {
            'return_id': returnId,
            'sale_item_id': item['sale_item_id'],
            'product_id': item['product_id'],
            'qty': item['qty'],
            'unit_price': item['unit_price'],
            'unit_cost': item['unit_cost'],
            'total':
                (item['qty'] as num).toDouble() *
                (item['unit_price'] as num).toDouble(),
          },
        );

        if ((item['track_stock'] as num).toInt() == 1) {
          await txn.rawUpdate(
            'UPDATE products '
            'SET stock = stock + ? '
            'WHERE id = ?',
            [item['qty'], item['product_id']],
          );
        }
      }

      final entryId = await _insertJournalEntry(
        txn,
        reference: reference,
        memo: 'مرتجع مبيعات',
        createdAt: now,
      );

      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode: '402',
        debit: refundTotal,
      );

      final originalStatus =
          (sale['status'] as String?) ?? 'paid';
      await _insertJournalLine(
        txn,
        entryId: entryId,
        accountCode:
            originalStatus == 'paid' ? '101' : '110',
        credit: refundTotal,
      );

      if (returnedCost > 0) {
        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: '120',
          debit: returnedCost,
        );
        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: '501',
          credit: returnedCost,
        );
      }

      return returnId;
    });
  }

  Future<List<SaleReturnSummaryRecord>>
      getSaleReturns() async {
    final rows = await db.query(
      'sale_returns',
      orderBy: 'id DESC',
      limit: 200,
    );
    return rows
        .map(SaleReturnSummaryRecord.fromMap)
        .toList();
  }

  Future<int> recordManualJournal({
    required DateTime date,
    required String memo,
    required List<JournalInputLine> lines,
  }) async {
    final validLines = lines
        .where(
          (line) => line.debit > 0 || line.credit > 0,
        )
        .toList();

    if (validLines.length < 2) {
      throw ArgumentError('القيد يحتاج سطرين على الأقل');
    }

    final totalDebit = validLines.fold<double>(
      0,
      (sum, line) => sum + line.debit,
    );
    final totalCredit = validLines.fold<double>(
      0,
      (sum, line) => sum + line.credit,
    );

    if ((totalDebit - totalCredit).abs() > 0.001) {
      throw ArgumentError('القيد غير متوازن');
    }

    return db.transaction((txn) async {
      final reference = 'JV-' +
          DateTime.now()
              .millisecondsSinceEpoch
              .toString();

      final entryId = await _insertJournalEntry(
        txn,
        reference: reference,
        memo: memo.trim(),
        createdAt: date.toIso8601String(),
      );

      for (final line in validLines) {
        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: line.accountCode,
          debit: line.debit,
          credit: line.credit,
        );
      }

      return entryId;
    });
  }


  Future<ReportSummary> getReportSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    final now = DateTime.now();
    final start = from ??
        DateTime(now.year, now.month, 1);
    final end = to ??
        DateTime(
          now.year,
          now.month + 1,
          1,
        );

    final startIso = start.toIso8601String();
    final endIso = end.toIso8601String();

    final salesRows = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS value '
      'FROM sales '
      'WHERE posted = 1 '
      'AND created_at >= ? '
      'AND created_at < ?',
      [startIso, endIso],
    );

    final returnsRows = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS value '
      'FROM sale_returns '
      'WHERE created_at >= ? '
      'AND created_at < ?',
      [startIso, endIso],
    );

    final expensesRows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS value '
      'FROM expenses '
      'WHERE created_at >= ? '
      'AND created_at < ?',
      [startIso, endIso],
    );

    final cogsRows = await db.rawQuery('''
      SELECT COALESCE(SUM(l.debit - l.credit), 0) AS value
      FROM journal_lines l
      JOIN journal_entries e ON e.id = l.entry_id
      WHERE l.account_code = '501'
        AND e.created_at >= ?
        AND e.created_at < ?
    ''', [startIso, endIso]);

    final receivableRows = await db.rawQuery('''
      SELECT COALESCE(SUM(debit - credit), 0) AS value
      FROM journal_lines
      WHERE account_code = '110'
    ''');

    final inventoryRows = await db.rawQuery('''
      SELECT COALESCE(
        SUM(
          CASE
            WHEN track_stock = 1
            THEN stock * cost_price
            ELSE 0
          END
        ),
        0
      ) AS value
      FROM products
    ''');

    return ReportSummary(
      sales:
          (salesRows.first['value'] as num).toDouble(),
      returnsValue:
          (returnsRows.first['value'] as num).toDouble(),
      expenses:
          (expensesRows.first['value'] as num).toDouble(),
      costOfGoods:
          (cogsRows.first['value'] as num).toDouble(),
      receivables:
          (receivableRows.first['value'] as num).toDouble(),
      inventoryValue:
          (inventoryRows.first['value'] as num).toDouble(),
    );
  }

  Future<List<ReportPoint>> getMonthlySalesTrend({
    int months = 6,
  }) async {
    final now = DateTime.now();
    final result = <ReportPoint>[];
    const monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    for (var offset = months - 1;
        offset >= 0;
        offset--) {
      final start = DateTime(
        now.year,
        now.month - offset,
        1,
      );
      final end = DateTime(
        start.year,
        start.month + 1,
        1,
      );

      final salesRows = await db.rawQuery(
        'SELECT COALESCE(SUM(total), 0) AS value '
        'FROM sales '
        'WHERE posted = 1 '
        'AND created_at >= ? '
        'AND created_at < ?',
        [
          start.toIso8601String(),
          end.toIso8601String(),
        ],
      );

      final returnRows = await db.rawQuery(
        'SELECT COALESCE(SUM(total), 0) AS value '
        'FROM sale_returns '
        'WHERE created_at >= ? '
        'AND created_at < ?',
        [
          start.toIso8601String(),
          end.toIso8601String(),
        ],
      );

      final sales =
          (salesRows.first['value'] as num).toDouble();
      final returnsValue =
          (returnRows.first['value'] as num)
              .toDouble();

      result.add(
        ReportPoint(
          label: monthNames[start.month - 1],
          value: sales - returnsValue,
        ),
      );
    }

    return result;
  }


  Future<List<PurchaseInvoiceRecord>>
      getPurchaseInvoices({
    String query = '',
    String status = 'all',
  }) async {
    final filters = <String>[];
    final args = <Object?>[];

    if (status != 'all') {
      filters.add('p.status = ?');
      args.add(status);
    }

    final normalized = query.trim();
    if (normalized.isNotEmpty) {
      filters.add(
        '(p.invoice_number LIKE ? '
        'OR COALESCE(s.name, p.supplier_name, \'\') LIKE ?)',
      );
      args.add('%' + normalized + '%');
      args.add('%' + normalized + '%');
    }

    final where = filters.isEmpty
        ? ''
        : 'WHERE ' + filters.join(' AND ');

    final rows = await db.rawQuery('''
      SELECT
        p.id,
        p.invoice_number,
        p.created_at,
        p.due_date,
        p.supplier_id,
        COALESCE(s.name, p.supplier_name, '') AS supplier_name,
        p.status,
        p.payment_method,
        p.subtotal,
        p.tax_rate,
        p.tax_amount,
        p.discount,
        p.total,
        p.notes,
        p.posted,
        COALESCE(SUM(i.qty), 0) AS item_count
      FROM purchases p
      LEFT JOIN parties s
        ON s.id = p.supplier_id
      LEFT JOIN purchase_items i
        ON i.purchase_id = p.id
      $where
      GROUP BY
        p.id,
        p.invoice_number,
        p.created_at,
        p.due_date,
        p.supplier_id,
        s.name,
        p.supplier_name,
        p.status,
        p.payment_method,
        p.subtotal,
        p.tax_rate,
        p.tax_amount,
        p.discount,
        p.total,
        p.notes,
        p.posted
      ORDER BY p.id DESC
      LIMIT 300
    ''', args);

    return rows
        .map(PurchaseInvoiceRecord.fromMap)
        .toList();
  }

  Future<PurchaseInvoiceRecord?>
      getPurchaseInvoice(
    int purchaseId,
  ) async {
    final rows = await db.rawQuery('''
      SELECT
        p.id,
        p.invoice_number,
        p.created_at,
        p.due_date,
        p.supplier_id,
        COALESCE(s.name, p.supplier_name, '') AS supplier_name,
        p.status,
        p.payment_method,
        p.subtotal,
        p.tax_rate,
        p.tax_amount,
        p.discount,
        p.total,
        p.notes,
        p.posted,
        COALESCE(SUM(i.qty), 0) AS item_count
      FROM purchases p
      LEFT JOIN parties s
        ON s.id = p.supplier_id
      LEFT JOIN purchase_items i
        ON i.purchase_id = p.id
      WHERE p.id = ?
      GROUP BY p.id
      LIMIT 1
    ''', [purchaseId]);

    if (rows.isEmpty) return null;
    return PurchaseInvoiceRecord.fromMap(
      rows.first,
    );
  }

  Future<List<PurchaseItemRecord>>
      getPurchaseItems(
    int purchaseId,
  ) async {
    final rows = await db.rawQuery('''
      SELECT
        i.id,
        i.purchase_id,
        i.product_id,
        p.name AS product_name,
        i.qty,
        i.unit_cost,
        i.total
      FROM purchase_items i
      JOIN products p
        ON p.id = i.product_id
      WHERE i.purchase_id = ?
      ORDER BY i.id ASC
    ''', [purchaseId]);

    return rows
        .map(PurchaseItemRecord.fromMap)
        .toList();
  }

  Future<int> savePurchaseInvoice({
    int? purchaseId,
    required List<PurchaseLineInput> lines,
    int? supplierId,
    required DateTime createdAt,
    DateTime? dueDate,
    required String paymentMethod,
    required String status,
    String notes = '',
    double taxRate = 0,
    double discount = 0,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('أضف صنفًا واحدًا على الأقل');
    }

    return db.transaction((txn) async {
      if (purchaseId != null) {
        final existing = await txn.query(
          'purchases',
          columns: ['posted'],
          where: 'id = ?',
          whereArgs: [purchaseId],
          limit: 1,
        );
        if (existing.isEmpty) {
          throw StateError('فاتورة الشراء غير موجودة');
        }
        final posted =
            (existing.first['posted'] as num).toInt() == 1;
        if (posted) {
          throw StateError(
            'فاتورة الشراء المرحلة لا تُعدّل',
          );
        }
      }

      double subtotal = 0;
      final products = <int, ProductRecord>{};

      for (final line in lines) {
        if (line.quantity <= 0 || line.unitCost < 0) {
          throw ArgumentError('بيانات الصنف غير صحيحة');
        }

        final rows = await txn.query(
          'products',
          where: 'id = ?',
          whereArgs: [line.productId],
          limit: 1,
        );
        if (rows.isEmpty) {
          throw StateError('أحد الأصناف غير موجود');
        }

        final product =
            ProductRecord.fromMap(rows.first);
        products[line.productId] = product;
        subtotal += line.quantity * line.unitCost;
      }

      final taxableBase = (subtotal - discount)
          .clamp(0.0, subtotal)
          .toDouble();
      final taxAmount =
          taxableBase * taxRate / 100;
      final total = taxableBase + taxAmount;
      final posted = status == 'draft' ? 0 : 1;

      String supplierName = '';
      if (supplierId != null) {
        final supplierRows = await txn.query(
          'parties',
          columns: ['name'],
          where: 'id = ?',
          whereArgs: [supplierId],
          limit: 1,
        );
        if (supplierRows.isNotEmpty) {
          supplierName =
              supplierRows.first['name'] as String;
        }
      }

      final values = <String, Object?>{
        'created_at': createdAt.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
        'supplier_id': supplierId,
        'supplier_name': supplierName,
        'status': status,
        'payment_method': paymentMethod,
        'notes': notes.trim(),
        'subtotal': subtotal,
        'tax_rate': taxRate,
        'tax_amount': taxAmount,
        'discount': discount,
        'total': total,
        'posted': posted,
      };

      int id;
      if (purchaseId == null) {
        id = await txn.insert('purchases', {
          ...values,
          'invoice_number': '',
        });
        await txn.update(
          'purchases',
          {
            'invoice_number':
                'PINV-' + id.toString(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        id = purchaseId;
        await txn.update(
          'purchases',
          values,
          where: 'id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'purchase_items',
          where: 'purchase_id = ?',
          whereArgs: [id],
        );
      }

      for (final line in lines) {
        await txn.insert('purchase_items', {
          'purchase_id': id,
          'product_id': line.productId,
          'qty': line.quantity,
          'unit_cost': line.unitCost,
          'total': line.quantity * line.unitCost,
        });
      }

      if (posted == 1) {
        for (final line in lines) {
          final product = products[line.productId]!;
          if (product.trackStock) {
            await txn.rawUpdate(
              'UPDATE products '
              'SET stock = stock + ?, '
              'cost_price = ? '
              'WHERE id = ?',
              [
                line.quantity,
                line.unitCost,
                line.productId,
              ],
            );
          }
        }

        final entryId = await _insertJournalEntry(
          txn,
          reference:
              'PINV-' + id.toString(),
          memo: 'فاتورة مشتريات',
          createdAt:
              createdAt.toIso8601String(),
        );

        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode: '120',
          debit: taxableBase,
        );

        if (taxAmount > 0) {
          await _insertJournalLine(
            txn,
            entryId: entryId,
            accountCode: '130',
            debit: taxAmount,
          );
        }

        await _insertJournalLine(
          txn,
          entryId: entryId,
          accountCode:
              status == 'paid' ? '101' : '201',
          credit: total,
        );
      }

      return id;
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
