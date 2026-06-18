import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/category_model.dart';
import '../providers/account_provider.dart';
import 'goal_detail_screen.dart';
import 'add_goal_screen.dart';
import 'settings_screen.dart';
import 'emergency_fund_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCharts;
  const HomeScreen({super.key, this.onNavigateToCharts});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<SettingsProvider, CategoryProvider, TransactionProvider>(
      builder: (context, settings, categoryProvider, txProvider, child) {
        final goalProvider = Provider.of<GoalProvider>(context);
        final accountProvider = Provider.of<AccountProvider>(context);
        final goals = goalProvider.goals;
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);

        double emergencyProgress = categoryProvider.emergencyTarget > 0
            ? categoryProvider.emergencyCurrent / categoryProvider.emergencyTarget
            : 0.0;
        if (emergencyProgress > 1.0) emergencyProgress = 1.0;

        final today = DateTime.now();
        final double todayExpenses = txProvider.transactions
            .where((t) => t.type == 'withdrawal' &&
                          t.date.year == today.year &&
                          t.date.month == today.month &&
                          t.date.day == today.day)
            .fold(0.0, (sum, t) => sum + t.amount);
        final double remainingPocketMoney = settings.dailyPocketMoney - todayExpenses;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            toolbarHeight: 70,
            titleSpacing: 25,
            title: Row(
              children: [
                Icon(Icons.analytics_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 28),
                const SizedBox(width: 12),
                Text(
                  settings.translate('tabunganku'),
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : const Color(0xFF002B1D),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
            actions: [
              CircleAvatar(
                radius: 18,
                backgroundImage: settings.getProfileImageProvider(),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : const Color(0xFF002B1D), size: 28),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              ),
              const SizedBox(width: 15),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    try {
                      final txs = txProvider.transactions;
                      final sb = StringBuffer();
                      sb.writeln('Total transactions: ${txs.length}');
                      for (var t in txs) {
                        sb.writeln('Tx: id=${t.id}, type=${t.type}, amount=${t.amount}, desc="${t.description}", catId=${t.categoryId}');
                      }
                      File('c:\\Users\\Sipul\\uas_projek_mobile\\db_debug.txt').writeAsStringSync(sb.toString());
                    } catch (e) {
                      // ignore
                    }
                    return const SizedBox.shrink();
                  }
                ),
                const SizedBox(height: 25),
                _buildTotalBalanceCard(
                  settings, 
                  isDark, 
                  categoryProvider.emergencyCurrent > 0 ? categoryProvider.emergencyCurrent : categoryProvider.savingsCurrent, 
                  txProvider.totalIncome - txProvider.transactions.where((t) {
                    if (t.type != 'withdrawal') return false;
                    if (t.categoryId == 5) return true;
                    if (t.description.contains('Mulai Menabung') || t.description.contains('Dana Darurat')) return true;
                    final cat = categoryProvider.allCategories.firstWhere(
                      (c) => c.id == t.categoryId,
                      orElse: () => CategoryModel(id: -1, name: '', iconCodePoint: 0, colorValue: 0),
                    );
                    final catName = cat.name.toLowerCase();
                    return catName.contains('darurat') || catName.contains('menabung') || catName.contains('emergency');
                  }).fold(0.0, (sum, t) => sum + t.amount), 
                  txProvider.totalExpenses, 
                  remainingPocketMoney,
                ),
                const SizedBox(height: 30),
                Text(
                  settings.translate('target_anda'),
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 15),
                goals.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flag_outlined, size: 40, color: isDark ? Colors.white54 : const Color(0xFF002B1D).withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              settings.translate('bahasa') == 'Bahasa Indonesia' 
                                  ? 'Belum ada target' 
                                  : 'No goals set yet',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settings.translate('bahasa') == 'Bahasa Indonesia'
                                  ? 'Mulai buat target Anda hari ini!'
                                  : 'Start making your goals today!',
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen())),
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(
                                settings.translate('bahasa') == 'Bahasa Indonesia' 
                                    ? 'Buat Target' 
                                    : 'Create Goal',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFBDCECA),
                                foregroundColor: const Color(0xFF002B1D),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: goals.map((goal) {
                          double progress = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0;
                          if (progress > 1.0) progress = 1.0;
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 60) / 2,
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetailScreen(goalId: goal.id ?? 1))),
                              child: _buildGoalProgressCard(
                                goal.name, 
                                progress, 
                                settings.formatCurrency(goal.targetAmount), 
                                isDark,
                                settings,
                                onEdit: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddGoalScreen(goalToEdit: goal)));
                                },
                                onDelete: () {
                                  if (goal.id != null) {
                                    Provider.of<GoalProvider>(context, listen: false).deleteGoal(goal.id!);
                                  }
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmergencyFundScreen()),
                    );
                  },
                  child: _buildEmergencyFundCard(
                  categoryProvider.emergencyCurrent,
                  categoryProvider.emergencyTarget,
                  emergencyProgress,
                  settings,
                  isDark,
                ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF002B1D),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddGoalScreen()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildTotalBalanceCard(SettingsProvider settings, bool isDark, double savingsBalance, double totalIncome, double totalExpenses, double remainingPocketMoney) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmergencyFundScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF002B1D),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: const Color(0xFF002B1D).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings.translate('sisa_uang_tabungan').toUpperCase(), 
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                settings.formatCurrency(savingsBalance), 
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: widget.onNavigateToCharts,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wallet_outlined, color: Color(0xFFBDCECA), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            settings.selectedLanguage == 'Bahasa Indonesia' ? 'Sisa Uang Saku Harian' : 'Daily Pocket Money Remaining',
                            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text(
                        settings.formatCurrency(remainingPocketMoney),
                        style: GoogleFonts.outfit(color: const Color(0xFFBDCECA), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildBalanceSubItem(settings.translate('pemasukan'), '+ ' + settings.formatCurrency(totalIncome)),
                  Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 25)),
                  _buildBalanceSubItem(settings.translate('pengeluaran'), '- ' + settings.formatCurrency(totalExpenses)),
                ],
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildBalanceSubItem(String label, String amount) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          const SizedBox(height: 5),
          Text(amount, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(String title, double progress, String amount, bool isDark, SettingsProvider settings, {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF002B1D)), maxLines: 2, overflow: TextOverflow.ellipsis)),
              SizedBox(
                height: 24,
                width: 24,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit();
                    if (value == 'delete' && onDelete != null) onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(settings.translate('edit'), style: GoogleFonts.outfit()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text(settings.translate('hapus'), style: GoogleFonts.outfit(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F4F9), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF002B1D)), minHeight: 6),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amount, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyFundCard(double current, double target, double progress, SettingsProvider settings, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                settings.translate('dana_darurat'), 
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: isDark ? Colors.white : const Color(0xFF002B1D)),
              ),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 28, color: isDark ? Colors.white : const Color(0xFF002B1D))),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: progress, backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F4F9), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF98D8B6)), minHeight: 10),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(
                settings.formatCurrency(current), 
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ), 
              Text(
                '${settings.translate('target_label')}: ${settings.formatCurrency(target)}', 
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
