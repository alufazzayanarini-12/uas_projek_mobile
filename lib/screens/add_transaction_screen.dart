import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Account account;
  const AddTransactionScreen({super.key, required this.account});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'deposit'; // 'deposit', 'withdrawal', 'transfer'
  CategoryModel? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CategoryProvider>(context);
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1F5FE), // Biru Muda
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0288D1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transaksi Baru', style: TextStyle(color: Color(0xFF0288D1), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── KOTAK INFO ARINI (UNGU MUDA) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5), // Ungu Muda
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFAB47BC),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF7B1FA2))),
                      const Text('Rekening Aktif', style: TextStyle(color: Color(0xFF7B1FA2), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── RADIO BUTTONS ──
            const Text('Tipe Transaksi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Setor', style: TextStyle(fontSize: 12)),
                    value: 'deposit',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Tarik', style: TextStyle(fontSize: 12)),
                    value: 'withdrawal',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Kirim', style: TextStyle(fontSize: 12)),
                    value: 'transfer',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── INPUT FIELD ──
            _buildInputField('Nominal', _amountController, Icons.money, TextInputType.number, prefix: 'Rp '),
            const SizedBox(height: 20),
            _buildInputField('Keterangan / Catatan', _noteController, Icons.note_alt_outlined, TextInputType.text),
            const SizedBox(height: 20),
            
            // ── DROP DOWN KATEGORI ──
            const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  isExpanded: true,
                  hint: const Text('Pilih Kategori'),
                  value: _selectedCategory,
                  items: catProvider.categories.map((c) => DropdownMenuItem(
                    value: c,
                    child: Row(children: [Icon(IconData(c.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(c.colorValue)), const SizedBox(width: 10), Text(c.name)]),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── TOMBOL SIMPAN ──
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('SIMPAN TRANSAKSI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, TextInputType type, {String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            prefixText: prefix,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  void _handleSave() async {
    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal harus lebih dari 0')));
      return;
    }

    final tx = TransactionModel(
      accountId: widget.account.id!,
      type: _type,
      amount: amount,
      categoryId: _selectedCategory?.id, // Kirim ID kategori ke database
      description: _noteController.text.isEmpty ? 'Transaksi Baru' : _noteController.text,
      date: DateTime.now(),
    );

    try {
      await Provider.of<AccountProvider>(context, listen: false).addTransaction(tx);
      await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
      
      // ── INTEGRASI KE MANAJEMEN KATEGORI ──
      if (_selectedCategory != null) {
        Provider.of<CategoryProvider>(context, listen: false).processTransaction(
          _selectedCategory!.name,
          _type,
          amount,
        );
      }
      
      if (mounted) {
        Navigator.pop(context); // Kembali ke Buku Tabungan
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi Berhasil Disimpan!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }
}
