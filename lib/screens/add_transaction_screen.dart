import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key, dynamic account});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, GoalProvider>(
      builder: (context, settings, goalProvider, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        // Get the first active goal if available, otherwise show a placeholder
        Goal? goal;
        if (goalProvider.goals.isNotEmpty) {
          goal = goalProvider.goals.first;
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            toolbarHeight: 70,
            titleSpacing: 25,
            title: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D)),
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
              IconButton(icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D)), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              }),
              const SizedBox(width: 15),
            ],
          ),
          body: goal == null 
            ? Center(child: Text('Tidak ada target aktif', style: GoogleFonts.outfit(color: textColor)))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'RINCIAN TARGET TABUNGAN',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${goal.name} - ${fmt.format(goal.targetAmount)}',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildMainProgressSection(goal, isDark, textColor),
                    const SizedBox(height: 25),
                    _buildMonthlyTargetCard(goal, isDark, textColor, cardColor, fmt),
                    const SizedBox(height: 20),
                    _buildAtomicSavingsCard(goal, isDark, textColor, fmt),
                    const SizedBox(height: 20),
                    _buildDecompositionTreeCard(goal, isDark, textColor, cardColor, fmt),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
        );
      }
    );
  }

  Widget _buildMainProgressSection(Goal goal, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${goal.progressPercent.toInt()}%',
          style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: textColor),
        ),
        Text(
          'PROGRES LOGIKA',
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: goal.progressFraction,
            minHeight: 10,
            backgroundColor: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTargetCard(Goal goal, bool isDark, Color textColor, Color cardColor, NumberFormat fmt) {
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
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 24),
                  const SizedBox(width: 12),
                  Text('Target Bulanan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF084B3E), borderRadius: BorderRadius.circular(15)),
                child: Text('${fmt.format(goal.monthlySuggestion)} / bln', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Dekomposisi bulanan standar.', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(value: goal.progressFraction, minHeight: 8, backgroundColor: isDark ? Colors.white10 : const Color(0xFFE8EEF9), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF98D8B6))),
                ),
              ),
              const SizedBox(width: 15),
              Text('${goal.daysRemaining ~/ 30} Bulan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtomicSavingsCard(Goal goal, bool isDark, Color textColor, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E3D35) : const Color(0xFFE8F0F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFCADBD9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grid_view_rounded, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 22),
              const SizedBox(width: 10),
              Text('Tabungan Atomik Harian', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D))),
            ],
          ),
          const SizedBox(height: 10),
          Text('Unit fundamental keberhasilan finansial.', style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[600])),
          const SizedBox(height: 25),
          Text(fmt.format(goal.dailySuggestion), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D))),
          Text('PER SIKLUS HARIAN', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : Colors.grey[600])),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002B1D),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Otomatisasi Logika', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDecompositionTreeCard(Goal goal, bool isDark, Color textColor, Color cardColor, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text('Visualisasi Pohon Dekomposisi', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 40),
          _buildTreeNode('TARGET UTAMA', fmt.format(goal.targetAmount), isDark, isMain: true),
          const SizedBox(height: 20),
          Container(width: 2, height: 30, color: isDark ? Colors.white10 : Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTreeNode('ATOMIK HARIAN', fmt.format(goal.dailySuggestion), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode(String label, String amount, bool isDark, {bool isMain = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isMain ? const Color(0xFF002B1D) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isMain ? Colors.transparent : (isDark ? Colors.white10 : Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: isMain ? Colors.white70 : Colors.grey)),
          const SizedBox(height: 4),
          Text(amount, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isMain ? Colors.white : (isDark ? Colors.white : const Color(0xFF002B1D)))),
        ],
      ),
    );
  }
}
