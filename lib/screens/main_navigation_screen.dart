import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'goals_screen.dart';
import 'charts_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChartsScreen(), // Analisis
    const Scaffold(body: Center(child: Text('Tambah'))), // FAB action
    const GoalsScreen(), // Aturan
    const Center(child: Text('Profil')), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan extendBody agar konten bisa berada di bawah BottomAppBar jika diperlukan
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 85,
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, 'Beranda'),
              _buildNavItem(1, Icons.insights_rounded, 'Analisis'),
              _buildFab(),
              _buildNavItem(3, Icons.code_rounded, 'Aturan'),
              _buildNavItem(4, Icons.person_outline_rounded, 'Profil'),
            ],
          ),
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
        width: 65,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFFBDCECA), 
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF002B1D) : const Color(0xFF8E99AF),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? const Color(0xFF002B1D) : const Color(0xFF8E99AF),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () {
        // Handle FAB click
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF002B1D),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF002B1D).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
