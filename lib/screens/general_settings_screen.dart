import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'account_settings_screen.dart';
import 'security_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'bank_management_screen.dart';
import 'language_settings_screen.dart';
import 'currency_settings_screen.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

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
              'Pengaturan Umum',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('AKUN & KEAMANAN', isDark),
                const SizedBox(height: 15),
                _buildSettingsCard(cardColor, [
                  _buildSettingsItem(context, Icons.person_outline, 'Informasi Pribadi', 'Nama, Email, Telepon', isDark, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsScreen()));
                  }),
                  _buildSettingsItem(context, Icons.lock_outline, 'Kata Sandi & Keamanan', 'PIN, Sidik Jari', isDark, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()));
                  }),
                  _buildSettingsItem(context, Icons.account_balance_outlined, 'Manajemen Rekening', '2 Rekening Terhubung', isDark, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BankManagementScreen()));
                  }),
                ], isDark),
                const SizedBox(height: 30),
                _buildSectionHeader('PREFERENSI APLIKASI', isDark),
                const SizedBox(height: 15),
                _buildSettingsCard(cardColor, [
                  _buildSettingsItem(context, Icons.notifications_none_outlined, 'Notifikasi', 'Pengingat Harian Aktif', isDark, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
                  }),
                  _buildSettingsItem(context, Icons.language_outlined, 'Bahasa', 'Bahasa Indonesia', isDark, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()));
                  }),
                  _buildSettingsItem(context, Icons.monetization_on_outlined, 'Mata Uang', 'IDR (Rp)', isDark, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrencySettingsScreen()));
                  }),
                  _buildThemeSwitch(settings, isDark),
                ], isDark),
                const SizedBox(height: 30),
                _buildSectionHeader('LAINNYA', isDark),
                const SizedBox(height: 15),
                _buildSettingsCard(cardColor, [
                  _buildSettingsItem(Icons.help_outline, 'Pusat Bantuan', 'FAQ & Kontak Dukungan', isDark),
                  _buildSettingsItem(Icons.info_outline, 'Tentang Aplikasi', 'Versi 2.1.0', isDark),
                ], isDark),
                const SizedBox(height: 40),
                _buildLogoutButton(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  Widget _buildSettingsCard(Color cardColor, List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String subtitle, bool isDark, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: isDark ? Colors.white70 : const Color(0xFF002B1D), size: 22),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildThemeSwitch(SettingsProvider settings, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
        child: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: isDark ? Colors.amber[400] : const Color(0xFF002B1D), size: 22),
      ),
      title: Text('Mode Gelap', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
      subtitle: Text(isDark ? 'Tema Gelap Aktif' : 'Tema Terang Aktif', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      trailing: Switch(
        value: isDark,
        onChanged: (v) => settings.toggleDarkMode(v),
        activeColor: const Color(0xFF002B1D),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text(
          'Keluar dari Akun',
          style: GoogleFonts.outfit(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
