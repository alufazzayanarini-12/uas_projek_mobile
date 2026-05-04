import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'pin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Keamanan & Privasi'),
              _buildSettingCard(
                title: 'Kunci Aplikasi (PIN)',
                subtitle: settings.isPinEnabled ? 'PIN Aktif' : 'Atur PIN sekarang',
                icon: Icons.lock_outline,
                color: Colors.blue,
                trailing: Switch(
                  value: settings.isPinEnabled,
                  onChanged: (val) {
                    if (val) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetup: true)));
                    } else {
                      // Logic to disable PIN could be added here
                    }
                  },
                ),
              ),
              _buildSettingCard(
                title: 'Mode Privasi',
                subtitle: 'Sembunyikan saldo di beranda',
                icon: Icons.visibility_off_outlined,
                color: Colors.purple,
                trailing: Switch(
                  value: settings.isBalanceHidden,
                  onChanged: (val) => settings.toggleBalanceVisibility(),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Data & Laporan'),
              _buildSettingCard(
                title: 'Manajemen Kategori',
                subtitle: 'Atur kategori tabungan kamu',
                icon: Icons.category_outlined,
                color: Colors.orange,
                onTap: () {
                  // TODO: Category Management
                },
              ),
              _buildSettingCard(
                title: 'Ekspor Riwayat',
                subtitle: 'Unduh laporan PDF / Excel',
                icon: Icons.file_download_outlined,
                color: Colors.green,
                onTap: () {
                  // TODO: Export Data
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Lainnya'),
              _buildSettingCard(
                title: 'Notifikasi Pengingat',
                subtitle: 'Atur jadwal menabung harian',
                icon: Icons.notifications_active_outlined,
                color: Colors.redAccent,
                onTap: () {
                  // TODO: Notifications
                },
              ),
              _buildSettingCard(
                title: 'Cadangkan ke Cloud',
                subtitle: 'Backup data ke Google Drive',
                icon: Icons.cloud_upload_outlined,
                color: Colors.lightBlue,
                onTap: () {
                  // TODO: Backup Cloud
                },
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text('Versi 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
