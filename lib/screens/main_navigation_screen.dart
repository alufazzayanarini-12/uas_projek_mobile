import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';
import 'goals_screen.dart';
import 'charts_screen.dart';
import 'add_transaction_screen.dart';
import 'profile_screen.dart';
import 'debt_management_screen.dart';
import 'add_goal_screen.dart';
import 'automation_settings_screen.dart';
import 'settings_screen.dart';
import 'financial_auditor_screen.dart';
import 'monthly_report_screen.dart';

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
    const MonthlyReportScreen(), // Report
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
            _buildNavItem(0, Icons.home_outlined, 'Beranda'),
            _buildNavItem(1, Icons.analytics_outlined, 'Statistik'),
            _buildNavItem(2, Icons.add_circle_outline_rounded, 'Tambah', isSpecial: true),
            _buildNavItem(3, Icons.terminal_rounded, 'Aturan'),
            _buildNavItem(4, Icons.person_outline_rounded, 'Profil'),
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
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isDark = settings.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                // Top Header Row (Tabunganku, Settings Icon, avatar)
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04))),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Tabunganku',
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: textColor),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                        },
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: settings.getProfileImageProvider(),
                      ),
                    ],
                  ),
                ),
                
                // Content body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Aksi',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kelola keuangan Anda dengan kontrol penuh.',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 35),
                        
                        // Three premium cards
                        _buildListFeatureCard(
                          context,
                          'Audit Finansial',
                          'Cek kesehatan keuangan Anda.',
                          Icons.search,
                          isDark,
                          () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialAuditorScreen()));
                          },
                        ),
                        _buildListFeatureCard(
                          context,
                          'Mesin Aturan',
                          'Kelola otomatisasi tabungan.',
                          Icons.terminal_outlined,
                          isDark,
                          () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AutomationSettingsScreen()));
                          },
                        ),
                        _buildListFeatureCard(
                          context,
                          'Riwayat Aktivitas',
                          'Lihat log transaksi terakhir.',
                          Icons.history,
                          isDark,
                          () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        _buildListTipsCard(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Circular close button at the bottom
            Positioned(
              bottom: 30,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002B1D),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF002B1D), size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTipsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF2563EB), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Tips: Mengatur otomatisasi membantu Anda berhemat 15% lebih banyak setiap bulan.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF1E40AF),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
