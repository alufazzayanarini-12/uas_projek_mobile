import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class WarungDetailScreen extends StatelessWidget {
  const WarungDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002B1D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily Savings',
          style: GoogleFonts.outfit(color: const Color(0xFF002B1D), fontWeight: FontWeight.bold),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Text(
              'Pilih Detail Warung',
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
            ),
            const SizedBox(height: 12),
            Text(
              'Kategorikan jenis usaha Anda untuk analisis keuangan yang lebih presisi sesuai pola operasional.',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 30),
            _buildWarungCard(
              'Nasi Rames',
              '',
              Icons.restaurant_outlined,
            ),
            _buildWarungCard(
              'Soto Ayam/Daging',
              'Menu: Soto Lamongan, Soto Madura, Soto Betawi, atau Coto Makassar.',
              Icons.soup_kitchen_outlined,
            ),
            _buildWarungCard(
              'Mie Goreng/Rebus',
              'Menu: Mie Instan Polos, Mie Telur, Indomie Double, atau Mie Nyemek.',
              Icons.ramen_dining_outlined,
            ),
            _buildWarungCard(
              'Gorengan',
              'Menu: Bakwan, Tempe Mendoan, Tahu Isi, Pisang Goreng, atau Cireng.',
              Icons.bakery_dining_outlined,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildSimpleBottomNav(),
    );
  }

  Widget _buildWarungCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0D4D3B), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600], height: 1.4)),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildSimpleBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.grid_view_rounded, 'Dashboard', false),
          _buildNavItem(Icons.receipt_long_rounded, 'Activity', true),
          _buildNavItem(Icons.track_changes_rounded, 'Goals', false),
          _buildNavItem(Icons.settings_outlined, 'Settings', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF0D4D3B) : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: isActive ? const Color(0xFF0D4D3B) : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
