import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
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
  List<Map<String, dynamic>> _allTransactions = [
    {'category': 'Food', 'note': 'Makan siang McD', 'date': 'Today, 12:45', 'amount': 'Rp 55.000'},
    {'category': 'Transport', 'note': 'Gojek ke kantor', 'date': 'Today, 08:30', 'amount': 'Rp 15.000'},
    {'category': 'Shopping', 'note': 'Beli kemeja baru', 'date': 'Yesterday', 'amount': 'Rp 250.000'},
    {'category': 'Bills', 'note': 'Listrik bulanan', 'date': '12 May 2026', 'amount': 'Rp 450.000'},
  ];
  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = _allTransactions;
    _noteController.addListener(_filterTransactions);
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _allTransactions
          .where((t) => t['note'].toLowerCase().contains(_noteController.text.toLowerCase()) || 
                       t['category'].toLowerCase().contains(_noteController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF002B1D);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF002B1D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Transaksi',
          style: GoogleFonts.outfit(color: const Color(0xFF002B1D), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF002B1D)),
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
            _buildAmountInput(cardColor, isDark, textColor),
            const SizedBox(height: 20),
            _buildSourceSection(cardColor, isDark, textColor),
            const SizedBox(height: 20),
            _buildCategorySection(cardColor, isDark, textColor),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildAmountInput(Color cardColor, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(
            'JUMLAH NOMINAL (IDR)',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF002B1D)),
              border: InputBorder.none,
              hintText: '0',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection(Color cardColor, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sumber Dana', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 20),
          _buildSourceItem(Icons.account_balance_wallet_outlined, 'Main Balance', _selectedSource == 'Main Balance'),
          const SizedBox(height: 12),
          _buildSourceItem(Icons.savings_outlined, 'Savings', _selectedSource == 'Savings'),
          const SizedBox(height: 12),
          _buildSourceItem(Icons.credit_card_outlined, 'Credit Card', _selectedSource == 'Credit Card'),
        ],
      ),
    );
  }

  Widget _buildSourceItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSource = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
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

  Widget _buildCategorySection(Color cardColor, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategori', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.6,
            children: [
              _buildCategoryItem(Icons.restaurant_outlined, 'Food'),
              _buildCategoryItem(Icons.directions_car_outlined, 'Transport'),
              _buildCategoryItem(Icons.receipt_long_outlined, 'Bills'),
              _buildCategoryItem(Icons.shopping_bag_outlined, 'Shopping'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = label);
        if (label == 'Food') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubCategoryScreen(mainCategory: 'Food')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0F0) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFF002B1D) : Colors.black.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF002B1D), size: 24),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF002B1D))),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(Color cardColor, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hasil Pencarian / Riwayat', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              Text('${_filteredTransactions.length} item', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          if (_filteredTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Tidak ada hasil yang cocok', style: GoogleFonts.outfit(color: Colors.grey)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final t = _filteredTransactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor(isDark).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Icon(_getCategoryIcon(t['category']), color: const Color(0xFF002B1D), size: 18),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['note'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(t['date'], style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text(t['amount'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF002B1D))),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color bgColor(bool isDark) => isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE);

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant_outlined;
      case 'Transport': return Icons.directions_car_outlined;
      case 'Bills': return Icons.receipt_long_outlined;
      case 'Shopping': return Icons.shopping_bag_outlined;
      default: return Icons.category_outlined;
    }
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: Text('Simpan Transaksi', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
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
