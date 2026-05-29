import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

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
              settings.translate('pilih_bahasa'),
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.translate('bahasa_tersedia'),
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),
                _buildLanguageCard(context, settings, 'Bahasa Indonesia', 'Default Sistem', isDark, cardColor),
                const SizedBox(height: 15),
                _buildLanguageCard(context, settings, 'English', 'United States', isDark, cardColor),
                const SizedBox(height: 15),
                _buildLanguageCard(context, settings, '日本語', 'Japan', isDark, cardColor),
                const SizedBox(height: 15),
                _buildLanguageCard(context, settings, 'العربية', 'Arabic', isDark, cardColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageCard(BuildContext context, SettingsProvider settings, String language, String region, bool isDark, Color cardColor) {
    final isSelected = settings.selectedLanguage == language;

    return GestureDetector(
      onTap: () {
        settings.setSelectedLanguage(language);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              settings.translate('bahasa_diubah_ke').replaceAll('{language}', language),
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: const Color(0xFF002B1D),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF0D9488) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  Text(region, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0D9488))
            else
              Icon(Icons.circle_outlined, color: Colors.grey.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
