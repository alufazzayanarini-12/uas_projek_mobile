import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'dart:io';
import 'account_settings_screen.dart';
import 'security_settings_screen.dart';
import 'language_settings_screen.dart';
import 'about_app_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationEnabled = true;

  Future<void> _pickImage(SettingsProvider settings) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await settings.setProfileImage(image.path);
    }
  }

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
            toolbarHeight: 70,
            titleSpacing: 25,
            title: Row(
              children: [
                Icon(Icons.analytics_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 28),
                const SizedBox(width: 12),
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
              CircleAvatar(
                radius: 18,
                backgroundImage: settings.getProfileImageProvider(),
              ),
              const SizedBox(width: 15),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 25),
                _buildProfileHeader(settings, isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildSection(
                  title: 'Akun',
                  icon: Icons.account_circle_outlined,
                  isDark: isDark,
                  textColor: textColor,
                  cardColor: cardColor,
                  items: [
                    _buildListTile(
                      'Pengaturan Akun', 
                      textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                        );
                      },
                    ),
                    _buildListTile(
                      'Keamanan', 
                      textColor, 
                      subtitle: 'Autentikasi Dua Faktor Aktif',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
                        );
                      },
                    ),
                    _buildListTile('Metode Pembayaran', textColor),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Preferensi',
                  icon: Icons.settings_outlined,
                  isDark: isDark,
                  textColor: textColor,
                  cardColor: cardColor,
                  items: [
                    _buildSwitchTile('Notifikasi', _isNotificationEnabled, (v) => setState(() => _isNotificationEnabled = v), textColor, isDark),
                    _buildListTile(
                      'Bahasa', 
                      textColor, 
                      subtitle: 'Indonesia',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()),
                        );
                      },
                    ),
                    _buildSwitchTile('Mode Gelap', settings.isDarkMode, (v) => settings.toggleDarkMode(v), textColor, isDark),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Finansial',
                  icon: Icons.account_balance_wallet_outlined,
                  isDark: isDark,
                  textColor: textColor,
                  cardColor: cardColor,
                  items: [
                    _buildListTile('Laporan Tahunan', textColor, trailing: const Icon(Icons.description_outlined, size: 20, color: Colors.grey)),
                    _buildListTile('Ekspor Data (CSV/PDF)', textColor, trailing: const Icon(Icons.file_download_outlined, size: 20, color: Colors.grey)),
                    _buildListTile('Limit Transaksi', textColor, subtitle: 'Rp 50.000.000 / bln'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSupportSection(isDark, textColor, cardColor),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildProfileHeader(SettingsProvider settings, bool isDark, Color textColor, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(settings),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: settings.getProfileImageProvider(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[800] : const Color(0xFF002B1D), shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Arini Alufazzayan',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          Text(
            'alufazzayanayin@gmail.com',
            style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[600]),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('Anggota Premium', const Color(0xFFBDCECA), const Color(0xFF002B1D)),
              const SizedBox(width: 10),
              _buildBadge('Bergabung Jan 2023', const Color(0xFFE8EEF9), Colors.blue[900]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> items, required bool isDark, required Color textColor, required Color cardColor}) {
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
            children: [
              Icon(icon, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 22),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 15),
          ...items,
        ],
      ),
    );
  }

  Widget _buildListTile(String title, Color textColor, {String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
      subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, Color textColor, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(value: value, onChanged: onChanged, activeColor: isDark ? Colors.green : const Color(0xFF002B1D)),
      ),
    );
  }

  Widget _buildSupportSection(bool isDark, Color textColor, Color cardColor) {
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
            children: [
              Icon(Icons.help_outline, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 22),
              const SizedBox(width: 12),
              Text('Dukungan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportCard(Icons.security_outlined, 'Kebijakan Privasi', isDark),
          const SizedBox(height: 10),
          _buildSupportCard(
            Icons.info_outline, 
            'Tentang Tabunganku', 
            isDark,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(IconData icon, String label, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 24),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF002B1D))),
          ],
        ),
      ),
    );
  }


}
