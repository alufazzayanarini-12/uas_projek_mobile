import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'goal_detail_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAutoSaveEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
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
                Icon(Icons.analytics_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Daily Savings',
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
              IconButton(
                icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 28),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              ),
              const SizedBox(width: 15),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                _buildTotalBalanceCard(isDark),
                const SizedBox(height: 25),
                _buildAutoSaveProtocol(isDark),
                const SizedBox(height: 30),
                Text(
                  'Target Aktif',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalDetailScreen(
                          goalId: 1, // Fallback ID
                        ))),
                        child: _buildGoalProgressCard('Laptop Baru', 0.75, 'Rp 11.250.000', isDark),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalDetailScreen(
                          goalId: 2, // Fallback ID
                        ))),
                        child: _buildGoalProgressCard('Books NW', 0.45, 'Rp 3.600.000', isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _buildEmergencyFundCard(45000000, 50000000, 0.92, fmt, isDark),
                const SizedBox(height: 25),
                _buildGrowthAnalysisCard(isDark),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalBalanceCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF002B1D),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF002B1D).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL SALDO BERSIH', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Icon(Icons.info_outline, color: Colors.white54, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text('Rp 12.500.000', style: GoogleFonts.outfit(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildBalanceSubItem('Pemasukan', '+ Rp 18M'),
              Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 25)),
              _buildBalanceSubItem('Dialokasikan', '- Rp 5.5M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSubItem(String label, String amount) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          const SizedBox(height: 5),
          Text(amount, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildAutoSaveProtocol(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.code_rounded, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 26)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Protokol Simpan-Otomatis', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF002B1D))), const SizedBox(height: 4), Text('Pembulatan & aturan berbasis logika', style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.grey[600], fontSize: 14))])),
          Switch(value: _isAutoSaveEnabled, onChanged: (val) => setState(() => _isAutoSaveEnabled = val), activeColor: isDark ? Colors.green : const Color(0xFF002B1D)),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(String title, double progress, String amount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF002B1D))),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F4F9), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)), minHeight: 6),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amount, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyFundCard(double current, double target, double progress, NumberFormat fmt, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Dana Darurat', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: isDark ? Colors.white : const Color(0xFF002B1D))), Text('Jaring Pengaman Finansial', style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.grey[600], fontSize: 14))]),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 28, color: isDark ? Colors.white : const Color(0xFF002B1D))),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: progress, backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F4F9), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF98D8B6)), minHeight: 10),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(fmt.format(current), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), Text('Target: ${fmt.format(target)}', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12))]),
        ],
      ),
    );
  }

  Widget _buildGrowthAnalysisCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isDark ? [const Color(0xFF1E1E1E), const Color(0xFF2D2D2D)] : [const Color(0xFFF1F4F9), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Colors.black.withOpacity(0.08), borderRadius: BorderRadius.circular(20)), child: Text('Analisis Pertumbuhan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black))),
          const SizedBox(height: 20),
          Text('Efisiensi Modal naik 12%', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D))),
          const SizedBox(height: 20),
          Row(children: [Text('Lihat Laporan Detail', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.green[200] : const Color(0xFF002B1D))), const SizedBox(width: 12), Icon(Icons.arrow_forward, size: 20, color: isDark ? Colors.green[200] : const Color(0xFF002B1D))]),
        ],
      ),
    );
  }
}
