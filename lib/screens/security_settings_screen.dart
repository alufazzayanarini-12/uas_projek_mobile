import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

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
              'Kata Sandi & Keamanan',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(25),
            children: [
              _buildSecurityTile(
                Icons.lock_reset_rounded,
                'Ubah PIN Transaksi',
                'Terakhir diubah 3 bulan lalu',
                isDark,
                textColor,
                cardColor,
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                Icons.fingerprint_rounded,
                'Biometrik',
                'Gunakan Sidik Jari untuk masuk',
                settings.isBiometricEnabled,
                (v) => settings.toggleBiometric(v),
                isDark,
                textColor,
                cardColor,
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                Icons.security_update_good_rounded,
                'Kunci Aplikasi',
                'Kunci aplikasi saat tidak aktif',
                settings.isAppLockEnabled,
                (v) => settings.toggleAppLock(v),
                isDark,
                textColor,
                cardColor,
              ),
              const SizedBox(height: 40),
              Text(
                'PERANGKAT TERHUBUNG',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
              ),
              const SizedBox(height: 15),
              _buildDeviceTile('Xiaomi 12 Pro', 'Aktif sekarang', true, isDark, cardColor),
              const SizedBox(height: 10),
              _buildDeviceTile('MacBook Air M2', 'Terakhir aktif 2 jam lalu', false, isDark, cardColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityTile(IconData icon, String title, String subtitle, bool isDark, Color textColor, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF002B1D)),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged, bool isDark, Color textColor, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF002B1D)),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF002B1D),
        ),
      ),
    );
  }

  Widget _buildDeviceTile(String name, String status, bool isActive, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(Icons.devices_rounded, color: isActive ? Colors.green : Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                Text(status, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (!isActive) Text('Hapus', style: GoogleFonts.outfit(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
