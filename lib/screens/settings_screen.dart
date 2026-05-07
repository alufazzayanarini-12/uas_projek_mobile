import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengaturan', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle('PRIVASI & TAMPILAN'),
              _buildSettingCard(
                icon: Icons.visibility_off_outlined,
                title: 'Mode Privasi',
                subtitle: 'Sembunyikan saldo di halaman utama',
                trailing: Switch(
                  value: settings.isBalanceHidden,
                  onChanged: (val) => settings.toggleBalanceVisibility(),
                  activeColor: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 25),
              
              _buildSectionTitle('KEAMANAN'),
              _buildSettingCard(
                icon: Icons.lock_outline,
                title: 'Kunci Aplikasi (PIN)',
                subtitle: 'Gunakan PIN saat membuka aplikasi',
                trailing: Switch(
                  value: settings.isAppLockEnabled,
                  onChanged: (val) => settings.toggleAppLock(val),
                  activeColor: const Color(0xFF1A237E),
                ),
              ),
              _buildSettingCard(
                icon: Icons.fingerprint,
                title: 'Biometrik',
                subtitle: 'Sidik jari atau Face ID',
                trailing: Switch(
                  value: settings.isBiometricEnabled,
                  onChanged: (val) => settings.toggleBiometric(val),
                  activeColor: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 25),

              _buildSectionTitle('DATA & KATEGORI'),
              _buildSettingCard(
                icon: Icons.category_outlined,
                title: 'Manajemen Kategori',
                subtitle: 'Edit atau tambah kategori tabungan',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen())),
              ),
              _buildSettingCard(
                icon: Icons.picture_as_pdf_outlined,
                title: 'Ekspor Laporan',
                subtitle: 'Unduh riwayat dalam format PDF/Excel',
                onTap: () {},
              ),
              const SizedBox(height: 25),

              _buildSectionTitle('LAINNYA'),
              _buildSettingCard(
                icon: Icons.cloud_upload_outlined,
                title: 'Cadangkan Data (Cloud)',
                subtitle: 'Hubungkan ke Google Drive',
                onTap: () {},
              ),
              _buildSettingCard(
                icon: Icons.notifications_none,
                title: 'Pengingat Menabung',
                subtitle: 'Atur jadwal notifikasi harian/bulanan',
                onTap: () {},
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF1A237E)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
