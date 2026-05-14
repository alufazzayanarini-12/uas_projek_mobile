import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WholesaleDetailScreen extends StatelessWidget {
  const WholesaleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Pilih Detail Grosir',
          style: GoogleFonts.outfit(color: const Color(0xFF002B1D), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Silakan pilih kategori grosir untuk analisis pengeluaran yang lebih akurat sesuai dengan pola konsumsi Anda.',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[700], height: 1.6),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.75,
              children: [
                _buildWholesaleCard(
                  'Supermarket',
                  'Belanja bulanan di ritel modern berskala besar.',
                  Icons.shopping_cart_outlined,
                ),
                _buildWholesaleCard(
                  'Pasar Tradisional',
                  'Belanja bahan segar langsung dari pedagang lokal.',
                  Icons.storefront_outlined,
                ),
                _buildWholesaleCard(
                  'Toko Kelontong',
                  'Kebutuhan harian cepat di toko lingkungan sekitar.',
                  Icons.home_work_outlined,
                ),
                _buildWholesaleCard(
                  'Minimarket',
                  'Belanja praktis di gerai waralaba modern terdekat.',
                  Icons.store_outlined,
                ),
              ],
            ),
            const SizedBox(height: 25),
            _buildOptimizationCard(),
            const SizedBox(height: 20),
            _buildQuoteCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildSimpleBottomNav(),
    );
  }

  Widget _buildWholesaleCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0D4D3B), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 15),
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
          const SizedBox(height: 8),
          Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600], height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildOptimizationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D4D3B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimalisasi Anggaran',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kategorisasi yang tepat membantu algoritma MindMoney memberikan saran penghematan yang lebih akurat.',
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Icon(Icons.bar_chart_rounded, color: Colors.white.withOpacity(0.2), size: 80),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF002B1D), size: 36),
          const SizedBox(height: 15),
          Text(
            '"Cermat dalam memilih, cerdas dalam mengelola."',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[800], fontStyle: FontStyle.italic),
          ),
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
