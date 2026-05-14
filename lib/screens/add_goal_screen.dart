import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Tabungan';
  DateTime _selectedDate = DateTime(2025, 12, 1);

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002B1D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Target Baru',
          style: GoogleFonts.outfit(color: const Color(0xFF002B1D), fontWeight: FontWeight.bold, fontSize: 22),
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
            _buildMainFormCard(cardColor, textColor),
            const SizedBox(height: 20),
            _buildProjectionCard(cardColor, textColor),
            const SizedBox(height: 20),
            _buildEstimationCard(cardColor, textColor),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildMainFormCard(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nama Target', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          TextField(
            controller: _nameController,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Contoh: Beli Laptop Baru',
              hintStyle: GoogleFonts.outfit(color: Colors.grey.withOpacity(0.5)),
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
          const SizedBox(height: 25),
          Text('Nominal Target (Rp)', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: 'Rp  ',
              prefixStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
              hintText: '0',
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
          const SizedBox(height: 25),
          Text('Kategori Target', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCategoryChip('Tabungan', Icons.account_balance_wallet_outlined),
              _buildCategoryChip('Investasi', Icons.trending_up),
              _buildCategoryChip('Pembelian', Icons.shopping_cart_outlined),
              _buildCategoryChip('Darurat', Icons.ac_unit),
            ],
          ),
          const SizedBox(height: 25),
          Text('Target Waktu', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('--------- yyyy').format(_selectedDate).replaceAll(RegExp(r'[a-zA-Z]'), '-'), // Placeholder style from image
                  style: GoogleFonts.outfit(fontSize: 18, letterSpacing: 2, color: Colors.grey),
                ),
              ),
              const Icon(Icons.calendar_month_outlined, color: Colors.grey),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF002B1D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF002B1D) : Colors.black.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionCard(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF002B1D), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Proyeksi Bulanan', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  Text('Rp 2.500.000', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: const LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Color(0xFFE8F0FE),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 15),
          Text('Berdasarkan target 12 bulan.', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEstimationCard(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimasi Selesai', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Text('Desember 2025', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
              Text('Dalam 18 Bulan', style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF10B981), fontWeight: FontWeight.w500)),
            ],
          ),
          const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 30),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: Text('Simpan Target', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF002B1D),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
      ),
    );
  }
}
