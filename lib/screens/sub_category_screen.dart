import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'warung_detail_screen.dart';

class SubCategoryScreen extends StatefulWidget {
  final String mainCategory;
  const SubCategoryScreen({super.key, required this.mainCategory});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  String _selectedSub = 'Restoran';

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
          'Pilih Sub-Kategori',
          style: GoogleFonts.outfit(color: const Color(0xFF002B1D), fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE8F0FE), shape: BoxShape.circle),
            child: const Icon(Icons.search, color: Color(0xFF002B1D), size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 30),
            _buildMainCategoryHeader(),
            const SizedBox(height: 20),
            _buildSubGrid(),
            const SizedBox(height: 35),
            _buildOtherRecommendations(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari sub-kategori...',
          hintStyle: GoogleFonts.outfit(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.restaurant, color: Color(0xFF002B1D), size: 24),
          const SizedBox(width: 12),
          Text(
            'Makanan & Minuman',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Kategori Utama',
              style: GoogleFonts.outfit(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _buildSubCard('Restoran', Icons.storefront_outlined),
        _buildSubCard('Grosir', Icons.shopping_cart_outlined),
        _buildSubCard('Kopi & Snack', Icons.coffee_outlined),
        _buildSubCard('Warung', Icons.restaurant_menu_outlined),
      ],
    );
  }

  Widget _buildSubCard(String title, IconData icon) {
    bool isSelected = _selectedSub == title;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSub = title);
        if (title == 'Restoran' || title == 'Warung') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WarungDetailScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB9F2D3) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? const Color(0xFF002B1D) : Colors.black.withOpacity(0.04), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.transparent : const Color(0xFFF1F4F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF002B1D), size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF002B1D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Rekomendasi Lainnya',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ),
        const SizedBox(height: 15),
        _buildRecommendItem('Bahan Bakar', 'Transportasi', Icons.local_gas_station_outlined),
        _buildRecommendItem('Pakaian', 'Shopping', Icons.checkroom_outlined),
      ],
    );
  }

  Widget _buildRecommendItem(String title, String category, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF002B1D), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(category, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: Text('Konfirmasi Sub-Kategori', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF002B1D),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
    );
  }
}
