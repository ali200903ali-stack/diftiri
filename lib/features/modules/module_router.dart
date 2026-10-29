import 'package:flutter/material.dart';

import 'accounting_screen.dart';
import 'expenses_screen.dart';
import 'inventory_screen.dart';
import 'parties_screen.dart';
import 'purchase_screen.dart';
import 'reports_screen.dart';
import 'sales_screen.dart';
import 'simple_module_screen.dart';

abstract final class ModuleRouter {
  static Future<void> open(
    BuildContext context,
    String title,
  ) async {
    Widget screen;

    switch (title) {
      case 'المبيعات':
        screen = const SalesScreen();
        break;
      case 'المشتريات':
        screen = const PurchaseScreen();
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
      case 'القيود':
        screen = const AccountingScreen();
        break;
      case 'التقارير':
        screen = const ReportsScreen();
        break;
      case 'الصندوق':
        screen = const SimpleModuleScreen(
          title: 'الصندوق',
          icon: Icons.account_balance_wallet_rounded,
          message:
              'رصيد الصندوق يتحدث آلياً من القيود المحاسبية.',
        );
        break;
      case 'البنوك':
        screen = const SimpleModuleScreen(
          title: 'البنوك',
          icon: Icons.account_balance_rounded,
          message:
              'الحسابات البنكية والتحويلات ستربط بالقيود المحاسبية.',
        );
        break;
      case 'الإعدادات':
        screen = const SimpleModuleScreen(
          title: 'الإعدادات',
          icon: Icons.settings_rounded,
          message:
              'إعدادات المنشأة والمستخدمين والطباعة.',
        );
        break;
      default:
        screen = SimpleModuleScreen(
          title: title,
          icon: Icons.dashboard_customize_rounded,
          message: 'القسم قيد التجهيز.',
        );
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => screen,
      ),
    );
  }
}
