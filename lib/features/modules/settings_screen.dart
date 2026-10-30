import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_ui_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final businessName = TextEditingController();

  String activityType = 'grocery';
  String currency = 'YER';
  double uiScale = 1;
  double fontScale = 1;
  String invoiceColorHex = '0DB28E';
  String invoicePaper = 'a4';
  bool saleScannerEnabled = true;
  bool scannerSoundEnabled = true;
  bool loading = true;
  bool saving = false;

  static const invoiceColors = <String>[
    '0DB28E',
    '123E63',
    '2563EB',
    '7C3AED',
    'C2410C',
    '111827',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    businessName.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await AppDatabase.instance.getBusinessSettings();
    if (!mounted) return;

    setState(() {
      businessName.text = settings.businessName;
      activityType = settings.activityType;
      currency = settings.currency;
      uiScale = settings.uiScale;
      fontScale = settings.fontScale;
      invoiceColorHex = settings.invoiceColorHex;
      invoicePaper = settings.invoicePaper;
      saleScannerEnabled = settings.saleScannerEnabled;
      scannerSoundEnabled = settings.scannerSoundEnabled;
      loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => saving = true);

    await AppDatabase.instance.saveBusinessSettings(
      businessName: businessName.text,
      activityType: activityType,
      currency: currency,
      uiScale: uiScale,
      fontScale: fontScale,
      invoiceColorHex: invoiceColorHex,
      invoicePaper: invoicePaper,
      saleScannerEnabled: saleScannerEnabled,
      scannerSoundEnabled: scannerSoundEnabled,
    );

    final settings = await AppDatabase.instance.getBusinessSettings();
    AppUiPreferences.instance.updateFromSettings(settings);

    if (!mounted) return;
    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات وتطبيقها على النظام'),
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final value = int.tryParse(hex, radix: 16) ?? 0x0DB28E;
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final phone = constraints.maxWidth < 700;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              phone ? 14 : 28,
              8,
              phone ? 14 : 28,
              110,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    children: [
                      _SettingsCard(
                        title: 'بيانات المنشأة',
                        subtitle: 'هوية النشاط والعملة الأساسية',
                        icon: Icons.storefront_rounded,
                        child: Column(
                          children: [
                            TextField(
                              controller: businessName,
                              decoration: const InputDecoration(
                                labelText: 'اسم المنشأة',
                                prefixIcon: Icon(Icons.business_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            phone
                                ? Column(
                                    children: [
                                      _ActivityField(
                                        value: activityType,
                                        onChanged: (value) {
                                          setState(() => activityType = value);
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _CurrencyField(
                                        value: currency,
                                        onChanged: (value) {
                                          setState(() => currency = value);
                                        },
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _ActivityField(
                                          value: activityType,
                                          onChanged: (value) {
                                            setState(
                                              () => activityType = value,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _CurrencyField(
                                          value: currency,
                                          onChanged: (value) {
                                            setState(() => currency = value);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsCard(
                        title: 'مظهر النظام',
                        subtitle:
                            'تحكم مستقل بحجم الواجهة وحجم الخط مع تطبيق مباشر',
                        icon: Icons.tune_rounded,
                        child: Column(
                          children: [
                            _ScaleSetting(
                              title: 'حجم الواجهة',
                              value: uiScale,
                              min: .88,
                              max: 1.16,
                              onChanged: (value) {
                                setState(() => uiScale = value);
                              },
                            ),
                            const Divider(height: 26),
                            _ScaleSetting(
                              title: 'حجم الخطوط',
                              value: fontScale,
                              min: .88,
                              max: 1.28,
                              onChanged: (value) {
                                setState(() => fontScale = value);
                              },
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                'معاينة: دفتري المحاسبي — فاتورة مبيعات احترافية',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsCard(
                        title: 'هوية الفاتورة والطباعة',
                        subtitle:
                            'اختيار لون الهوية ونوع الطباعة الافتراضي',
                        icon: Icons.receipt_long_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'لون هوية الفاتورة',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: invoiceColors.map((hex) {
                                final selected = invoiceColorHex == hex;
                                return InkWell(
                                  onTap: () {
                                    setState(() => invoiceColorHex = hex);
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: selected ? 50 : 42,
                                    height: selected ? 50 : 42,
                                    decoration: BoxDecoration(
                                      color: _colorFromHex(hex),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.text
                                            : Colors.white,
                                        width: selected ? 3 : 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x18000000),
                                          blurRadius: 12,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: selected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'a4',
                                  icon: Icon(Icons.description_rounded),
                                  label: Text('A4 رسمية'),
                                ),
                                ButtonSegment(
                                  value: 'thermal',
                                  icon: Icon(Icons.receipt_rounded),
                                  label: Text('حرارية 80mm'),
                                ),
                              ],
                              selected: {invoicePaper},
                              onSelectionChanged: (value) {
                                setState(() {
                                  invoicePaper = value.first;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              invoicePaper == 'a4'
                                  ? 'فاتورة كبيرة رسمية بترويسة وهوية كاملة.'
                                  : 'فاتورة طولية مبسطة مناسبة لطابعات الكاشير الحرارية.',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsCard(
                        title: 'الباركود والكاشير',
                        subtitle:
                            'إضافة الأصناف بالمسح مع تأكيد صوتي واستمرار المسح',
                        icon: Icons.qr_code_scanner_rounded,
                        child: Column(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: saleScannerEnabled,
                                onChanged: (value) {
                                  setState(
                                    () => saleScannerEnabled = value,
                                  );
                                },
                                title: const Text(
                                  'إظهار ماسح الباركود في شاشة البيع',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                subtitle: const Text(
                                  'يمكن إبقاء الماسح مفتوحًا لإضافة عدة منتجات متتالية.',
                                ),
                              ),
                            ),
                            const Divider(),
                            Material(
                              color: Colors.transparent,
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: scannerSoundEnabled,
                                onChanged: (value) {
                                  setState(
                                    () => scannerSoundEnabled = value,
                                  );
                                },
                                title: const Text(
                                  'نغمة تأكيد بعد قراءة الصنف',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                subtitle: const Text(
                                  'تشغيل صوت قصير عند نجاح إضافة المنتج للسلة.',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: FilledButton.icon(
            onPressed: saving ? null : _save,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text(
                'حفظ الإعدادات',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C123E63),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.emeraldDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ScaleSetting extends StatelessWidget {
  const _ScaleSetting({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.emeraldDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: 8,
          label: '$percent%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ActivityField extends StatelessWidget {
  const _ActivityField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'نوع النشاط',
        prefixIcon: Icon(Icons.category_rounded),
      ),
      items: const [
        DropdownMenuItem(value: 'grocery', child: Text('بقالة / تجزئة')),
        DropdownMenuItem(value: 'restaurant', child: Text('مطعم')),
        DropdownMenuItem(value: 'mixed', child: Text('مطعم وتجزئة')),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _CurrencyField extends StatelessWidget {
  const _CurrencyField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'العملة',
        prefixIcon: Icon(Icons.payments_rounded),
      ),
      items: const [
        DropdownMenuItem(value: 'YER', child: Text('الريال اليمني')),
        DropdownMenuItem(value: 'SAR', child: Text('الريال السعودي')),
        DropdownMenuItem(value: 'USD', child: Text('الدولار الأمريكي')),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
