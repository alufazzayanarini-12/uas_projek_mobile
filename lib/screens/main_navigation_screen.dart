import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'goals_screen.dart';
import 'charts_screen.dart';
import 'add_transaction_screen.dart';
import 'profile_screen.dart';
import 'debt_management_screen.dart';
import 'add_goal_screen.dart';
import 'automation_settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChartsScreen(), // Insights
    const AddTransactionScreen(), // Add (Fallback)
    const GoalsScreen(), // Rules
    const ProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home'),
            _buildNavItem(1, Icons.analytics_outlined, 'Insights'),
            _buildNavItem(2, Icons.add_circle_outline_rounded, 'Add', isSpecial: true),
            _buildNavItem(3, Icons.terminal_rounded, 'Rules'),
            _buildNavItem(4, Icons.person_outline_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool isSpecial = false}) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (isSpecial) {
          _showAddChoiceMenu(context);
        } else {
          setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: (isActive && !isSpecial)
                  ? BoxDecoration(
                      color: const Color(0xFFBDCECA), 
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                icon,
                color: (isActive || isSpecial) ? const Color(0xFF002B1D) : const Color(0xFF8E99AF),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: (isActive || isSpecial) ? const Color(0xFF002B1D) : const Color(0xFF8E99AF),
                fontSize: 11,
                fontWeight: (isActive || isSpecial) ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChoiceMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(25, 40, 25, 100),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Pilih Aksi',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola keuangan Anda dengan langkah cerdas hari ini.',
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 35),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.85,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildFeatureCard(
                      'Tambah Transaksi',
                      'Catat pengeluaran harian dengan cepat',
                      Icons.payments_outlined,
                      const Color(0xFFE8F0FE),
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
                      },
                    ),
                    _buildFeatureCard(
                      'Buat Target Baru',
                      'Mulai tabungan untuk impian masa depan',
                      Icons.track_changes_rounded,
                      const Color(0xFFF1F4F9),
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen()));
                      },
                    ),
                    _buildFeatureCard(
                      'Atur Otomatisasi',
                      'Gunakan mesin logika untuk pos anggaran',
                      Icons.code_rounded,
                      const Color(0xFFF1F4F9),
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AutomationSettingsScreen()));
                      },
                    ),
                    _buildFeatureCard(
                      'Catat Pemasukan',
                      'Pantau aliran dana masuk secara akurat',
                      Icons.account_balance_wallet_outlined,
                      const Color(0xFFF1F4F9),
                      () {
                        Navigator.pop(context);
                        // Future: Navigate to IncomeScreen
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildTipsCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 25,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color iconBg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF111827), size: 24),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
            const SizedBox(height: 8),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600], height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF111827)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Tips: Mengatur otomatisasi membantu Anda berhemat 15% lebih banyak setiap bulan.',
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[800], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
