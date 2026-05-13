import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalTitle;
  final String targetAmount;
  final String currentAmount;
  final String remainingAmount;
  final double progress;
  final IconData icon;

  const GoalDetailScreen({
    super.key,
    required this.goalTitle,
    required this.targetAmount,
    required this.currentAmount,
    required this.remainingAmount,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

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
              'Daily Savings',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            actions: [
              IconButton(icon: Icon(Icons.settings_outlined, color: textColor), onPressed: () {}),
              const SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeaderCard(isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildDecompositionTree(isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildSavingsSummary(isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildSettingsSection(context, isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildRecentTransactions(context, isDark, textColor, cardColor),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(bool isDark, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF002B1D),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goalTitle,
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      'Target: $targetAmount',
                      style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
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
              value: progress,
              minHeight: 12,
              backgroundColor: isDark ? Colors.white10 : const Color(0xFFE8F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(currentAmount, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor)),
              Text('Sisa $remainingAmount', style: GoogleFonts.outfit(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecompositionTree(bool isDark, Color textColor, Color cardColor) {
    return Container(
      width: double.infinity,
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
            'Pohon Dekomposisi',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                _buildTreeNode('TARGET UTAMA', goalTitle, isDark, isMain: true),
                const SizedBox(height: 15),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildTreeNode('BULANAN', 'Rp 625.000', isDark),
                const SizedBox(height: 15),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildTreeNode('ATOMIK', 'Rp 20.000 / day', isDark, isAtomic: true),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: labColor)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: valColor)),
        ],
      ),
    );
  }

  Widget _buildSavingsSummary(bool isDark, Color textColor, Color cardColor) {
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
          _buildSummaryRow(Icons.calendar_month_outlined, 'Target Bulanan', 'Rp 625.000 /bln', isDark),
          const SizedBox(height: 15),
          _buildSummaryRow(Icons.bolt_outlined, 'Atomic Daily', 'Rp 20.000 /hari', isDark),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text('Estimasi Tercapai:', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 5),
          Text('6 Bulan Lagi (Januari 2025)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF002B1D), size: 20),
        ),
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

  Widget _buildSettingsSection(BuildContext context, bool isDark, Color textColor, Color cardColor) {
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
              currentTitle: goalTitle,
              currentAmount: targetAmount,
            )));
          }),
          _buildSettingItem(Icons.refresh_outlined, 'Atur Otomatisasi', isDark),
          _buildSettingItem(Icons.pause_circle_outline, 'Jeda Menabung', isDark, isWarning: true),
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

  Widget _buildRecentTransactions(BuildContext context, bool isDark, Color textColor, Color cardColor) {
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
                'Transaksi Terkini',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              Text('Lihat Semua', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TANGGAL', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('KETERANGAN', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('JUMLAH', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(width: 30),
            ],
          ),
          const Divider(),
          _buildTransactionRow('Hari ini, 08:30', 'Atomic Daily Deposit', '+Rp 20.000', isDark),
          _buildTransactionRow('Kemarin, 08:30', 'Atomic Daily Deposit', '+Rp 20.000', isDark),
          _buildTransactionRow('20 Oct 2024', 'Atomic Daily Deposit', '+Rp 20.000', isDark),
          _buildTransactionRow('19 Oct 2024', 'Top-up Manual', '+Rp 500.000', isDark, isManual: true),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String date, String desc, String amount, bool isDark, {bool isManual = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(date, style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: isManual ? Colors.teal : Colors.black, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(desc, style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Text(amount, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFBDCECA), borderRadius: BorderRadius.circular(4)),
            child: const Text('BER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF002B1D))),
          ),
        ],
      ),
    );
  }
}
