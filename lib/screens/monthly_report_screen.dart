import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import 'settings_screen.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final txProvider = Provider.of<TransactionProvider>(context, listen: false);
      if (txProvider.transactions.isEmpty && !txProvider.isLoading) {
        txProvider.loadTransactions();
      }
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + delta, 1);
    });
  }

  Future<void> _pickMonthYear(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SettingsProvider, CategoryProvider, TransactionProvider>(
      builder: (context, settings, categoryProvider, transactionProvider, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);

        // Format currency helper
        final fmt = NumberFormat.currency(locale: settings.locale.toString(), symbol: 'Rp ', decimalDigits: 0);
        final currentMonthLabel = DateFormat('MMMM yyyy', settings.locale.toString()).format(selectedMonth);

        final monthlyTransactions = transactionProvider.transactions.where((tx) {
          return tx.date.year == selectedMonth.year && tx.date.month == selectedMonth.month;
        }).toList();

        final incomeTotal = monthlyTransactions
            .where((tx) => tx.type == 'deposit')
            .fold<double>(0, (sum, tx) => sum + tx.amount);
        final expenseTotal = monthlyTransactions
            .where((tx) => tx.type == 'withdrawal')
            .fold<double>(0, (sum, tx) => sum + tx.amount);

        final categoryMap = {for (var cat in categoryProvider.allCategories) cat.id: cat};
        final breakdown = <int, double>{};
        for (final tx in monthlyTransactions.where((tx) => tx.type == 'withdrawal')) {
          final key = tx.categoryId ?? 0;
          breakdown[key] = (breakdown[key] ?? 0) + tx.amount;
        }

        final breakdownItems = breakdown.entries.map((entry) {
          final category = categoryMap[entry.key];
          return {
            'name': category?.name ?? 'Lain-lain',
            'amount': entry.value,
            'color': category != null ? Color(category.colorValue) : const Color(0xFF8B5CF6),
            'icon': category != null ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons') : Icons.more_horiz_rounded,
            'categoryId': entry.key,
          };
        }).toList()
          ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

        double totalSisaSaldo = categoryProvider.savingsCurrent +
            categoryProvider.emergencyCurrent +
            categoryProvider.educationCurrent;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              settings.translate('laporan_bulanan'),
              style: GoogleFonts.outfit(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined, color: textColor),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Month Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: textColor),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickMonthYear(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentMonthLabel,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.keyboard_arrow_down, color: textColor),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: textColor),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 2. Summary Overview Cards
                Text(
                  settings.translate('laporan_keuangan'),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 15),

                // Income & Expenses Cards Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F5132), Color(0xFF198754)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
                            const SizedBox(height: 15),
                            Text(
                              settings.translate('pemasukan'),
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settings.formatCurrency(incomeTotal),
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF842029), Color(0xFFDC3545)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 24),
                            const SizedBox(height: 15),
                            Text(
                              settings.translate('pengeluaran'),
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settings.formatCurrency(expenseTotal),
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Net Balance Card (Full Width - Linked dynamically to all savings)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F4EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF0F5132), size: 26),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.translate('sisa_saldo_bersih'),
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.formatCurrency(totalSisaSaldo),
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F5132),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // 3. Expense Breakdown Graph Mock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      settings.translate('rincian_pengeluaran'),
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${settings.translate('total_label')}: ${settings.formatCurrency(expenseTotal)}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                  ),
                  child: Column(
                    children: [
                      if (breakdownItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Tidak ada pengeluaran untuk bulan ini',
                              style: GoogleFonts.outfit(color: Colors.grey[500]),
                            ),
                          ),
                        )
                      else ...breakdownItems.map((item) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => _showExpenseDetail(
                                context,
                                settings,
                                item['name'] as String,
                                item['amount'] as double,
                                monthlyTransactions.where((tx) => tx.categoryId == item['categoryId']).toList(),
                              ),
                              child: _buildBreakdownItem(
                                context,
                                settings,
                                item['name'] as String,
                                item['amount'] as double,
                                expenseTotal > 0 ? expenseTotal : 1,
                                item['color'] as Color,
                                item['icon'] as IconData,
                                isDark,
                              ),
                            ),
                            const Divider(height: 30),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 4. Smart Insights card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2215) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 26),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.translate('analisis_bulanan'),
                              style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              settings.translate('analisis_bulanan_deskripsi').replaceAll('{balance}', settings.formatCurrency(totalSisaSaldo)),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // 5. Download Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(settings.translate('laporan_berhasil_unduh').replaceAll('{month}', currentMonthLabel)),
                          backgroundColor: const Color(0xFF0F5132),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: Text(
                      settings.translate('unduh_laporan_pdf'),
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002B1D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakdownItem(
    BuildContext context,
    SettingsProvider settings,
    String title,
    double spent,
    double total,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    double ratio = total > 0 ? (spent / total) : 0.0;
    int percentage = (ratio * 100).round();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    settings.formatCurrency(spent),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                settings.translate('persentase_pengeluaran').replaceAll('{percentage}', percentage.toString()),
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExpenseDetail(BuildContext context, SettingsProvider settings, String categoryName, double amount, List<dynamic> transactions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = '';
        String sortOption = 'date_desc';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredTransactions = transactions.where((tx) {
              final desc = (tx.description ?? '').toString().toLowerCase();
              return desc.contains(searchQuery.toLowerCase());
            }).toList();

            if (sortOption == 'date_asc') {
              filteredTransactions.sort((a, b) => a.date.compareTo(b.date));
            } else if (sortOption == 'date_desc') {
              filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
            } else if (sortOption == 'amount_asc') {
              filteredTransactions.sort((a, b) => a.amount.compareTo(b.amount));
            } else if (sortOption == 'amount_desc') {
              filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
            }

            final transactionCount = filteredTransactions.length;
            final averageAmount = transactionCount > 0
                ? filteredTransactions.fold<double>(0, (prev, tx) => prev + tx.amount) / transactionCount
                : 0.0;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 25,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    categoryName,
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${settings.translate('total_label')}: ${settings.formatCurrency(amount)}',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$transactionCount ${settings.translate('transaksi')}',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[700]),
                      ),
                      Text(
                        '${settings.translate('rata_rata')}: ${settings.formatCurrency(averageAmount)}',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: settings.translate('cari_transaksi'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
                      suffixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) => setModalState(() {
                      searchQuery = value;
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${settings.translate('urutkan')}:',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: DropdownButton<String>(
                            value: sortOption,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: [
                              DropdownMenuItem(value: 'date_desc', child: Text(settings.translate('terbaru_terlebih_dulu'))),
                              DropdownMenuItem(value: 'date_asc', child: Text(settings.translate('terlama_terlebih_dulu'))),
                              DropdownMenuItem(value: 'amount_desc', child: Text(settings.translate('nominal_terbesar'))),
                              DropdownMenuItem(value: 'amount_asc', child: Text(settings.translate('nominal_terkecil'))),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setModalState(() {
                                  sortOption = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (filteredTransactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(settings.translate('tidak_ada_transaksi'), style: GoogleFonts.outfit(color: Colors.grey[500])),
                      ),
                    )
                  else
                    ...filteredTransactions.map((tx) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.description,
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              settings.formatCurrency(tx.amount),
                              style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFFEF4444)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM yyyy', settings.locale.toString()).format(tx.date),
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
