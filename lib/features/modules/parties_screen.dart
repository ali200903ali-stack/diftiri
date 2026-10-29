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
  final searchController = TextEditingController();
  late Future<List<PartyRecord>> future;

  String query = '';
  String filter = 'all';

  bool get isCustomer => widget.type == 'customer';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _reload() {
    future = AppDatabase.instance.getParties(widget.type);
  }

  List<PartyRecord> _applyFilters(
    List<PartyRecord> source,
  ) {
    final normalized = query.trim();

    return source.where((party) {
      final matchesQuery = normalized.isEmpty ||
          party.name.contains(normalized) ||
          party.phone.contains(normalized);

      final matchesFilter = switch (filter) {
        'balance' => party.balance > 0,
        'clear' => party.balance <= 0,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<void> _openEditor({
    PartyRecord? party,
  }) async {
    final name = TextEditingController(
      text: party?.name ?? '',
    );
    final phone = TextEditingController(
      text: party?.phone ?? '',
    );
    final opening = TextEditingController(text: '0');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              18,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius:
                          BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          party == null
                              ? (isCustomer
                                  ? 'إضافة عميل'
                                  : 'إضافة مورد')
                              : (isCustomer
                                  ? 'تحرير العميل'
                                  : 'تحرير المورد'),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(
                        isCustomer
                            ? Icons.person_rounded
                            : Icons.local_shipping_rounded,
                        color: AppColors.emeraldDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    decoration:
                        const InputDecoration(
                      labelText: 'الاسم',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phone,
                    keyboardType:
                        TextInputType.phone,
                    decoration:
                        const InputDecoration(
                      labelText: 'رقم الجوال',
                    ),
                  ),
                  if (party == null) ...[
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
                        labelText:
                            'الرصيد الافتتاحي',
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (name.text
                            .trim()
                            .isEmpty) {
                          return;
                        }

                        if (party == null) {
                          await AppDatabase.instance
                              .addParty(
                            type: widget.type,
                            name: name.text,
                            phone: phone.text,
                            openingBalance:
                                double.tryParse(
                                      opening.text,
                                    ) ??
                                    0,
                          );
                        } else {
                          await AppDatabase.instance
                              .updateParty(
                            id: party.id,
                            name: name.text,
                            phone: phone.text,
                          );
                        }

                        if (sheetContext.mounted) {
                          Navigator.pop(
                            sheetContext,
                            true,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.save_rounded,
                      ),
                      label: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Text(
                          party == null
                              ? 'إضافة'
                              : 'حفظ التعديلات',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (saved == true && mounted) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addLabel =
        isCustomer ? 'إضافة عميل' : 'إضافة مورد';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: addLabel,
            onPressed: () => _openEditor(),
            icon: const Icon(
              Icons.add_circle_rounded,
              color: AppColors.emeraldDark,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(addLabel),
      ),
      body: FutureBuilder<List<PartyRecord>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final all = snapshot.data!;
          final visible = _applyFilters(all);
          final balanceCount = all
              .where((party) => party.balance > 0)
              .length;
          final balanceTotal = all.fold<double>(
            0,
            (sum, party) =>
                sum +
                (party.balance > 0
                    ? party.balance
                    : 0),
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  0,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                  decoration:
                      const InputDecoration(
                    hintText:
                        'ابحث بالاسم أو الجوال',
                    prefixIcon:
                        Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    _PartyFilter(
                      label: 'الكل',
                      value: 'all',
                      current: filter,
                      onTap: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                    ),
                    _PartyFilter(
                      label: 'عليه رصيد',
                      value: 'balance',
                      current: filter,
                      onTap: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                    ),
                    _PartyFilter(
                      label: 'مسدد',
                      value: 'clear',
                      current: filter,
                      onTap: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _PartyStatCard(
                        label: isCustomer
                            ? 'إجمالي العملاء'
                            : 'إجمالي الموردين',
                        value: all.length.toString(),
                        icon: isCustomer
                            ? Icons.groups_rounded
                            : Icons
                                .local_shipping_rounded,
                        alert: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PartyStatCard(
                        label: 'عليهم رصيد',
                        value:
                            balanceCount.toString(),
                        subtitle:
                            balanceTotal.toStringAsFixed(
                                  0,
                                ) +
                                ' ر.ي',
                        icon:
                            Icons.schedule_rounded,
                        alert: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text(
                          'لا يوجد ' +
                              widget.title +
                              ' مطابقون',
                          style: const TextStyle(
                            color:
                                AppColors.muted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        key: const Key(
                          'parties-list',
                        ),
                        padding:
                            const EdgeInsets.fromLTRB(
                          14,
                          0,
                          14,
                          90,
                        ),
                        itemCount:
                            visible.length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          height: 9,
                        ),
                        itemBuilder:
                            (context, index) {
                          final party =
                              visible[index];
                          return _PartyCard(
                            party: party,
                            onTap: () =>
                                _openEditor(
                              party: party,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PartyFilter extends StatelessWidget {
  const _PartyFilter({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(
        end: 8,
      ),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(value),
        selectedColor: AppColors.navy,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? AppColors.navy
              : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : AppColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PartyStatCard extends StatelessWidget {
  const _PartyStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.alert,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final fg = alert
        ? Colors.red.shade700
        : AppColors.emeraldDark;
    final bg = alert
        ? const Color(0xFFFFECEC)
        : const Color(0xFFE8F8F4);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                if (subtitle != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                        Alignment.centerRight,
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        color: fg,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.party,
    required this.onTap,
  });

  final PartyRecord party;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasBalance = party.balance > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 27,
                backgroundColor:
                    Color(0xFFEAF3FA),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.navy,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    Text(
                      party.phone.isEmpty
                          ? 'بدون رقم هاتف'
                          : party.phone,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'الرصيد: ',
                          style: TextStyle(
                            color:
                                AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            party.balance
                                    .toStringAsFixed(
                                  0,
                                ) +
                                ' ر.ي',
                            style: TextStyle(
                              color: hasBalance
                                  ? Colors
                                      .red.shade700
                                  : AppColors
                                      .emeraldDark,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: hasBalance
                      ? const Color(
                          0xFFFFE8E8,
                        )
                      : const Color(
                          0xFFE3F8F1,
                        ),
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Text(
                  hasBalance
                      ? 'عليه رصيد'
                      : 'مسدد',
                  style: TextStyle(
                    color: hasBalance
                        ? Colors.red.shade700
                        : AppColors
                            .emeraldDark,
                    fontWeight:
                        FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
