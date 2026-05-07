import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 10),
              
              // ── SEKSI PRIVASI & TAMPILAN ──
              _buildSectionTitle('Privasi & Tampilan'),
              _buildSettingTile(
                icon: Icons.visibility_off_outlined,
                title: 'Mode Privasi',
                subtitle: 'Sembunyikan saldo di halaman utama',
                trailing: Switch(
                  value: settings.isBalanceHidden,
                  onChanged: (val) => settings.toggleBalanceVisibility(),
                  activeColor: Colors.black,
                ),
              ),
              
              const SizedBox(height: 25),
              
              // ── SEKSI KEAMANAN ──
              _buildSectionTitle('Keamanan'),
              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'Kunci Aplikasi (PIN)',
                subtitle: 'Gunakan PIN saat membuka aplikasi',
                trailing: Switch(
                  value: settings.isAppLockEnabled,
                  onChanged: (val) => settings.toggleAppLock(val),
                  activeColor: Colors.black,
                ),
              ),
              _buildSettingTile(
                icon: Icons.fingerprint,
                title: 'Biometrik',
                subtitle: 'Sidik jari atau Face ID',
                trailing: Switch(
                  value: settings.isBiometricEnabled,
                  onChanged: (val) => settings.toggleBiometric(val),
                  activeColor: Colors.black,
                ),
              ),
              
              const SizedBox(height: 25),
              
              // ── SEKSI DATA & KATEGORI ──
              _buildSectionTitle('Data & Kategori'),
              _buildSettingTile(
                icon: Icons.category_outlined,
                title: 'Manajemen Kategori',
                subtitle: 'Edit atau tambah kategori tabungan',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen())),
              ),
              _buildSettingTile(
                icon: Icons.picture_as_pdf_outlined,
                title: 'Ekspor Laporan',
                subtitle: 'Unduh riwayat dalam format PDF/Excel',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Ekspor akan segera hadir!')));
                },
              ),
              
              const SizedBox(height: 25),
              
              // ── SEKSI LAINNYA ──
              _buildSectionTitle('Lainnya'),
              _buildSettingTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Cadangkan Data (Cloud)',
                subtitle: 'Hubungkan ke Google Drive',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.notifications_none_outlined,
                title: 'Pengingat Menabung',
                subtitle: 'Atur jadwal notifikasi harian/bulanan',
                onTap: () {},
              ),
              
              const SizedBox(height: 40),
              const Center(
                child: Text('Versi 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }
}
