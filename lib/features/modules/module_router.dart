import 'package:flutter/material.dart';

import 'accounting_screen.dart';
import 'banks_screen.dart';
import 'cash_screen.dart';
import 'expenses_screen.dart';
import 'inventory_screen.dart';
import 'parties_screen.dart';
import 'purchase_invoices_screen.dart';
import 'reports_screen.dart';
import 'restaurant_tables_screen.dart';
import 'sales_invoices_screen.dart';
import 'settings_screen.dart';

abstract final class ModuleRouter {
  static Future<void> open(
    BuildContext context,
    String title,
  ) async {
    Widget screen;

    switch (title) {
      case 'المبيعات':
        screen = const SalesInvoicesScreen();
        break;
      case 'المشتريات':
        screen = const PurchaseInvoicesScreen();
        break;
      case 'المخزون':
        screen = const InventoryScreen();
        break;
      case 'العملاء':
        screen = const PartiesScreen(
          type: 'customer',
          title: 'العملاء',
        );
        break;
      case 'الموردون':
        screen = const PartiesScreen(
          type: 'supplier',
          title: 'الموردون',
        );
        break;
      case 'المصروفات':
        screen = const ExpensesScreen();
        break;
      case 'الحسابات':
        screen = const AccountingScreen(initialTab: 0);
        break;
      case 'القيود':
        screen = const AccountingScreen(initialTab: 1);
        break;
      case 'التقارير':
        screen = const ReportsScreen();
        break;
      case 'الصندوق':
        screen = const CashScreen();
        break;
      case 'الطاولات':
        screen = const RestaurantTablesScreen();
        break;
      case 'البنوك':
        screen = const BanksScreen();
        break;
      case 'الإعدادات':
        screen = const SettingsScreen();
        break;
      default:
        screen = const SettingsScreen();
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => screen,
      ),
    );
  }
}
