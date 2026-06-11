import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import '../providers/account_provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class EmergencyFundScreen extends StatefulWidget {
  const EmergencyFundScreen({super.key});

  @override
  State<EmergencyFundScreen> createState() => _EmergencyFundScreenState();
}

class _EmergencyFundScreenState extends State<EmergencyFundScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isWithdrawMode = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context);
    final isDark = settings.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double currentAmount = catProvider.emergencyCurrent > 0
        ? catProvider.emergencyCurrent
        : catProvider.savingsCurrent;
    double targetAmount = catProvider.emergencyTarget > 0
        ? catProvider.emergencyTarget
        : catProvider.savingsTarget;

    double progress = targetAmount > 0 ? (currentAmount / targetAmount) : 0.0;
    if (progress > 1.0) progress = 1.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          settings.translate('dana_darurat'),
          style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D4D3B),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text('Total Tersimpan', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text(fmt.format(currentAmount), style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF98D8B6)),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Text('Target: ${fmt.format(targetAmount)}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Top up / Withdrawal Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab Selector
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isWithdrawMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isWithdrawMode ? const Color(0xFF002B1D) : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: !_isWithdrawMode ? const Color(0xFF002B1D) : Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Text(
                                'Tabung',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: !_isWithdrawMode ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isWithdrawMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isWithdrawMode ? const Color(0xFFC62828) : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: _isWithdrawMode ? const Color(0xFFC62828) : Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Text(
                                'Tarik',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: _isWithdrawMode ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      prefixStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      hintText: '0',
                      labelText: _isWithdrawMode ? 'Nominal Pengeluaran / Tarik' : 'Nominal Top Up / Tabung',
                      labelStyle: GoogleFonts.outfit(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: _isWithdrawMode ? const Color(0xFFC62828) : (isDark ? Colors.white70 : const Color(0xFF002B1D)), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                          String cleanText = _amountController.text.replaceAll('.', '').replaceAll(',', '.');
                          double amount = double.tryParse(cleanText) ?? 0.0;
                          if (amount > 0) {
                            if (_isWithdrawMode) {
                              // Tarik Mode
                              if (catProvider.emergencyCurrent < amount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      settings.translate('bahasa') == 'Bahasa Indonesia' 
                                          ? 'Saldo tabungan tidak mencukupi!' 
                                          : 'Insufficient savings balance!', 
                                      style: GoogleFonts.outfit(),
                                    ),
                                    backgroundColor: Colors.red,
                                  )
                                );
                                return;
                              }
                              
                              // 1. Update CategoryProvider balance (withdraw)
                              catProvider.withdrawEmergency(amount);
                              
                              // 2. Add withdrawal transaction to AccountProvider
                              final accountProvider = Provider.of<AccountProvider>(context, listen: false);
                              if (accountProvider.accounts.isNotEmpty) {
                                final defaultAccount = accountProvider.accounts.first;
                                final newTx = TransactionModel(
                                  accountId: defaultAccount.id ?? 1,
                                  categoryId: 5, // Dana Darurat
                                  amount: amount,
                                  type: 'withdrawal',
                                  description: 'Tarik Mulai Menabung',
                                  date: DateTime.now(),
                                );
                                await accountProvider.addTransaction(newTx);
                                if (mounted) {
                                  await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
                                }
                              }

                              _amountController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    settings.translate('bahasa') == 'Bahasa Indonesia' 
                                        ? 'Berhasil menarik uang tabungan!' 
                                        : 'Successfully withdrew savings!', 
                                    style: GoogleFonts.outfit(),
                                  ),
                                  backgroundColor: const Color(0xFFC62828),
                                )
                              );
                            } else {
                              // Tabung Mode
                              // 1. Update CategoryProvider balance
                              catProvider.topUpEmergency(amount);
                              
                              // 2. Add deposit transaction to AccountProvider
                              final accountProvider = Provider.of<AccountProvider>(context, listen: false);
                              if (accountProvider.accounts.isNotEmpty) {
                                final defaultAccount = accountProvider.accounts.first;
                                final newTx = TransactionModel(
                                  accountId: defaultAccount.id ?? 1,
                                  categoryId: 5, // Dana Darurat
                                  amount: amount,
                                  type: 'deposit',
                                  description: 'Top Up Mulai Menabung',
                                  date: DateTime.now(),
                                );
                                await accountProvider.addTransaction(newTx);
                                if (mounted) {
                                  await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
                                }
                              }

                              _amountController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    settings.translate('bahasa') == 'Bahasa Indonesia' 
                                        ? 'Berhasil menambah tabungan!' 
                                        : 'Successfully added savings!', 
                                    style: GoogleFonts.outfit(),
                                  ),
                                  backgroundColor: const Color(0xFF0D4D3B),
                                )
                              );
                            }
                          }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWithdrawMode ? const Color(0xFFC62828) : const Color(0xFF002B1D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(_isWithdrawMode ? 'Tarik Tabungan' : 'Simpan Tabungan', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
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
}
