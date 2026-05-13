import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../models/account.dart';
import 'account_detail_screen.dart';
import 'add_account_screen.dart';

class BankManagementScreen extends StatelessWidget {
  const BankManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AccountProvider>(
      builder: (context, settings, accountProvider, child) {
        final isDark = settings.isDarkMode;
        final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Manajemen Rekening',
              style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REKENING TERHUBUNG',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),
                
                // Menampilkan rekening dari database jika ada
                if (accountProvider.accounts.isNotEmpty)
                  ...accountProvider.accounts.map((acc) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _buildBankCard(
                      context,
                      acc.name, 
                      'Arini - ${acc.id}0000', 
                      'Rp ${acc.balance.toInt()}', 
                      isDark, 
                      cardColor,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(account: acc))),
                    ),
                  ))
                else ...[
                  // Data hardcoded jika database kosong (sesuai gambar)
                  _buildBankCard(
                    context,
                    'Bank Central Asia (BCA)', 
                    'Arini - 1234567890', 
                    'Rp 8.500.000', 
                    isDark, 
                    cardColor,
                    onTap: () => _showDummyDetail(context, 'BCA', 8500000),
                  ),
                  const SizedBox(height: 15),
                  _buildBankCard(
                    context,
                    'Bank Mandiri', 
                    'Arini - 0987654321', 
                    'Rp 4.000.000', 
                    isDark, 
                    cardColor,
                    onTap: () => _showDummyDetail(context, 'Mandiri', 4000000),
                  ),
                ],
                
                const SizedBox(height: 30),
                _buildAddBankButton(context, isDark),
                const SizedBox(height: 40),
                Text(
                  'METODE PEMBAYARAN LAIN',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),
                _buildOtherMethodCard(
                  context,
                  'E-Wallet (GoPay)', 
                  '081234567890', 
                  isDark, 
                  cardColor,
                  onTap: () => _showEWalletInfo(context, isDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankCard(BuildContext context, String bankName, String details, String balance, bool isDark, Color cardColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF002B1D), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.account_balance, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bankName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  Text(details, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Text(balance, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0D9488))),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherMethodCard(BuildContext context, String name, String details, bool isDark, Color cardColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDark ? Colors.white10 : const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.wallet, color: isDark ? Colors.white70 : const Color(0xFF002B1D), size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  Text(details, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBankButton(BuildContext context, bool isDark) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAccountScreen()));
      },
      icon: const Icon(Icons.add_rounded),
      label: Text('Tambah Rekening Baru', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF002B1D),
        side: const BorderSide(color: Color(0xFF002B1D)),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  void _showDummyDetail(BuildContext context, String name, double balance) {
    // Navigasi ke detail dengan data dummy untuk demo
    Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(
      account: Account(id: 99, name: name, balance: balance, colorValue: 0xFF002B1D, iconCodePoint: Icons.account_balance.codePoint),
    )));
  }

  void _showEWalletInfo(BuildContext context, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail E-Wallet akan segera hadir!', style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF002B1D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
