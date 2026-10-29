import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({
    super.key,
    required this.type,
    required this.title,
  });

  final String type;
  final String title;

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  late Future<List<PartyRecord>> future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    future = AppDatabase.instance.getParties(widget.type);
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final phone = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          widget.type == 'customer'
              ? 'إضافة عميل'
              : 'إضافة مورد',
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'الهاتف'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;

              await AppDatabase.instance.addParty(
                type: widget.type,
                name: name.text,
                phone: phone.text,
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (saved == true) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('إضافة'),
      ),
      body: FutureBuilder<List<PartyRecord>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snapshot.data!;
          if (rows.isEmpty) {
            return Center(
              child: Text('لا يوجد ' + widget.title + ' حتى الآن'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final row = rows[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(
                    row.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    row.phone.isEmpty
                        ? 'بدون رقم هاتف'
                        : row.phone,
                  ),
                  trailing: Text(
                    'رصيد ' + row.balance.toStringAsFixed(0),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
