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
                  'Tabunganku',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : const Color(0xFF002B1D),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(icon: Icon(Icons.search, color: isDark ? Colors.white : const Color(0xFF002B1D)), onPressed: () {}),
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
                  'Pola Pengeluaran',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPeriodToggle(isDark),
                const SizedBox(height: 25),
                _buildDailyExpenseCard(isDark, textColor, cardColor, txs),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalSavingsScreen()),
                    );
                  },
                  child: _buildSavingsProgressCard(isDark),
                ),
                const SizedBox(height: 20),
                _buildForecastCard(isDark),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildPeriodToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFE8EEF9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleItem(0, 'Mingguan', isDark),
          _buildToggleItem(1, 'Bulanan', isDark),
          _buildToggleItem(2, 'Tahunan', isDark),
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

  Widget _buildDailyExpenseCard(bool isDark, Color textColor, Color cardColor, List<TransactionModel> txs) {
    final double totalExpenses = txs
        .where((t) => t.type == 'withdrawal')
        .fold(0.0, (sum, t) => sum + t.amount);

    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    List<double> points = [];
    double current = 100000.0;
    points.add(current);

    List<TransactionModel> sortedTxs = List.from(txs)..sort((a, b) => a.date.compareTo(b.date));
    for (var tx in sortedTxs) {
      if (tx.type == 'deposit') {
        current += tx.amount;
      } else {
        current -= tx.amount;
      }
      points.add(current);
    }

    if (points.length < 3) {
      points = [100000.0, 150000.0, 120000.0, 200000.0, 180000.0, 250000.0, 220000.0, 300000.0];
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
            children: [
              Text('Pengeluaran harian', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmt.format(totalExpenses), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  Text('Total aliran-logika', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: SparklinePainter(points, isDark: isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSavingsProgressCard(bool isDark) {
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
                child: Text('Tren Signifikan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF92400E))),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text('Sisa Tabungan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.amber[100] : const Color(0xFF92400E))),
          const SizedBox(height: 5),
          Text('Tabungan Anda sehat. Capai 65% dari target bulanan.', style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.amber[50] : const Color(0xFFB45309))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white, 
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: isDark ? Colors.amber.withOpacity(0.3) : const Color(0xFFFDE68A))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TARGET TABUNGAN', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.amber[100] : const Color(0xFF92400E))),
                    Text('65%', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.amber[100] : const Color(0xFF92400E))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: 0.65, 
                    minHeight: 6, 
                    backgroundColor: isDark ? Colors.white10 : const Color(0xFFFEF3C7), 
                    valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.amber : const Color(0xFF92400E))
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF002B1D),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Uang Saku', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          Text('Kelola alokasi dan pengeluaran uang saku bulanan Anda.', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 20),
          Text('Rp 12.450.000', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialAuditorScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB7E4C7),
              foregroundColor: const Color(0xFF002B1D),
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text('Atur Uang Saku', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final bool isDark;

  SparklinePainter(this.data, {required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFF0D9488)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);
    
    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    if (range == 0) range = 1.0;

    double getY(double val) {
      double pct = (val - minVal) / range;
      return size.height - (pct * (size.height - 20) + 10);
    }

    path.moveTo(0, getY(data[0]));

    for (int i = 0; i < data.length - 1; i++) {
      double x1 = i * stepX;
      double y1 = getY(data[i]);
      double x2 = (i + 1) * stepX;
      double y2 = getY(data[i + 1]);

      double cx1 = x1 + stepX / 2;
      double cy1 = y1;
      double cx2 = x1 + stepX / 2;
      double cy2 = y2;

      path.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D9488).withOpacity(isDark ? 0.3 : 0.15),
          const Color(0xFF0D9488).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
