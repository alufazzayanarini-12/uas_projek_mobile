import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _dailyReminder = true;
  bool _budgetWarning = true;
  bool _autoSaveConfirm = false;
  bool _promoInfo = true;

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
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Notifikasi',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(25),
            children: [
              _buildSectionTitle('PENGINGAT TRANSAKSI'),
              _buildSwitchCard(
                'Pengingat Harian',
                'Ingatkan untuk mencatat pengeluaran setiap jam 20:00',
                _dailyReminder,
                (v) => setState(() => _dailyReminder = v),
                isDark, textColor, cardColor,
              ),
              const SizedBox(height: 15),
              _buildSwitchCard(
                'Peringatan Anggaran',
                'Notifikasi jika pengeluaran melebihi 80% batas',
                _budgetWarning,
                (v) => setState(() => _budgetWarning = v),
                isDark, textColor, cardColor,
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('OTOMATISASI'),
              _buildSwitchCard(
                'Konfirmasi Auto-Save',
                'Minta izin sebelum memindahkan saldo otomatis',
                _autoSaveConfirm,
                (v) => setState(() => _autoSaveConfirm = v),
                isDark, textColor, cardColor,
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('INFORMASI'),
              _buildSwitchCard(
                'Promo & Edukasi',
                'Tips menabung dan penawaran menarik lainnya',
                _promoInfo,
                (v) => setState(() => _promoInfo = v),
                isDark, textColor, cardColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildSwitchCard(String title, String subtitle, bool value, Function(bool) onChanged, bool isDark, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: ListTile(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF002B1D),
        ),
      ),
    );
  }
}
