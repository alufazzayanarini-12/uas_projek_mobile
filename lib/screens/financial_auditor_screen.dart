import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'settings_screen.dart';
import 'fix_logic_screen.dart';
import 'dart:io';

class FinancialAuditorScreen extends StatelessWidget {
  const FinancialAuditorScreen({super.key});

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
                Text(
                  'Daily Savings',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : const Color(0xFF002B1D),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D)), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              }),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Text(
                  'Auditor Finansial',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 25),
                _buildCriticalWarningCard(isDark, textColor, cardColor),
                const SizedBox(height: 25),
                _buildAuditItemCard(
                  context: context,
                  icon: Icons.restaurant_rounded,
                  title: 'Makan & Sosial',
                  amount: 'Rp 850.000',
                  limit: 'Rp 500.000',
                  badge: 'Kritis',
                  badgeColor: const Color(0xFFFEE2E2),
                  textColor: const Color(0xFF991B1B),
                  cardColor: isDark ? const Color(0xFF2D1A1A) : const Color(0xFFFFF8F8),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                _buildAuditItemCard(
                  context: context,
                  icon: Icons.local_shipping_rounded,
                  title: 'Transportasi & Pengiriman',
                  amount: 'Rp 270.000',
                  limit: 'Rp 150.000',
                  badge: 'Waspada',
                  badgeColor: const Color(0xFFFFEDD5),
                  textColor: const Color(0xFF9A3412),
                  cardColor: isDark ? const Color(0xFF2D251A) : const Color(0xFFFFF8F8),
                  isDark: isDark,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          bottomNavigationBar: _buildSimpleBottomNav(isDark),
        );
      }
    );
  }

  Widget _buildCriticalWarningCard(bool isDark, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.power_settings_new_rounded, color: Color(0xFFB91C1C), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'PERINGATAN KRITIS',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFB91C1C), letterSpacing: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rp 1.240.50',
                      style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: isDark ? Colors.white10 : const Color(0xFFF1F4F9), shape: BoxShape.circle),
                child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 40), 
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF311010) : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFFECDD3).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kebocoran Tertinggi', style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.red[200] : const Color(0xFF991B1B))),
                const SizedBox(height: 4),
                Text('Makan & Sosial', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.red[200] : const Color(0xFF991B1B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItemCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String amount,
    required String limit,
    required String badge,
    required Color badgeColor,
    required Color textColor,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isDark ? Colors.red.withOpacity(0.1) : const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: isDark ? Colors.red[300] : const Color(0xFF991B1B), size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: isDark ? textColor.withOpacity(0.2) : badgeColor, borderRadius: BorderRadius.circular(8)),
                child: Text(badge, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : textColor)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D))),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(amount, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.red[300] : const Color(0xFFB91C1C))),
              Text(' / Batas $limit', style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: 1.0, 
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.red[400]! : const Color(0xFFB91C1C)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FixLogicScreen(
                category: title,
                currentAmount: amount,
                currentLimit: limit,
              )));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.green[800] : const Color(0xFF002B1D),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text('Perbaiki Logika', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBottomNav(bool isDark) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 'Beranda', isDark),
          _buildNavItem(Icons.analytics_outlined, 'Wawasan', isDark, isActive: true),
          _buildNavItem(Icons.add_circle_outline_rounded, 'Tambah', isDark),
          _buildNavItem(Icons.terminal_rounded, 'Aturan', isDark),
          _buildNavItem(Icons.person_outline_rounded, 'Profil', isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isDark, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isActive ? BoxDecoration(color: isDark ? Colors.green.withOpacity(0.2) : const Color(0xFFBDCECA), borderRadius: BorderRadius.circular(12)) : null,
          child: Icon(icon, color: isActive ? (isDark ? Colors.green[400] : const Color(0xFF002B1D)) : const Color(0xFF8E99AF), size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(color: isActive ? (isDark ? Colors.green[400] : const Color(0xFF002B1D)) : const Color(0xFF8E99AF), fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }
}
