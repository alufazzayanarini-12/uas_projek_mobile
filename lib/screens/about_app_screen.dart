import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final primaryColor = const Color(0xFF002B1D);

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
              settings.translate('tentang_aplikasi'),
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // App Logo with Glowing Gradient Background
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF002B1D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      size: 65,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  settings.translate('tabunganku'),
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Versi Aplikasi 2.1.0',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Description Card
                Container(
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
                        '${settings.translate('tentang_aplikasi')} ${settings.translate('tabunganku')}',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tabunganku adalah asisten manajemen keuangan pribadi cerdas Anda yang dirancang untuk membantu melacak pengeluaran harian, menabung secara disiplin, dan menganalisis kesehatan anggaran (Financial Audit) dengan antarmuka yang sangat indah dan intuitif.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Key Features Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'FITUR UNGGULAN APLIKASI',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                _buildFeatureTile(
                  Icons.auto_awesome,
                  'Audit Kesehatan Keuangan',
                  'Saran cerdas kalkulasi skor kesehatan tabungan Anda.',
                  isDark,
                  cardColor,
                ),
                const SizedBox(height: 12),
                _buildFeatureTile(
                  Icons.savings_outlined,
                  'Alokasi Tabungan Kustom',
                  'Simpan dana pendidikan, dana darurat, dan target bulanan.',
                  isDark,
                  cardColor,
                ),
                const SizedBox(height: 12),
                _buildFeatureTile(
                  Icons.security_outlined,
                  'Privasi & Proteksi PIN',
                  'Keamanan berlapis menjaga kerahasiaan keuangan Anda.',
                  isDark,
                  cardColor,
                ),
                
                const SizedBox(height: 35),
                
                // Developer Info
                Text(
                  'Dikembangkan oleh:',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  'Arini Alufazzayan',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Footer Copyright
                Text(
                  'Hak Cipta © 2026 Tabunganku.\nSemua Hak Dilindungi.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF002B1D).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0D9488),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF002B1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
