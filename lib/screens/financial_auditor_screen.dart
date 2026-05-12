import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class FinancialAuditorScreen extends StatelessWidget {
  const FinancialAuditorScreen({super.key});

  final String _profileImagePath = 'C:/Users/Sipul/.gemini/antigravity/brain/2693fa1e-fb88-410b-a3ca-8813d5a1d002/arini_actual_profile_1778586287965.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        titleSpacing: 25,
        title: Row(
          children: [
            Text(
              'MindMoney',
              style: GoogleFonts.outfit(
                color: const Color(0xFF002B1D),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF002B1D)), onPressed: () {}),
          CircleAvatar(
            radius: 18,
            backgroundImage: FileImage(File(_profileImagePath)),
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
                color: const Color(0xFF002B1D),
              ),
            ),
            const SizedBox(height: 25),
            _buildCriticalWarningCard(),
            const SizedBox(height: 25),
            _buildAuditItemCard(
              icon: Icons.restaurant_rounded,
              title: 'Makan & Sosial',
              amount: 'Rp 850.000',
              limit: 'Rp 500.000',
              badge: 'Kritis',
              badgeColor: const Color(0xFFFEE2E2),
              textColor: const Color(0xFF991B1B),
            ),
            const SizedBox(height: 20),
            _buildAuditItemCard(
              icon: Icons.local_shipping_rounded,
              title: 'Transportasi & Pengiriman',
              amount: 'Rp 270.000',
              limit: 'Rp 150.000',
              badge: 'Waspada',
              badgeColor: const Color(0xFFFFEDD5),
              textColor: const Color(0xFF9A3412),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: _buildSimpleBottomNav(),
    );
  }

  Widget _buildCriticalWarningCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
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
                      style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: const Color(0xFFF1F4F9), shape: BoxShape.circle),
                child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 40), 
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kebocoran Tertinggi', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF991B1B))),
                const SizedBox(height: 4),
                Text('Makan & Sosial', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF991B1B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItemCard({
    required IconData icon,
    required String title,
    required String amount,
    required String limit,
    required String badge,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: const Color(0xFF991B1B), size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                child: Text(badge, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(amount, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFB91C1C))),
              Text(' / Batas $limit', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: const LinearProgressIndicator(
              value: 1.0, 
              minHeight: 8,
              backgroundColor: Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB91C1C)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002B1D),
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

  Widget _buildSimpleBottomNav() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home'),
          _buildNavItem(Icons.analytics_outlined, 'Insights', isActive: true),
          _buildNavItem(Icons.add_circle_outline_rounded, 'Add'),
          _buildNavItem(Icons.terminal_rounded, 'Rules'),
          _buildNavItem(Icons.person_outline_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isActive ? BoxDecoration(color: const Color(0xFFBDCECA), borderRadius: BorderRadius.circular(12)) : null,
          child: Icon(icon, color: isActive ? const Color(0xFF002B1D) : const Color(0xFF8E99AF), size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(color: isActive ? const Color(0xFF002B1D) : const Color(0xFF8E99AF), fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }
}
