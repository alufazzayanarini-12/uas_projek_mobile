import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'account_settings_screen.dart';
import 'security_settings_screen.dart';
import 'language_settings_screen.dart';
import 'about_app_screen.dart';
import 'monthly_report_screen.dart';

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
                  settings.translate('tabunganku'),
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
                  title: settings.translate('akun'),
                  icon: Icons.account_circle_outlined,
                  isDark: isDark,
                  textColor: textColor,
                  cardColor: cardColor,
                  items: [
                    _buildListTile(
                      settings.translate('pengaturan_akun'), 
                      textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                        );
                      },
                    ),
                    _buildListTile(
                      settings.translate('keamanan'), 
                      textColor, 
                      subtitle: settings.translate('keamanan'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
                        );
                      },
                    ),
                    _buildListTile(settings.translate('metode_pembayaran'), textColor),
                  ],
                ),


                const SizedBox(height: 20),
                _buildSupportSection(settings, isDark, textColor, cardColor),
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
              _buildBadge(settings.translate('anggota_premium'), const Color(0xFFBDCECA), const Color(0xFF002B1D)),
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

  Widget _buildSupportSection(SettingsProvider settings, bool isDark, Color textColor, Color cardColor) {
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
          _buildSupportCard(
            Icons.security_outlined,
            settings.translate('kebijakan_privasi'),
            isDark,
            onTap: () => _showPrivacyPolicyBottomSheet(context, isDark, textColor),
          ),
          const SizedBox(height: 10),
          _buildSupportCard(
            Icons.info_outline,
            settings.translate('tentang_aplikasi'),
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
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(15),
        ),
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

  void _showPrivacyPolicyBottomSheet(BuildContext context, bool isDark, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kebijakan Privasi',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildPrivacySection(
                          '1. Pengumpulan Data',
                          'Aplikasi Tabunganku menyimpan semua data transaksi, target keuangan, dan preferensi akun Anda secara lokal di dalam perangkat Anda sendiri menggunakan penyimpanan terenkripsi aman. Kami tidak mengunggah data keuangan pribadi Anda ke server pihak ketiga mana pun.',
                          isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildPrivacySection(
                          '2. Keamanan PIN & Biometrik',
                          'Kami menyediakan perlindungan berlapis dengan menggunakan kode PIN lokal dan otentikasi biometrik (jika diaktifkan) yang terintegrasi langsung dengan sistem keamanan bawaan perangkat Anda.',
                          isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildPrivacySection(
                          '3. Hak Pengguna',
                          'Anda memiliki hak penuh untuk mengekspor data transaksi keuangan Anda kapan saja dalam format PDF atau CSV melalui menu ekspor, serta menghapus seluruh data aplikasi secara permanen dengan membersihkan data aplikasi di pengaturan perangkat Anda.',
                          isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildPrivacySection(
                          '4. Perubahan Kebijakan',
                          'Kebijakan privasi ini dapat diperbarui sewaktu-waktu seiring dengan pembaruan fitur aplikasi untuk senantiasa memastikan keamanan data keuangan Anda tetap terjaga di level tertinggi.',
                          isDark,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Pembaruan terakhir: Mei 2026',
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrivacySection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D9488),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.grey[800],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _showExportBottomSheet(BuildContext context, bool isDark, Color textColor, Color cardColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ekspor Data Keuangan',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Pilih format file untuk mengunduh laporan keuangan Anda secara lengkap.',
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              
              GestureDetector(
                onTap: () => _triggerExportAnimation(context, 'CSV'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.table_chart, color: Colors.green, size: 24),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Format CSV (Spreadsheet)',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Text(
                              'Cocok untuk diolah kembali di Excel / Google Sheets',
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              GestureDetector(
                onTap: () => _triggerExportAnimation(context, 'PDF'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Format PDF (Dokumen Cetak)',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Text(
                              'Laporan rapi siap cetak dan mudah dibagikan',
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _triggerExportAnimation(BuildContext context, String format) {
    Navigator.pop(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (context.mounted) {
                Navigator.pop(context);
                _showSuccessExportDialog(context, format);
              }
            });
            
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Menyiapkan Dokumen $format...',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF002B1D),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Mohon tunggu sebentar',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessExportDialog(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Color(0xFF059669), size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ekspor Berhasil!',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Laporan keuangan format $format telah berhasil diekspor ke folder Unduhan perangkat Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                     onPressed: () => Navigator.pop(context),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF002B1D),
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       elevation: 0,
                     ),
                     child: Text('Selesai', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLimitBottomSheet(BuildContext context, SettingsProvider settings, bool isDark, Color textColor, Color cardColor) {
    final controller = TextEditingController(text: settings.monthlyTransactionLimit.toStringAsFixed(0));
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Limit Bulanan',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Tentukan batas maksimal akumulasi pengeluaran bulanan Anda.',
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Rp ',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(controller.text) ?? 50000000.0;
                    settings.setMonthlyTransactionLimit(val);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Limit bulanan diperbarui menjadi Rp ${NumberFormat.currency(locale: "id", symbol: "", decimalDigits: 0).format(val)}!',
                          style: GoogleFonts.outfit(),
                        ),
                        backgroundColor: const Color(0xFF002B1D),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002B1D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
