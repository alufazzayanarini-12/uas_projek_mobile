import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AutomationSettingsScreen extends StatefulWidget {
  const AutomationSettingsScreen({super.key});

  @override
  State<AutomationSettingsScreen> createState() => _AutomationSettingsScreenState();
}

class _AutomationSettingsScreenState extends State<AutomationSettingsScreen> {
  bool _isAutoSaveEnabled = true;
  double _dailyAmount = 20000;

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
              'Atur Otomatisasi',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                _buildToggleCard(isDark, textColor, cardColor),
                const SizedBox(height: 25),
                Text(
                  'KONFIGURASI ATOMIK',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                ),
                const SizedBox(height: 15),
                _buildAmountSlider(isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildInfoCard(isDark, textColor),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleCard(bool isDark, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bolt_outlined, color: Color(0xFF002B1D), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Protokol Simpan-Otomatis', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                Text('Simpan secara otomatis setiap hari', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: _isAutoSaveEnabled,
            onChanged: (v) => setState(() => _isAutoSaveEnabled = v),
            activeColor: const Color(0xFF002B1D),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSlider(bool isDark, Color textColor, Color cardColor) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Setoran Harian', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
              Text('Rp ${_dailyAmount.toInt()}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
            ],
          ),
          const SizedBox(height: 20),
          Slider(
            value: _dailyAmount,
            min: 5000,
            max: 100000,
            divisions: 19,
            activeColor: const Color(0xFF002B1D),
            inactiveColor: isDark ? Colors.white10 : const Color(0xFFE8F0FE),
            onChanged: (v) => setState(() => _dailyAmount = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rp 5rb', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
              Text('Rp 100rb', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D4D3B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0D4D3B).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF0D4D3B)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Otomatisasi akan memindahkan dana dari saldo utama ke target tabungan Anda setiap pukul 08:30 pagi.',
              style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF002B1D),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      child: Text('Simpan Konfigurasi', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
