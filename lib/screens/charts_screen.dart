import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'financial_auditor_screen.dart';
import 'settings_screen.dart';
import 'personal_savings_screen.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedPeriod = 0; // 0: Mingguan, 1: Bulanan, 2: Tahunan

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, TransactionProvider>(
      builder: (context, settings, txProvider, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final txs = txProvider.transactions;
        final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            toolbarHeight: 70,
            titleSpacing: 25,
            title: Row(
              children: [
                Text(
                  settings.translate('tabunganku'),
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : const Color(0xFF002B1D),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
            actions: [
              CircleAvatar(
                radius: 18,
                backgroundImage: settings.getProfileImageProvider(),
              ),
              const SizedBox(width: 10),
              IconButton(icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D)), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              }),
              const SizedBox(width: 15),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  settings.translate('pola_pengeluaran'),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPeriodToggle(settings, isDark),
                const SizedBox(height: 25),
                _buildDailyExpenseCard(settings, isDark, textColor, cardColor, txs),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                    _showPocketMoneyDialog(context, settings, fmt);
                  },
                  child: _buildSavingsProgressCard(settings, isDark),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildPeriodToggle(SettingsProvider settings, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFE8EEF9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleItem(0, settings.translate('mingguan'), isDark),
          _buildToggleItem(1, settings.translate('bulanan'), isDark),
          _buildToggleItem(2, settings.translate('tahunan'), isDark),
        ],
      ),
    );
  }

  Widget _buildToggleItem(int index, String label, bool isDark) {
    bool isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white24 : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? (isDark ? Colors.white : const Color(0xFF002B1D)) : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyExpenseCard(SettingsProvider settings, bool isDark, Color textColor, Color cardColor, List<TransactionModel> txs) {
    // 1. Calculate threshold based on selected period
    final now = DateTime.now();
    DateTime threshold;
    if (_selectedPeriod == 0) {
      // Mingguan (7 days)
      threshold = now.subtract(const Duration(days: 7));
    } else if (_selectedPeriod == 1) {
      // Bulanan (30 days)
      threshold = now.subtract(const Duration(days: 30));
    } else {
      // Tahunan (365 days)
      threshold = now.subtract(const Duration(days: 365));
    }

    // 2. Filter transactions for total expenses calculation within period
    final double totalExpenses = txs
        .where((t) => t.type == 'withdrawal' && !t.date.isBefore(threshold))
        .fold(0.0, (sum, t) => sum + t.amount);

    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // 3. Compute running balance points historically
    List<TransactionModel> allSortedTxs = List.from(txs)..sort((a, b) => a.date.compareTo(b.date));

    int totalSteps = _selectedPeriod == 0 ? 7 : (_selectedPeriod == 1 ? 30 : 12);
    DateTime startDate;
    if (_selectedPeriod == 0) {
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    } else if (_selectedPeriod == 1) {
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
    } else {
      startDate = DateTime(now.year, now.month - 11, 1);
    }

    double runningBalance = 0.0;
    for (var tx in allSortedTxs) {
      if (tx.date.isBefore(startDate)) {
        if (tx.type == 'deposit') {
          runningBalance += tx.amount;
        } else if (tx.type == 'withdrawal' || tx.type == 'transfer') {
          runningBalance -= tx.amount;
        }
      }
    }

    List<double> savingsPoints = [];
    List<double> pocketPoints = [];
    double accumulatedPocket = 0.0;

    if (_selectedPeriod == 2) {
      // Yearly: 12 months
      for (int i = 0; i < 12; i++) {
        DateTime monthStart = DateTime(startDate.year, startDate.month + i, 1);
        DateTime nextMonthStart = DateTime(startDate.year, startDate.month + i + 1, 1);

        for (var tx in allSortedTxs) {
          if (!tx.date.isBefore(monthStart) && tx.date.isBefore(nextMonthStart)) {
            if (tx.type == 'deposit') {
              runningBalance += tx.amount;
            } else if (tx.type == 'withdrawal' || tx.type == 'transfer') {
              runningBalance -= tx.amount;
            }
          }
        }
        accumulatedPocket += settings.dailyPocketMoney * 30;

        savingsPoints.add(runningBalance);
        pocketPoints.add(accumulatedPocket);
      }
    } else {
      // Weekly or Monthly: day-by-day
      for (int i = 0; i < totalSteps; i++) {
        DateTime dayStart = DateTime(startDate.year, startDate.month, startDate.day + i);
        DateTime nextDayStart = dayStart.add(const Duration(days: 1));

        for (var tx in allSortedTxs) {
          if (!tx.date.isBefore(dayStart) && tx.date.isBefore(nextDayStart)) {
            if (tx.type == 'deposit') {
              runningBalance += tx.amount;
            } else if (tx.type == 'withdrawal' || tx.type == 'transfer') {
              runningBalance -= tx.amount;
            }
          }
        }
        accumulatedPocket += settings.dailyPocketMoney;

        savingsPoints.add(runningBalance);
        pocketPoints.add(accumulatedPocket);
      }
    }

    if (savingsPoints.length < 2) {
      savingsPoints = [runningBalance, runningBalance];
      pocketPoints = [settings.dailyPocketMoney, settings.dailyPocketMoney];
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _selectedPeriod == 0
                      ? (settings.selectedLanguage == 'Bahasa Indonesia' ? 'Pengeluaran Mingguan' : 'Weekly Expense')
                      : _selectedPeriod == 1
                          ? (settings.selectedLanguage == 'Bahasa Indonesia' ? 'Pengeluaran Bulanan' : 'Monthly Expense')
                          : (settings.selectedLanguage == 'Bahasa Indonesia' ? 'Pengeluaran Tahunan' : 'Yearly Expense'),
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmt.format(totalExpenses), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  Text(
                    _selectedPeriod == 0
                        ? (settings.selectedLanguage == 'Bahasa Indonesia' ? 'Total 7 Hari Terakhir' : 'Total Last 7 Days')
                        : _selectedPeriod == 1
                            ? (settings.selectedLanguage == 'Bahasa Indonesia' ? 'Total 30 Hari Terakhir' : 'Total Last 30 Days')
                            : (settings.selectedLanguage == 'Bahasa Indonesia' ? 'Total 1 Tahun Terakhir' : 'Total Last 1 Year'),
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 100,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: SparklinePainter(
                  savingsData: savingsPoints,
                  pocketData: pocketPoints,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF0D9488), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                settings.selectedLanguage == 'Bahasa Indonesia' ? 'Uang Tabungan' : 'Savings',
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 20),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                settings.selectedLanguage == 'Bahasa Indonesia' ? 'Jatah Uang Saku' : 'Pocket Money',
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildSavingsProgressCard(SettingsProvider settings, bool isDark) {
    double daily = settings.dailyPocketMoney;
    double monthly = daily * 30;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2A1A) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.amber.withOpacity(0.2) : const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFFDE68A), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF92400E), size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  settings.selectedLanguage == 'Bahasa Indonesia' ? 'Uang Sakuku' : 'My Pocket Money',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            settings.selectedLanguage == 'Bahasa Indonesia' ? 'Jatah Uang Saku Harian' : 'Daily Pocket Money Allowance',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.amber[100] : const Color(0xFF92400E)),
          ),
          const SizedBox(height: 5),
          Text(
            settings.selectedLanguage == 'Bahasa Indonesia' ? 'Atur jatah uang saku' : 'Manage pocket money allowance',
            style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.amber[50] : const Color(0xFFB45309)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white, 
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: isDark ? Colors.amber.withOpacity(0.3) : const Color(0xFFFDE68A))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (settings.selectedLanguage == 'Bahasa Indonesia' ? 'Harian' : 'Daily').toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.formatCurrency(daily),
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (settings.selectedLanguage == 'Bahasa Indonesia' ? 'Estimasi Bulanan' : 'Monthly Est.').toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.formatCurrency(monthly),
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPocketMoneyDialog(BuildContext context, SettingsProvider settings, NumberFormat fmt) {
    final controller = TextEditingController(text: settings.dailyPocketMoney.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          top: 25,
          left: 25,
          right: 25,
        ),
        decoration: BoxDecoration(
          color: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
            const SizedBox(height: 25),
            Text(
              settings.translate('atur_uang_saku_harian'),
              style: GoogleFonts.outfit(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: settings.isDarkMode ? Colors.white : const Color(0xFF002B1D)
              ),
            ),
            const SizedBox(height: 8),
            Text(
              settings.translate('konfig_uang_saku_deskripsi'),
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: settings.isDarkMode ? Colors.white : const Color(0xFF002B1D)
              ),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: GoogleFonts.outfit(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF002B1D)
                ),
                labelText: settings.translate('nominal_baru'),
                labelStyle: GoogleFonts.outfit(color: const Color(0xFF0D9488)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [10000, 20000, 30000, 50000, 100000].map((val) {
                return ActionChip(
                  backgroundColor: settings.isDarkMode ? Colors.white12 : const Color(0xFFF1F4F9),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  label: Text(
                    settings.formatCurrency(val.toDouble()),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: settings.isDarkMode ? Colors.white : const Color(0xFF002B1D),
                    ),
                  ),
                  onPressed: () {
                    controller.text = val.toString();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  double amount = double.tryParse(controller.text) ?? 0.0;
                  if (amount > 0) {
                    settings.setDailyPocketMoney(amount);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(settings.translate('uang_saku_diperbarui').replaceAll('{amount}', fmt.format(amount)), style: GoogleFonts.outfit(color: Colors.white)),
                        backgroundColor: const Color(0xFF0D4D3B),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B1D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  settings.translate('simpan_uang_saku'),
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class SparklinePainter extends CustomPainter {
  final List<double> savingsData;
  final List<double> pocketData;
  final bool isDark;

  SparklinePainter({
    required this.savingsData,
    required this.pocketData,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (savingsData.length < 2) return;

    double minVal = savingsData[0];
    double maxVal = savingsData[0];
    for (var v in savingsData) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }
    for (var v in pocketData) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }
    
    double range = maxVal - minVal;
    if (range == 0) range = 1.0;

    double getY(double val) {
      double pct = (val - minVal) / range;
      return size.height - (pct * (size.height - 20) + 10);
    }

    final double stepX = size.width / (savingsData.length - 1);

    // 1. Draw Pocket Money Line (Amber)
    final pocketPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final pocketPath = Path();
    pocketPath.moveTo(0, getY(pocketData[0]));
    for (int i = 0; i < pocketData.length - 1; i++) {
      double x1 = i * stepX;
      double y1 = getY(pocketData[i]);
      double x2 = (i + 1) * stepX;
      double y2 = getY(pocketData[i + 1]);

      double cx1 = x1 + stepX / 2;
      double cy1 = y1;
      double cx2 = x1 + stepX / 2;
      double cy2 = y2;

      pocketPath.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
    }
    canvas.drawPath(pocketPath, pocketPaint);

    // 2. Draw Savings Line (Teal/Green)
    final savingsPaint = Paint()
      ..color = const Color(0xFF0D9488)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final savingsPath = Path();
    savingsPath.moveTo(0, getY(savingsData[0]));
    for (int i = 0; i < savingsData.length - 1; i++) {
      double x1 = i * stepX;
      double y1 = getY(savingsData[i]);
      double x2 = (i + 1) * stepX;
      double y2 = getY(savingsData[i + 1]);

      double cx1 = x1 + stepX / 2;
      double cy1 = y1;
      double cx2 = x1 + stepX / 2;
      double cy2 = y2;

      savingsPath.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
    }

    final fillPath = Path.from(savingsPath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D9488).withOpacity(isDark ? 0.25 : 0.12),
          const Color(0xFF0D9488).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(savingsPath, savingsPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
