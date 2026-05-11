import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedPeriod = 0; // 0: Mingguan, 1: Bulanan, 2: Tahunan

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
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF002B1D)), onPressed: () {}),
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
              'Pola Pengeluaran',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002B1D),
              ),
            ),
            const SizedBox(height: 20),
            _buildPeriodToggle(),
            const SizedBox(height: 25),
            _buildDailyExpenseCard(),
            const SizedBox(height: 20),
            _buildRecursiveCostsCard(),
            const SizedBox(height: 20),
            _buildSavingsProgressCard(),
            const SizedBox(height: 20),
            _buildForecastCard(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleItem(0, 'Mingguan'),
          _buildToggleItem(1, 'Bulanan'),
          _buildToggleItem(2, 'Tahunan'),
        ],
      ),
    );
  }

  Widget _buildToggleItem(int index, String label) {
    bool isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF002B1D) : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyExpenseCard() {
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
              Text('Pengeluaran harian', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rp 4.280.500', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                  Text('Total aliran-logika', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(12),
            ),
          ), // Chart Placeholder
        ],
      ),
    );
  }

  Widget _buildRecursiveCostsCard() {
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
            children: [
              const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF76C893), size: 28),
              const SizedBox(width: 12),
              Text('Biaya Rekursif', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecursiveItem(Icons.business_center_rounded, 'Sewa/KPR', 'Rp 2,1jt', 0.8, const Color(0xFF002B1D)),
          const SizedBox(height: 15),
          _buildRecursiveItem(Icons.directions_car_rounded, 'Log Komuter', 'Rp 340rb', 0.4, const Color(0xFF76C893)),
        ],
      ),
    );
  }

  Widget _buildRecursiveItem(IconData icon, String title, String amount, double progress, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFE8EEF9), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF002B1D), size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                  Text(amount, style: GoogleFonts.outfit(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: const Color(0xFFF1F4F9), valueColor: AlwaysStoppedAnimation<Color>(color)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFFDE68A), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF92400E), size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20)),
                child: Text('Tren Signifikan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF92400E))),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text('Sisa Tabungan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF92400E))),
          const SizedBox(height: 5),
          Text('Tabungan Anda sehat. Capai 65% dari target bulanan.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFFB45309))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFFDE68A))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TARGET TABUNGAN', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF92400E))),
                    Text('65%', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF92400E))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: const LinearProgressIndicator(value: 0.65, minHeight: 6, backgroundColor: Color(0xFFFEF3C7), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF92400E))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF002B1D),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perkiraan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          Text('Prediksi modal akhir bulan berdasarkan pola saat ini.', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 20),
          Text('Rp 12.450.000', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB7E4C7),
              foregroundColor: const Color(0xFF002B1D),
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: BorderRadius.circular(15),
            ),
            child: Text('Sesuaikan Parameter', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
