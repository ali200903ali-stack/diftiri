import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'simple_module_screen.dart';

abstract final class ModuleRouter {
  static void open(BuildContext context, String title) {
    final Widget screen = switch (title) {
      'المبيعات' => const SalesScreen(),
      'المخزون' => const InventoryScreen(),
      'التقارير' => const SimpleModuleScreen(
          title: 'التقارير',
          icon: Icons.bar_chart_rounded,
          message: 'ملخص المبيعات، الأرباح، المصروفات وحركة المخزون.',
        ),
      'المشتريات' => const SimpleModuleScreen(
          title: 'المشتريات',
          icon: Icons.shopping_bag_rounded,
          message: 'فواتير الشراء، الموردون وتحديث أرصدة المخزون.',
        ),
      'العملاء' => const SimpleModuleScreen(
          title: 'العملاء',
          icon: Icons.person_rounded,
          message: 'ملفات العملاء، الأرصدة والحركات.',
        ),
      'الموردون' => const SimpleModuleScreen(
          title: 'الموردون',
          icon: Icons.local_shipping_rounded,
          message: 'بيانات الموردين وفواتيرهم وأرصدتهم.',
        ),
      'الحسابات' || 'القيود' => const SimpleModuleScreen(
          title: 'الحسابات والقيود',
          icon: Icons.menu_book_rounded,
          message: 'شجرة الحسابات والقيود اليومية والترحيل.',
        ),
      'الصندوق' || 'البنوك' => SimpleModuleScreen(
          title: title,
          icon: Icons.account_balance_wallet_rounded,
          message: 'الأرصدة وحركات القبض والصرف.',
        ),
      'المصروفات' => const SimpleModuleScreen(
          title: 'المصروفات',
          icon: Icons.request_quote_rounded,
          message: 'تسجيل وتصنيف المصروفات اليومية.',
        ),
      _ => SimpleModuleScreen(
          title: title,
          icon: Icons.settings_rounded,
          message: 'إعدادات المنشأة والمستخدمين والطباعة.',
        ),
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}
