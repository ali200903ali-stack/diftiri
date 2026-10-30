import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/diftiri_ui.dart';

class BanksScreen extends StatefulWidget {
  const BanksScreen({super.key});

  @override
  State<BanksScreen> createState() =>
      _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  late Future<List<BankAccountRecord>> future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    future = AppDatabase.instance.getBankAccounts();
  }

  Future<void> _addBank() async {
    final name = TextEditingController();
    final number = TextEditingController();
    final opening = TextEditingController(
      text: '0',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة حساب بنكي'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration:
                        const InputDecoration(
                      labelText: 'اسم البنك',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'رقم الحساب - اختياري',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: opening,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText: 'الرصيد الافتتاحي',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty) {
                  return;
                }

                await AppDatabase.instance
                    .addBankAccount(
                  name: name.text,
                  accountNumber: number.text,
                  openingBalance:
                      double.tryParse(
                            opening.text,
                          ) ??
                          0,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (saved == true && mounted) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DiftiriAppBar(
        title: 'البنوك',
        subtitle: 'الحسابات البنكية والأرصدة',
        icon: Icons.account_balance_rounded,
        tone: DiftiriTone.mint,
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addBank,
        icon: const Icon(Icons.add_rounded),
        label: const Text('حساب بنكي'),
      ),
      body:
          FutureBuilder<List<BankAccountRecord>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final accounts = snapshot.data!;
          if (accounts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'لا توجد حسابات بنكية. أضف أول حساب من الزر بالأسفل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              14,
              14,
              14,
              90,
            ),
            itemCount: accounts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final account = accounts[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE8F8F4),
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color:
                            AppColors.emeraldDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          Text(
                            account.accountNumber
                                    .isEmpty
                                ? 'الحساب ' +
                                    account.accountCode
                                : account
                                    .accountNumber,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        account.balance
                                .toStringAsFixed(0) +
                            ' ر.ي',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
