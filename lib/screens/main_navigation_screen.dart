import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'goals_screen.dart';
import 'charts_screen.dart';
import 'add_transaction_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChartsScreen(), // Wawasan
    const AddTransactionScreen(), // Tambah
    const GoalsScreen(), // Aturan
    const Center(child: Text('Profil')), 
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
            _buildNavItem(0, Icons.grid_view_rounded, 'Beranda'),
            _buildNavItem(1, Icons.query_stats_rounded, 'Wawasan'),
            _buildNavItem(2, Icons.add_circle_outline_rounded, 'Tambah'),
            _buildNavItem(3, Icons.terminal_rounded, 'Aturan'),
            _buildNavItem(4, Icons.person_outline_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isActive
                  ? BoxDecoration(
                      color: const Color(0xFFBDCECA), 
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF002B1D) : const Color(0xFF8E99AF),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? const Color(0xFF002B1D) : const Color(0xFF8E99AF),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
