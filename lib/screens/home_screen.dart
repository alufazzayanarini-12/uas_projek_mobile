import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/goal.dart';
import 'goal_detail_screen.dart';
import 'settings_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAutoSaveEnabled = true;
  final String _profileImagePath = 'C:/Users/Sipul/.gemini/antigravity/brain/2693fa1e-fb88-410b-a3ca-8813d5a1d002/arini_actual_profile_1778586287965.png';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        titleSpacing: 25,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: FileImage(File(_profileImagePath)),
            ),
            const SizedBox(width: 15),
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
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF002B1D), size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Consumer2<AccountProvider, TransactionProvider>(
        builder: (context, accProvider, txProvider, child) {
          final displayBalance = accProvider.totalBalance > 0 ? accProvider.totalBalance : 12450000.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 25),
                _buildMainBalanceCard(displayBalance, fmt),
                const SizedBox(height: 25),
                _buildAutoSaveCard(),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen())),
                        child: _buildGoalProgressCard('New Laptop', 0.70, 'Rp 14.5M'),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(child: _buildGoalProgressCard('Books NW', 0.45, 'Rp 8.2M')),
                  ],
                ),
                const SizedBox(height: 25),
                _buildEmergencyFundCard(45000000, 50000000, 0.92, fmt),
                const SizedBox(height: 25),
                _buildGrowthAnalysisCard(),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainBalanceCard(double total, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF002B1D),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALDO AMAN DIBELANJAKAN',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
          ),
          const SizedBox(height: 15),
          Text(
            fmt.format(total),
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Income', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 5),
                    Text('+ Rp 18M', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              Container(width: 1, height: 45, color: Colors.white.withOpacity(0.2)),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reserved', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 5),
                    Text('- Rp 5.5M', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white24, size: 42),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoSaveCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.black.withOpacity(0.04))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.code_rounded, color: Color(0xFF002B1D), size: 26)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Auto-Save Protocol', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF002B1D))), const SizedBox(height: 4), Text('Round-ups & logic-based rules', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14))])),
          Switch(value: _isAutoSaveEnabled, onChanged: (val) => setState(() => _isAutoSaveEnabled = val), activeColor: const Color(0xFF002B1D)),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(String title, double progress, String amount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.black.withOpacity(0.04))),
      child: Column(
        children: [
          SizedBox(
            height: 90, width: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: progress, strokeWidth: 9, backgroundColor: const Color(0xFFF1F4F9), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)), strokeCap: StrokeCap.round),
                Text('${(progress * 100).toInt()}%', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 6),
          Text(amount, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF002B1D))),
        ],
      ),
    );
  }

  Widget _buildEmergencyFundCard(double current, double target, double progress, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.black.withOpacity(0.04))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Emergency Fund', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF002B1D))), Text('Computational Safety Net', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14))]),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 28, color: const Color(0xFF002B1D))),
            ],
          ),
          const SizedBox(height: 25),
          ClipRRect(borderRadius: BorderRadius.circular(15), child: LinearProgressIndicator(value: progress, minHeight: 9, backgroundColor: const Color(0xFFF1F4F9), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)))),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(fmt.format(current), style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600])), Text('Target: Rp 50M', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600]))]),
        ],
      ),
    );
  }

  Widget _buildGrowthAnalysisCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: const Color(0xFFE0E5E2), borderRadius: BorderRadius.circular(30), image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=1000&auto=format&fit=crop'), fit: BoxFit.cover, opacity: 0.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Colors.black.withOpacity(0.08), borderRadius: BorderRadius.circular(20)), child: Text('Growth Analysis', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(height: 20),
          Text('Capital Efficiency is up 12%', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
          const SizedBox(height: 20),
          Row(children: [Text('View Detailed Report', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF002B1D))), const SizedBox(width: 12), const Icon(Icons.arrow_forward, size: 20, color: Color(0xFF002B1D))]),
        ],
      ),
    );
  }
}
