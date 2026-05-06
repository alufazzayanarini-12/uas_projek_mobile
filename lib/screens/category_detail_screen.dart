import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/category_model.dart';
import '../providers/account_provider.dart';
import 'add_transaction_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  // Data dummy untuk Hutang
  final Map<String, double> _paidAmounts = {'Nia (Hutang)': 50000, 'Wulan (Piutang)': 100000};
  
  // ── DATA DUMMY UNTUK TABUNGAN SAYA ──
  final List<Map<String, dynamic>> _savingsGoals = [
    {'name': 'Beli HP Baru', 'target': 5000000, 'saved': 1250000, 'daily': 50000},
    {'name': 'Liburan Bali', 'target': 8000000, 'saved': 2000000, 'daily': 100000},
  ];

  final TextEditingController _inputController = TextEditingController();

  void _addSavings(int index, double amount) {
    setState(() {
      _savingsGoals[index]['saved'] += amount;
    });
    _inputController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tabungan berhasil disimpan! 🥳'), backgroundColor: Colors.pinkAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final themeColor = Color(widget.category.colorValue);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGeneralHeader(fmt, themeColor),
            if (widget.category.name.toLowerCase().contains('hutang'))
              _buildHutangUI(context, fmt, themeColor)
            else if (widget.category.name.toLowerCase().contains('tabungan'))
              _buildTabunganUI(context, fmt, themeColor) // ── AKTIFKAN UI TABUNGAN ──
            else
              _buildGenericUI(fmt, themeColor),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final accounts = Provider.of<AccountProvider>(context, listen: false).accounts;
          if (accounts.isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen(account: accounts.first)));
          }
        },
        backgroundColor: themeColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGeneralHeader(NumberFormat fmt, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: const Column(
        children: [
          Text('Fokus Kategori', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          Text('Wujudkan Targetmu!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── UI TABUNGAN SAYA (PINK THEME) ──
  Widget _buildTabunganUI(BuildContext context, NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Menabung (Goals)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 5),
          Text('Klik kartu untuk menambah tabungan', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 20),
          ...List.generate(_savingsGoals.length, (index) {
            final goal = _savingsGoals[index];
            return _buildSavingsGoalCard(context, index, goal, fmt, color);
          }),
          const SizedBox(height: 20),
          _buildProjectionBox(color),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalCard(BuildContext context, int index, Map<String, dynamic> goal, NumberFormat fmt, Color color) {
    double progress = goal['saved'] / goal['target'];
    if (progress > 1.0) progress = 1.0;

    return GestureDetector(
      onTap: () => _showSavingsInputModal(context, index, goal, fmt, color),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Rounded 3xl ala modern
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Icon(Icons.stars, color: color),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Terkumpul: ${fmt.format(goal['saved'])}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                color: color,
                backgroundColor: color.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 15),
            Text('Kurang: ${fmt.format(goal['target'] - goal['saved'])} lagi!', style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  void _showSavingsInputModal(BuildContext context, int index, Map<String, dynamic> goal, NumberFormat fmt, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 25, left: 25, right: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Menabung untuk ${goal['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Masukkan Nominal Tabungan',
                prefixText: 'Rp ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: color, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  double amount = double.tryParse(_inputController.text) ?? 0;
                  if (amount > 0) _addSavings(index, amount);
                },
                style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Text('SIMPAN TABUNGAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionBox(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(25), border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, color: color),
              const SizedBox(width: 10),
              const Text('Proyeksi Masa Depan', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Dengan rata-rata menabungmu, target "Beli HP Baru" akan tercapai dalam 15 hari lagi! Semangat! 🔥', style: TextStyle(fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  // ── UI HUTANG (DARI SEBELUMNYA) ──
  Widget _buildHutangUI(BuildContext context, NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Hutang Saya', 'Rp 100k', Colors.red)),
              const SizedBox(width: 15),
              Expanded(child: _buildSummaryCard('Piutang', 'Rp 1M', Colors.green)),
            ],
          ),
          const SizedBox(height: 25),
          const Text('Daftar Kontak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          _buildDebtItem(context, 'Nia (Hutang)', 200000, '12 Mei', Colors.red, fmt),
          _buildDebtItem(context, 'Wulan (Piutang)', 1500000, '20 Juni', Colors.green, fmt),
        ],
      ),
    );
  }

  Widget _buildDebtItem(BuildContext context, String name, double total, String date, Color color, NumberFormat fmt) {
    double paid = _paidAmounts[name] ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Dibayar: ${fmt.format(paid)}'),
        trailing: Text(fmt.format(total - paid), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Column(children: [Text(title, style: TextStyle(fontSize: 12, color: col)), Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col))]),
    );
  }

  Widget _buildGenericUI(NumberFormat fmt, Color color) {
    return const Padding(padding: EdgeInsets.all(40.0), child: Center(child: Text('Gunakan fitur khusus untuk kategori ini.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))));
  }
}
