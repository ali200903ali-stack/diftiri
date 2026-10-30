import 'package:flutter/material.dart';

import '../database/app_database.dart';

class AppUiPreferences extends ChangeNotifier {
  AppUiPreferences._();

  static final AppUiPreferences instance = AppUiPreferences._();

  double uiScale = 1;
  double fontScale = 1;
  String invoiceColorHex = '0DB28E';
  String invoicePaper = 'a4';
  bool saleScannerEnabled = true;
  bool scannerSoundEnabled = true;

  Future<void> load() async {
    final settings = await AppDatabase.instance.getBusinessSettings();
    updateFromSettings(settings, notify: false);
  }

  void updateFromSettings(
    BusinessSettingsRecord settings, {
    bool notify = true,
  }) {
    uiScale = settings.uiScale;
    fontScale = settings.fontScale;
    invoiceColorHex = settings.invoiceColorHex;
    invoicePaper = settings.invoicePaper;
    saleScannerEnabled = settings.saleScannerEnabled;
    scannerSoundEnabled = settings.scannerSoundEnabled;
    if (notify) notifyListeners();
  }

  Color get invoiceColor {
    final normalized = invoiceColorHex.replaceAll('#', '');
    final value = int.tryParse(normalized, radix: 16) ?? 0x0DB28E;
    return Color(0xFF000000 | value);
  }
}
