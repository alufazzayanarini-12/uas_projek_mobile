import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import 'edit_goal_screen.dart';
import 'settings_screen.dart';
import 'automation_settings_screen.dart';
import 'package:intl/intl.dart';

class GoalDetailScreen extends StatelessWidget {
  final int goalId;

  const GoalDetailScreen({
    super.key,
    required this.goalId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, GoalProvider>(
      builder: (context, settings, goalProvider, child) {
        final goalIndex = goalProvider.goals.indexWhere((g) => g.id == goalId);
        
        if (goalIndex == -1) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Target tidak ditemukan'),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  )
                ],
              ),
            ),
          );
        }

        final goal = goalProvider.goals[goalIndex];
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FE),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              goal.name,
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            actions: [
              IconButton(icon: Icon(Icons.settings_outlined, color: textColor), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              }),
              const SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeaderCard(goal, isDark, textColor, cardColor, currencyFormat),
                const SizedBox(height: 25),
                _buildDecompositionTree(goal, isDark, textColor, cardColor, currencyFormat),
                const SizedBox(height: 25),
                _buildSavingsSummary(goal, isDark, textColor, cardColor, currencyFormat),
                const SizedBox(height: 25),
                _buildSettingsSection(context, goal, isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildRecentTransactions(context, goal, isDark, textColor, cardColor, currencyFormat),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(Goal goal, bool isDark, Color textColor, Color cardColor, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(16)),
                child: Icon(IconData(goal.icon, fontFamily: 'MaterialIcons'), color: const Color(0xFF002B1D), size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sisa untuk menabung', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
                    Text(fmt.format(goal.remainingAmount), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${goal.progressPercent.toInt()}%',
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text(
                    'PROGRES',
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: goal.progressFraction,
              minHeight: 12,
              backgroundColor: isDark ? Colors.white10 : const Color(0xFFE8F0FE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecompositionTree(Goal goal, bool isDark, Color textColor, Color cardColor, NumberFormat fmt) {
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
          Text(
            'Visualisasi Pohon Dekomposisi',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 30),
          _buildTreeNode('TARGET UTAMA', fmt.format(goal.targetAmount), isDark, isMain: true),
          const SizedBox(height: 20),
          Container(width: 2, height: 30, color: isDark ? Colors.white10 : Colors.grey[300]),
          _buildTreeNode('ATOMIK HARIAN', fmt.format(goal.dailySuggestion), isDark, isAtomic: true),
        ],
      ),
    );
  }

  Widget _buildTreeNode(String label, String value, bool isDark, {bool isMain = false, bool isAtomic = false}) {
    Color bgColor = isMain ? const Color(0xFFE0E5E2) : (isAtomic ? const Color(0xFF002B1D) : Colors.white);
    Color valColor = isMain ? const Color(0xFF002B1D) : (isAtomic ? Colors.white : const Color(0xFF002B1D));
    Color labColor = isMain ? Colors.grey[700]! : (isAtomic ? Colors.white70 : Colors.grey);

    if (isDark && !isMain && !isAtomic) {
      bgColor = Colors.white10;
      valColor = Colors.white;
    }

    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: labColor)),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: valColor)),
        ],
      ),
    );
  }

  Widget _buildSavingsSummary(Goal goal, bool isDark, Color textColor, Color cardColor, NumberFormat fmt) {
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
          Text(
            'Ringkasan Tabungan',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(Icons.account_balance_wallet_outlined, 'Telah Ditabung', fmt.format(goal.currentAmount), isDark),
          const SizedBox(height: 15),
          _buildSummaryRow(Icons.flag_outlined, 'Target Pencapaian', DateFormat('MMMM yyyy', 'id_ID').format(goal.deadline), isDark),
          const SizedBox(height: 15),
          _buildSummaryRow(Icons.trending_up_outlined, 'Performa Menabung', 'Sangat Baik', isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, Goal goal, bool isDark, Color textColor, Color cardColor) {
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
          Text(
            'Pengaturan',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 15),
          _buildSettingItem(Icons.edit_outlined, 'Ubah Target', isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditGoalScreen(
              goal: goal,
            )));
          }),
          _buildSettingItem(Icons.refresh_outlined, 'Atur Otomatisasi', isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AutomationSettingsScreen()));
          }),
          _buildSettingItem(Icons.pause_circle_outline, 'Jeda Menabung', isDark, isWarning: true, onTap: () => _showPauseDialog(context, isDark)),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label, bool isDark, {bool isWarning = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isWarning ? Colors.red[300] : (isDark ? Colors.white70 : Colors.grey[700])),
      title: Text(label, style: GoogleFonts.outfit(fontSize: 16, color: isWarning ? Colors.red[300] : (isDark ? Colors.white : Colors.black))),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildRecentTransactions(BuildContext context, Goal goal, bool isDark, Color textColor, Color cardColor, NumberFormat fmt) {
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
              Text(
                'Riwayat Tabungan',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              Text('Lihat Semua', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF002B1D), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          _buildTransactionRow('Hari ini', 'Auto-save harian', fmt.format(goal.dailySuggestion), isDark, fmt),
          _buildTransactionRow('Kemarin', 'Top up manual', 'Rp 150.000', isDark, fmt, isManual: true),
          _buildTransactionRow('12 Mei', 'Auto-save harian', fmt.format(goal.dailySuggestion), isDark, fmt),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String date, String desc, String amount, bool isDark, NumberFormat fmt, {bool isManual = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isManual ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Icon(isManual ? Icons.add_circle_outline : Icons.refresh, size: 16, color: isManual ? Colors.blue[800] : Colors.grey[700]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D))),
                Text(date, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(amount, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0D9488))),
        ],
      ),
    );
  }

  void _showPauseDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFFFF1F2), shape: BoxShape.circle),
              child: const Icon(Icons.pause_circle_filled, color: Color(0xFFB91C1C), size: 40),
            ),
            const SizedBox(height: 25),
            Text('Jeda Menabung?', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 10),
            Text(
              'Otomatisasi akan dihentikan sementara. Anda bisa melanjutkannya kapan saja.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB91C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('Jeda Sekarang', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
