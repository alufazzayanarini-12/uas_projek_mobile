import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class CurrencySettingsScreen extends StatelessWidget {
  const CurrencySettingsScreen({super.key});

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
              'Pilih Mata Uang',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MATA UANG POPULER',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),
                _buildCurrencyCard('Rupiah Indonesia', 'IDR (Rp)', true, isDark, cardColor),
                const SizedBox(height: 15),
                _buildCurrencyCard('US Dollar', 'USD (\$)', false, isDark, cardColor),
                const SizedBox(height: 15),
                _buildCurrencyCard('Euro', 'EUR (€)', false, isDark, cardColor),
                const SizedBox(height: 15),
                _buildCurrencyCard('Japanese Yen', 'JPY (¥)', false, isDark, cardColor),
                const SizedBox(height: 15),
                _buildCurrencyCard('Saudi Riyal', 'SAR (﷼)', false, isDark, cardColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyCard(String name, String symbol, bool isSelected, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF002B1D) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04))),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(15)),
            alignment: Alignment.center,
            child: Text(symbol.split(' ').last.replaceAll('(', '').replaceAll(')', ''), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF002B1D))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                Text(symbol, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: Color(0xFF002B1D))
          else
            Icon(Icons.circle_outlined, color: Colors.grey.withOpacity(0.3)),
        ],
      ),
    );
  }
}
