import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class CoffeeSnackDetailScreen extends StatelessWidget {
  const CoffeeSnackDetailScreen({super.key});

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
              'Pilih Detail Kopi & Snack',
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
            ),
            const SizedBox(height: 12),
            Text(
              'Kelola pengeluaran harian Anda dengan presisi sistematis.',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.85,
              children: [
                _buildDetailCard('Kedai Kopi', 'Kafe & Barista', Icons.coffee_maker_outlined, const Color(0xFF0D4D3B)),
                _buildDetailCard('Toko Roti', 'Bakery & Pastry', Icons.bakery_dining_outlined, const Color(0xFFE8F0FE)),
                _buildDetailCard('Jajanan Pasar', 'Camilan Tradisional', Icons.cookie_outlined, const Color(0xFFE8F0FE)),
                _buildDetailCard('Es Krim', '& Dessert Manis', Icons.icecream_outlined, const Color(0xFFFDE8E8)),
              ],
            ),
            const SizedBox(height: 25),
            _buildStructureAnalysisCard(),
            const SizedBox(height: 20),
            _buildInspirationCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildSimpleBottomNav(),
    );
  }

  Widget _buildDetailCard(String title, String subtitle, IconData icon, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg == const Color(0xFF0D4D3B) ? iconBg : iconBg.withOpacity(0.5), shape: BoxShape.circle),
            child: Icon(icon, color: iconBg == const Color(0xFF0D4D3B) ? Colors.white : const Color(0xFF002B1D), size: 28),
          ),
          const SizedBox(height: 15),
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
          Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStructureAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analisis Struktur', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Logika pengelompokan kategori', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Icon(Icons.bar_chart, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 25),
          _buildAnalysisRow('Optimasi Anggaran', 0.8),
          const SizedBox(height: 15),
          _buildAnalysisRow('Segmentasi Data', 0.5),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, double value) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[800]))),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: const Color(0xFFF1F4F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D4D3B)),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInspirationCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1511920170033-f8396924c348?q=80&w=1000&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INSPIRASI HARIAN', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2)),
            const SizedBox(height: 5),
            Text('Kelola kesenangan kecil Anda.', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
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
