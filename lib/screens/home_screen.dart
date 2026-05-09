import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/goal.dart';
import 'goal_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAutoSaveEnabled = true;

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
    final currencyFmt = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Aneka'), // Cartoon girl avatar
            ),
            const SizedBox(width: 12),
            Text(
              'Daily Savings',
              style: GoogleFonts.outfit(
                color: const Color(0xFF002B1D),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF002B1D)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer2<AccountProvider, TransactionProvider>(
        builder: (context, accProvider, txProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              // Main Balance Card
              _buildMainBalanceCard(accProvider.totalBalance, fmt),
              const SizedBox(height: 20),
              // Auto-Save Protocol Card
              _buildAutoSaveCard(),
              const SizedBox(height: 20),
              // Goals Row
              Row(
                children: [
                  Expanded(
                    child: _buildGoalProgressCard(
                      'New Laptop', 
                      0.70, 
                      'Rp 14.5M',
                      onTap: () => _navigateToGoal(context, 'New Laptop', 14500000),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildGoalProgressCard(
                      'New Books', 
                      0.45, 
                      'Rp 8.2M',
                      onTap: () => _navigateToGoal(context, 'New Books', 8200000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Emergency Fund Card
              _buildEmergencyFundCard(45000000, 50000000, 0.92, fmt),
              const SizedBox(height: 20),
              // Growth Analysis Card
              _buildGrowthAnalysisCard(),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  void _navigateToGoal(BuildContext context, String name, double target) {
    // Create a dummy goal for navigation if the real one isn't found
    final dummyGoal = Goal(
      name: name,
      targetAmount: target,
      currentAmount: target * (name == 'New Laptop' ? 0.70 : 0.45),
      deadline: DateTime.now().add(const Duration(days: 30)),
      category: 'Gadget',
      color: 0xFF002B1D,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goal: dummyGoal),
      ),
    );
  }

  Widget _buildMainBalanceCard(double total, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF002B1D),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALDO AMAN DIBELANJAKAN',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(total),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Income',
                      style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+ Rp 18M',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 35, color: Colors.white.withOpacity(0.2)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserved',
                      style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '- Rp 5.5M',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white24, size: 36),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoSaveCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.code_rounded, color: Color(0xFF002B1D)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Save Protocol',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF002B1D)),
                ),
                Text(
                  'Round-ups & logic-based rules',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAutoSaveEnabled,
            onChanged: (val) => setState(() => _isAutoSaveEnabled = val),
            activeColor: const Color(0xFF002B1D),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(String title, double progress, String amount, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFF0F2F5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              amount,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF002B1D)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyFundCard(double current, double target, double progress, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Fund',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF002B1D)),
                  ),
                  Text(
                    'Computational Safety Net',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: const Color(0xFF002B1D)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F2F5),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fmt.format(current), style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              Text('Target: Rp 50M', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthAnalysisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E5E2),
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=1000&auto=format&fit=crop'), // Chart background
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Growth Analysis',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Capital Efficiency is up 12%',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'View Detailed Report',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF002B1D)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF002B1D)),
            ],
          ),
        ],
      ),
    );
  }
}
