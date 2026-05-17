import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import 'edit_goal_screen.dart';
import 'settings_screen.dart';
import 'automation_settings_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final int? goalId;

  const GoalDetailScreen({super.key, this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, GoalProvider>(
      builder: (context, settings, goalProvider, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        Goal? goal;
        if (widget.goalId != null) {
          try {
            goal = goalProvider.goals.firstWhere((g) => g.id == widget.goalId);
          } catch (e) {
            goal = null;
          }
        }

        final title = goal?.name ?? (widget.goalId == 1 ? 'Laptop Baru' : 'Books NW');
        final currentAmount = goal?.currentAmount ?? (widget.goalId == 1 ? 11250000.0 : 3600000.0);
        final targetAmount = goal?.targetAmount ?? (widget.goalId == 1 ? 15000000.0 : 8000000.0);
        double progress = targetAmount > 0 ? currentAmount / targetAmount : 0;
        if (progress > 1.0) progress = 1.0;
        
        final userName = settings.userName.isNotEmpty ? settings.userName : 'Arini';

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFE5E7EB), // Gray background like screenshot
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFE5E7EB),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Purple Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A148C), // Deep purple
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Text('Total Saldo Anda', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 10),
                      Text(fmt.format(currentAmount), style: GoogleFonts.outfit(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 16),
                          const SizedBox(width: 8),
                          Text(userName, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                Text('${(progress * 100).toInt()}%', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('Target: ${fmt.format(targetAmount)}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),

                // Bottom Sheet style container for Catat Setoran
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catat Setoran', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      const SizedBox(height: 30),
                      
                      // Tanggal field
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF0D9488)), // Teal border
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('dd MMMM yyyy').format(_selectedDate), style: GoogleFonts.outfit(fontSize: 16, color: textColor)),
                                  Icon(Icons.calendar_month_outlined, color: Colors.grey[600]),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            left: 12,
                            child: Container(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text('Tanggal', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Nominal field
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.outfit(fontSize: 16, color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Rp 2000000',
                              hintStyle: GoogleFonts.outfit(color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488))),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            left: 12,
                            child: Container(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text('Nominal', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Keterangan field
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          TextField(
                            controller: _noteController,
                            style: GoogleFonts.outfit(fontSize: 16, color: textColor),
                            decoration: InputDecoration(
                              hintText: 'tabungan saya',
                              hintStyle: GoogleFonts.outfit(color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0BACD4))), // Blue-cyan border
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0BACD4))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0BACD4))),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            left: 12,
                            child: Container(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text('Keterangan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0BACD4))),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          if (_amountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal harus diisi')));
                            return;
                          }
                          
                          if (goal != null && goal.id != null) {
                            double amount = double.tryParse(_amountController.text) ?? 0;
                            // Assume accountId 1 for now
                            Provider.of<GoalProvider>(context, listen: false).addSavingsToGoal(goal.id!, amount, 1);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Setoran berhasil dicatat!', style: GoogleFonts.outfit()), backgroundColor: const Color(0xFF4CAF50)));
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ini hanya contoh. Setoran tidak dapat disimpan.', style: GoogleFonts.outfit())));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50), // Green button like screenshot
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('SIMPAN', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                      ),
                      const SizedBox(height: 100), // padding for scroll
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
