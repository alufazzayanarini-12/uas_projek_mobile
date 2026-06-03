import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'sub_category_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final dynamic account;
  const AddTransactionScreen({super.key, this.account});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController(text: '125000');
  String _selectedSource = 'Main Balance';
  String _selectedCategory = 'Food';
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE);

    String currencySymbol = 'Rp ';
    switch (settings.selectedCurrency) {
      case 'Rupiah Indonesia': currencySymbol = 'Rp '; break;
      case 'US Dollar': currencySymbol = '\$ '; break;
      case 'Euro': currencySymbol = '€ '; break;
      case 'Japanese Yen': currencySymbol = '¥ '; break;
      case 'Saudi Riyal': currencySymbol = '﷼ '; break;
      case 'Ringgit Malaysia': currencySymbol = 'RM '; break;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : const Color(0xFF002B1D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          settings.translate('tambah_transaksi'),
          style: GoogleFonts.outfit(color: isDark ? Colors.white : const Color(0xFF002B1D), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: isDark ? Colors.white : const Color(0xFF002B1D)),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAmountInput(settings, currencySymbol, cardColor, isDark, textColor),
            const SizedBox(height: 20),
            _buildSourceSection(settings, cardColor, isDark, textColor),
            const SizedBox(height: 20),
            _buildCategorySection(settings, cardColor, isDark, textColor),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveButton(settings),
    );
  }

  Widget _buildAmountInput(SettingsProvider settings, String currencySymbol, Color cardColor, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(
            settings.translate('nominal').toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D)),
            decoration: InputDecoration(
              prefixText: currencySymbol,
              prefixStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF002B1D)),
              border: InputBorder.none,
              hintText: '0',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection(SettingsProvider settings, Color cardColor, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.translate('akun_asal'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 20),
          _buildSourceItem(Icons.account_balance_wallet_outlined, settings.translate('dompet'), _selectedSource == 'Main Balance', () => setState(() => _selectedSource = 'Main Balance')),
          const SizedBox(height: 12),
          _buildSourceItem(Icons.savings_outlined, settings.translate('tabungan'), _selectedSource == 'Savings', () => setState(() => _selectedSource = 'Savings')),
          const SizedBox(height: 12),
          _buildSourceItem(Icons.credit_card_outlined, settings.translate('kartu_kredit'), _selectedSource == 'Credit Card', () => setState(() => _selectedSource = 'Credit Card')),
        ],
      ),
    );
  }

  Widget _buildSourceItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFF002B1D) : Colors.black.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF002B1D), size: 20),
            const SizedBox(width: 15),
            Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF002B1D))),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFF002B1D),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(SettingsProvider settings, Color cardColor, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.translate('kategori'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.6,
            children: [
              _buildCategoryItem(Icons.restaurant_outlined, settings.translate('makan_dan_minum'), 'Food'),
              _buildCategoryItem(Icons.directions_car_outlined, settings.translate('transportasi_dan_bensin'), 'Transport'),
              _buildCategoryItem(Icons.receipt_long_outlined, settings.translate('tagihan'), 'Bills'),
              _buildCategoryItem(Icons.shopping_bag_outlined, settings.translate('belanja'), 'Shopping'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, String key) {
    bool isSelected = _selectedCategory == key;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = key);
        if (key == 'Food') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubCategoryScreen(mainCategory: 'Food')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFF002B1D) : Colors.black.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF002B1D), size: 24),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF002B1D)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton.icon(
        onPressed: () async {
          final raw = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
          final parsedAmount = double.tryParse(raw) ?? 0.0;
          if (parsedAmount <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(settings.translate('bahasa') == 'Bahasa Indonesia' ? 'Masukkan nominal yang valid' : 'Please enter a valid amount'), backgroundColor: Colors.red.shade700),
            );
            return;
          }

          final accountProvider = Provider.of<AccountProvider>(context, listen: false);
          final txProvider = Provider.of<TransactionProvider>(context, listen: false);
          final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

          if (accountProvider.accounts.isEmpty) {
            await accountProvider.loadAccounts();
          }

          final currentAccount = accountProvider.accounts.isNotEmpty ? accountProvider.accounts.first : null;
          if (currentAccount == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Tidak ada akun yang tersedia'), backgroundColor: Colors.red.shade700),
            );
            return;
          }

          // Match category from categories list or fallback
          int? matchedCategoryId;
          String categoryName = _selectedCategory; // 'Food', 'Transport', 'Bills', 'Shopping'
          String localizedCatName = categoryName;
          if (categoryName == 'Food') {
            localizedCatName = 'Makan & Minum';
          } else if (categoryName == 'Transport') {
            localizedCatName = 'Transportasi';
          } else if (categoryName == 'Bills') {
            localizedCatName = 'Tagihan';
          } else if (categoryName == 'Shopping') {
            localizedCatName = 'Belanja';
          }

          final lowerCat = localizedCatName.toLowerCase();
          for (var cat in categoryProvider.allCategories) {
            final catName = cat.name.toLowerCase();
            if ((lowerCat.contains('makan') || lowerCat.contains('food')) && 
                (catName.contains('makan') || catName.contains('food'))) {
              matchedCategoryId = cat.id;
              break;
            }
            if ((lowerCat.contains('transport') || lowerCat.contains('bensin')) && 
                (catName.contains('transport') || catName.contains('bensin') || catName.contains('fuel'))) {
              matchedCategoryId = cat.id;
              break;
            }
            if (lowerCat.contains('tagihan') && catName.contains('bulanan')) {
              matchedCategoryId = cat.id;
              break;
            }
            if (lowerCat.contains('belanja') && catName.contains('saku')) {
              matchedCategoryId = cat.id;
              break;
            }
          }

          if (matchedCategoryId == null && categoryProvider.allCategories.isNotEmpty) {
            matchedCategoryId = categoryProvider.allCategories.first.id;
          }

          final description = _noteController.text.trim().isEmpty ? localizedCatName : _noteController.text.trim();
          final newTransaction = TransactionModel(
            accountId: currentAccount.id!,
            categoryId: matchedCategoryId,
            type: 'withdrawal',
            amount: parsedAmount,
            description: description,
          );

          await txProvider.addTransaction(newTransaction);
          categoryProvider.processTransaction(localizedCatName, 'withdrawal', parsedAmount);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(settings.translate('bahasa') == 'Bahasa Indonesia' ? 'Transaksi berhasil disimpan' : 'Transaction saved successfully'), backgroundColor: Colors.green.shade700),
          );

          Navigator.pop(context);
        },
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: Text(settings.translate('simpan_transaksi'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF002B1D),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
       ),
    );
  }
}
