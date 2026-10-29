import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'simple_module_screen.dart';

abstract final class ModuleRouter {
  static void open(BuildContext context, String title) {
    final Widget screen;

    switch (title) {
      case 'المبيعات':
        screen = const SalesScreen();
      case 'المخزون':
        screen = const InventoryScreen();
      case 'التقارير':
        screen = const SimpleModuleScreen(
          title: 'التقارير',
          icon: Icons.bar_chart_rounded,
          message: 'ملخص المبيعات، الأرباح، المصروفات وحركة المخزون.',
        );
      case 'المشتريات':
        screen = const SimpleModuleScreen(
          title: 'المشتريات',
          icon: Icons.shopping_bag_rounded,
          message: 'فواتير الشراء، الموردون وتحديث أرصدة المخزون.',
        );
      case 'العملاء':
        screen = const SimpleModuleScreen(
          title: 'العملاء',
          icon: Icons.person_rounded,
          message: 'ملفات العملاء، الأرصدة والحركات.',
        );
      case 'الموردون':
        screen = const SimpleModuleScreen(
          title: 'الموردون',
          icon: Icons.local_shipping_rounded,
          message: 'بيانات الموردين وفواتيرهم وأرصدتهم.',
        );
      case 'الحسابات':
      case 'القيود':
        screen = const SimpleModuleScreen(
          title: 'الحسابات والقيود',
          icon: Icons.menu_book_rounded,
          message: 'شجرة الحسابات والقيود اليومية والترحيل.',
        );
      case 'الصندوق':
      case 'البنوك':
        screen = SimpleModuleScreen(
          title: title,
          icon: Icons.account_balance_wallet_rounded,
          message: 'الأرصدة وحركات القبض والصرف.',
        );
      case 'المصروفات':
        screen = const SimpleModuleScreen(
          title: 'المصروفات',
          icon: Icons.request_quote_rounded,
          message: 'تسجيل وتصنيف المصروفات اليومية.',
        );
      default:
        screen = SimpleModuleScreen(
          title: title,
          icon: Icons.settings_rounded,
          message: 'إعدادات المنشأة والمستخدمين والطباعة.',
        );
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}
