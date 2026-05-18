import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import 'settings_screen.dart';
import 'fix_logic_screen.dart';

class FinancialAuditorScreen extends StatelessWidget {
  const FinancialAuditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, CategoryProvider>(
      builder: (context, settings, categoryProvider, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);

        // Format currency helper
        final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
        String totalSavedFormatted = fmt.format(categoryProvider.savingsCurrent);

        // Calculate progress ratio
        double savingsProgress = categoryProvider.savingsTarget > 0 
            ? (categoryProvider.savingsCurrent / categoryProvider.savingsTarget) 
            : 0.0;
        if (savingsProgress > 1.0) savingsProgress = 1.0;

        // Dynamic status based on savings target progress
        double percent = savingsProgress * 100;
        String statusTabungan = 'Perlu Ditingkatkan';
        Color statusColor = const Color(0xFFEF4444);
        if (percent >= 80) {
          statusTabungan = 'Sangat Sehat';
          statusColor = const Color(0xFF10B981);
        } else if (percent >= 50) {
          statusTabungan = 'Sehat';
          statusColor = const Color(0xFF3B82F6);
        } else if (percent >= 25) {
          statusTabungan = 'Waspada';
          statusColor = const Color(0xFFF59E0B);
        }

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Financial Audit',
              style: GoogleFonts.outfit(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline, color: textColor),
                onPressed: () {
                  // Show quick explanation snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Halaman ini mengevaluasi kesehatan finansial berdasarkan tabungan Rp ${fmt.format(categoryProvider.savingsTarget)} Anda.'),
                      backgroundColor: const Color(0xFF0B3A2E),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Skor Kesehatan Keuangan (Financial Health Score Card - Linked to real savings)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: 4.2,
                              child: CircularProgressIndicator(
                                value: savingsProgress,
                                strokeWidth: 3.5,
                                color: const Color(0xFF0B3A2E),
                                backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    totalSavedFormatted,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: totalSavedFormatted.length > 12 ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TOTAL MENABUNG',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Skor Kesehatan Keuangan',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusTabungan,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 2. Kebocoran Anggaran Card
                GestureDetector(
                  onTap: () => _showEditPocketMoneyBottomSheet(context, settings),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Kebocoran Anggaran',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.edit_rounded, size: 12, color: Colors.grey[500]),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp 120.000',
                              style: GoogleFonts.outfit(
                                  fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF2F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.money_off_rounded, color: Color(0xFFEF4444), size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 3. Efisiensi & Skor Kredit Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Efisiensi',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '92%',
                              style: GoogleFonts.outfit(
                                  fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 12),
                            const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 22),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skor Kredit',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '780',
                              style: GoogleFonts.outfit(
                                  fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 12),
                            const Icon(Icons.credit_card_rounded, color: Color(0xFF3B82F6), size: 22),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // 4. Rekomendasi Cerdas Section
                Text(
                  'Rekomendasi Cerdas',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3A2E), 
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.white, size: 28),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                          children: const [
                            TextSpan(text: 'Pindahkan '),
                            TextSpan(text: 'Rp 500.000 ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                            TextSpan(text: 'ke Tabungan Berjangka untuk bunga lebih tinggi.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              title: Text(
                                'Tabungan Berjangka',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tabungan Berjangka adalah produk simpanan berjangka waktu tertentu dengan penawaran suku bunga yang lebih tinggi daripada tabungan reguler.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Keunggulan:',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• Bunga tinggi hingga 5.5% per tahun.\n• Melatih disiplin rutin menabung.\n• Simpanan aman & terjamin.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Mengerti',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0B3A2E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pelajari Selengkapnya',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          bottomNavigationBar: _buildSimpleBottomNav(isDark),
        );
      },
    );
  }

  void _showEditPocketMoneyBottomSheet(BuildContext context, SettingsProvider settings) {
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
            const SizedBox(height: 25),
            Text(
              'Ubah Uang Saku Harian',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan nominal uang saku harian baru Anda.',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
                labelText: 'Nominal Baru',
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
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  double? newAmount = double.tryParse(controller.text);
                  if (newAmount != null) {
                    settings.setDailyPocketMoney(newAmount);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B1D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  'SIMPAN PERUBAHAN',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBottomNav(bool isDark) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 'Beranda', isDark),
          _buildNavItem(Icons.analytics_outlined, 'Wawasan', isDark, isActive: true),
          _buildNavItem(Icons.add_circle_outline_rounded, 'Tambah', isDark),
          _buildNavItem(Icons.description_rounded, 'Laporan', isDark),
          _buildNavItem(Icons.person_outline_rounded, 'Profil', isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isDark, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isActive ? BoxDecoration(color: isDark ? Colors.green.withOpacity(0.2) : const Color(0xFFBDCECA), borderRadius: BorderRadius.circular(12)) : null,
          child: Icon(icon, color: isActive ? (isDark ? Colors.green[400] : const Color(0xFF002B1D)) : const Color(0xFF8E99AF), size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(color: isActive ? (isDark ? Colors.green[400] : const Color(0xFF002B1D)) : const Color(0xFF8E99AF), fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }
}
