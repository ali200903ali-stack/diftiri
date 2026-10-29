import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  final businessName = TextEditingController();

  String activityType = 'grocery';
  String currency = 'YER';
  bool loading = true;
  bool saving = false;

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
    final settings = await AppDatabase.instance
        .getBusinessSettings();

    if (!mounted) return;

    setState(() {
      businessName.text =
          settings.businessName;
      activityType =
          settings.activityType;
      currency = settings.currency;
      loading = false;
    });
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
    });

    await AppDatabase.instance
        .saveBusinessSettings(
      businessName: businessName.text,
      activityType: activityType,
      currency: currency,
    );

    if (!mounted) return;

    setState(() {
      saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ إعدادات المنشأة',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final phone =
              constraints.maxWidth < 600;

          return ListView(
            padding: EdgeInsets.all(
              phone ? 14 : 24,
            ),
            children: [
              Center(
                child: Container(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 620,
                  ),
                  padding: EdgeInsets.all(
                    phone ? 16 : 22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'بيانات المنشأة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: businessName,
                        decoration:
                            const InputDecoration(
                          labelText: 'اسم المنشأة',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: activityType,
                        decoration:
                            const InputDecoration(
                          labelText: 'نوع النشاط',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'grocery',
                            child: Text('بقالة'),
                          ),
                          DropdownMenuItem(
                            value: 'restaurant',
                            child: Text('مطعم'),
                          ),
                          DropdownMenuItem(
                            value: 'mixed',
                            child: Text(
                              'مطعم وبقالة',
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            activityType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: currency,
                        decoration:
                            const InputDecoration(
                          labelText: 'العملة',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'YER',
                            child: Text(
                              'الريال اليمني',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'SAR',
                            child: Text(
                              'الريال السعودي',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'USD',
                            child: Text(
                              'الدولار الأمريكي',
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            currency = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed:
                            saving ? null : _save,
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.save_rounded,
                              ),
                        label: const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Text(
                            'حفظ الإعدادات',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
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
    );
  }
}
