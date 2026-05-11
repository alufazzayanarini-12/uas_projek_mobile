import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key, dynamic account});

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
            const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF002B1D)),
            const SizedBox(width: 12),
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
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=man_mindmoney'),
          ),
          const SizedBox(width: 10),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF002B1D)), onPressed: () {}),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'RINCIAN TARGET TABUNGAN',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Laptop Baru - Rp 15.000.000',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002B1D),
              ),
            ),
            const SizedBox(height: 30),
            _buildMainProgressSection(),
            const SizedBox(height: 25),
            _buildMonthlyTargetCard(),
            const SizedBox(height: 20),
            _buildAtomicSavingsCard(),
            const SizedBox(height: 20),
            _buildDecompositionTreeCard(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildMainProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '75%',
          style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
        ),
        Text(
          'PROGRES LOGIKA',
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 0.75,
            minHeight: 10,
            backgroundColor: Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTargetCard() {
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
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Color(0xFF002B1D), size: 24),
                  const SizedBox(width: 12),
                  Text('Target Bulanan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF084B3E), borderRadius: BorderRadius.circular(15)),
                child: Text('Rp 625.000 / mo', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Dekomposisi bulanan standar.', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: const LinearProgressIndicator(value: 0.45, minHeight: 8, backgroundColor: Color(0xFFE8EEF9), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF98D8B6))),
                ),
              ),
              const SizedBox(width: 15),
              Text('24 Bulan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtomicSavingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCADBD9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.grid_view_rounded, color: Color(0xFF002B1D), size: 22),
              const SizedBox(width: 10),
              Text('Tabungan Atomik Harian', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
            ],
          ),
          const SizedBox(height: 10),
          Text('Unit fundamental keberhasilan finansial.', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 25),
          Text('Rp 20.000', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
          Text('PER SIKLUS HARIAN', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002B1D),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Otomatisasi Logika', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDecompositionTreeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text('Visualisasi Pohon Dekomposisi', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
          const SizedBox(height: 40),
          _buildTreeNode('TARGET UTAMA', 'Rp 15.000.000', isMain: true),
          const SizedBox(height: 20),
          Container(width: 2, height: 30, color: Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTreeNode('BULAN 1-12', 'Rp 7.500k'),
              const SizedBox(width: 20),
              _buildTreeNode('BULAN 13-24', 'Rp 7.500k'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallNode('Rp 20.000'),
              const SizedBox(width: 10),
              _buildSmallNode('Rp 20.000'),
              const SizedBox(width: 10),
              _buildSmallNode('Rp 20.000'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode(String label, String amount, {bool isMain = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isMain ? const Color(0xFF002B1D) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isMain ? Colors.transparent : Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: isMain ? Colors.white70 : Colors.grey)),
          const SizedBox(height: 4),
          Text(amount, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isMain ? Colors.white : const Color(0xFF002B1D))),
        ],
      ),
    );
  }

  Widget _buildSmallNode(String amount) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.2), style: BorderStyle.none), // Custom dashed look usually needs a painter, using solid for now
      ),
      child: Column(
        children: [
          const Icon(Icons.bolt, size: 16, color: Color(0xFF002B1D)),
          Text('Atomik Harian', style: GoogleFonts.outfit(fontSize: 8, color: Colors.grey)),
          Text(amount, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
        ],
      ),
    );
  }
}
