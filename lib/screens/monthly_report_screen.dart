import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/account_provider.dart';
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
        bool isFoodCategory(category) {
          if (category == null) return false;
          final name = (category.name as String).toLowerCase();
          return name.contains('makan') || name.contains('food');
        }

        bool isTransportCategory(category) {
          if (category == null) return false;
          final name = (category.name as String).toLowerCase();
          return name.contains('bensin') || name.contains('fuel');
        }

        final List<TransactionModel> foodTransactions = monthlyTransactions.where((tx) {
          final category = categoryMap[tx.categoryId];
          final desc = (tx.description ?? '').toString().toLowerCase();
          return tx.type == 'withdrawal' && (isFoodCategory(category) || desc.contains('makan'));
        }).cast<TransactionModel>().toList();

        final List<TransactionModel> transportTransactions = monthlyTransactions.where((tx) {
          final category = categoryMap[tx.categoryId];
          final desc = (tx.description ?? '').toString().toLowerCase();
          return tx.type == 'withdrawal' && (isTransportCategory(category) || desc.contains('bensin'));
        }).cast<TransactionModel>().toList();

        final breakdownItems = [
          {
            'name': settings.translate('uang_makan'),
            'amount': foodTransactions.fold<double>(0, (sum, tx) => sum + tx.amount),
            'color': const Color(0xFFFB923C),
            'icon': Icons.restaurant_outlined,
            'transactions': foodTransactions,
          },
          {
            'name': settings.translate('uang_bensin'),
            'amount': transportTransactions.fold<double>(0, (sum, tx) => sum + tx.amount),
            'color': const Color(0xFF2563EB),
            'icon': Icons.local_gas_station_outlined,
            'transactions': transportTransactions,
          },
        ];

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
                                List<TransactionModel>.from(item['transactions'] as List),
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

  void _showExpenseDetail(BuildContext context, SettingsProvider settings, String categoryName, double amount, List<TransactionModel> transactions) {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedType = 'withdrawal';
    List<TransactionModel> currentTransactions = List<TransactionModel>.from(transactions);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = '';
        String sortOption = 'date_desc';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredTransactions = currentTransactions.where((tx) {
              final desc = tx.description.toLowerCase();
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

            return SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => setModalState(() => selectedType = 'withdrawal'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: selectedType == 'withdrawal' ? const Color(0xFFEF4444) : const Color(0xFFF3F4F6),
                                        foregroundColor: selectedType == 'withdrawal' ? Colors.white : Colors.black,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: const Text('Uang Keluar'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => setModalState(() => selectedType = 'deposit'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: selectedType == 'deposit' ? const Color(0xFF10B981) : const Color(0xFFF3F4F6),
                                        foregroundColor: selectedType == 'deposit' ? Colors.white : Colors.black,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: const Text('Uang Masuk'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  labelText: settings.translate('nominal'),
                                  prefixText: 'Rp ',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: noteController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  hintText: 'Catatan (opsional)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 30),
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
                                          '${tx.type == 'withdrawal' ? '- ' : '+ '}${settings.formatCurrency(tx.amount)}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            color: tx.type == 'withdrawal' ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
                                          ),
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
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                        left: 20,
                        right: 20,
                        top: 8,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                           onPressed: () async {
                            final raw = amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                            final parsedAmount = double.tryParse(raw) ?? 0.0;
                            if (parsedAmount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Masukkan nominal yang valid'), backgroundColor: Colors.red.shade700),
                              );
                              return;
                            }

                            final activeAccounts = accountProvider.accounts;
                            if (activeAccounts.isEmpty) {
                              await accountProvider.loadAccounts();
                            }
                            final currentAccount = accountProvider.accounts.isNotEmpty
                                ? accountProvider.accounts.first
                                : null;

                            if (currentAccount == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tidak ada akun yang tersedia'), backgroundColor: Colors.red.shade700),
                              );
                              return;
                            }

                            // Match Category ID
                            int? matchedCategoryId;
                            final lowerName = categoryName.toLowerCase();
                            final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                            for (var cat in categoryProvider.allCategories) {
                              final catName = cat.name.toLowerCase();
                              if ((lowerName.contains('makan') || lowerName.contains('food')) && 
                                  (catName.contains('makan') || catName.contains('food'))) {
                                matchedCategoryId = cat.id;
                                break;
                              }
                              if ((lowerName.contains('bensin') || lowerName.contains('fuel') || lowerName.contains('gas')) && 
                                  (catName.contains('bensin') || catName.contains('fuel') || catName.contains('transport'))) {
                                matchedCategoryId = cat.id;
                                break;
                              }
                            }
                            // Fallback to Uang Bulanan category if available
                            if (matchedCategoryId == null) {
                              for (var cat in categoryProvider.allCategories) {
                                if (cat.name.toLowerCase().contains('bulanan')) {
                                  matchedCategoryId = cat.id;
                                  break;
                                }
                              }
                            }

                            String finalDescription = noteController.text.trim();
                            if (finalDescription.isEmpty) {
                              finalDescription = categoryName;
                            } else {
                              final lowerDesc = finalDescription.toLowerCase();
                              if (lowerName.contains('makan') || lowerName.contains('food')) {
                                if (!lowerDesc.contains('makan') && !lowerDesc.contains('food')) {
                                  finalDescription += ' ($categoryName)';
                                }
                              } else if (lowerName.contains('bensin') || lowerName.contains('fuel') || lowerName.contains('gas')) {
                                if (!lowerDesc.contains('bensin') && !lowerDesc.contains('fuel') && !lowerDesc.contains('gas')) {
                                  finalDescription += ' ($categoryName)';
                                }
                              }
                            }

                            final newTransaction = TransactionModel(
                              accountId: currentAccount.id!,
                              categoryId: matchedCategoryId,
                              type: selectedType,
                              amount: parsedAmount,
                              description: finalDescription,
                            );

                            await txProvider.addTransaction(newTransaction);
                            categoryProvider.processTransaction(categoryName, selectedType, parsedAmount);

                            setModalState(() {
                              currentTransactions.insert(0, newTransaction);
                              amountController.clear();
                              noteController.clear();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(selectedType == 'withdrawal'
                                    ? 'Uang keluar berhasil ditambahkan'
                                    : 'Uang masuk berhasil ditambahkan'),
                                backgroundColor: selectedType == 'withdrawal' ? Colors.red.shade700 : Colors.green.shade700,
                              ),
                            );
                          },
                          icon: const Icon(Icons.save, size: 20),
                          label: Text(settings.translate('simpan_transaksi')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
