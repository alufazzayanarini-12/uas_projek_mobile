import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/goal_provider.dart';
import 'add_transaction_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final themeColor = Color(category.colorValue);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Info Umum
            _buildGeneralHeader(fmt, themeColor),
            
            // UI KHUSUS BERDASARKAN KATEGORI
            if (category.name.toLowerCase().contains('hutang'))
              _buildHutangUI(fmt, themeColor)
            else if (category.name.toLowerCase().contains('tabungan'))
              _buildTabunganUI(context, fmt, themeColor)
            else if (category.name.toLowerCase().contains('pendidikan'))
              _buildPendidikanUI(fmt, themeColor)
            else if (category.name.toLowerCase().contains('bulanan'))
              _buildMonthlyUI(fmt, themeColor)
            else if (category.name.toLowerCase().contains('darurat'))
              _buildEmergencyUI(fmt, themeColor)
            else if (category.name.toLowerCase().contains('saku'))
              _buildPocketMoneyUI(fmt, themeColor)
            else
              _buildGenericUI(fmt, themeColor),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final accounts = Provider.of<AccountProvider>(context, listen: false).accounts;
          if (accounts.isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddTransactionScreen(account: accounts.first)
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Silakan buat rekening terlebih dahulu!'))
            );
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
      child: Column(
        children: [
          const Text('Total Pengeluaran Bulan Ini', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Rp 1.250.000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: const Text('Limit: Rp 2.000.000', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── 1. HUTANG UI ──
  Widget _buildHutangUI(NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Hutang Saya', 'Rp 500k', Colors.red)),
              const SizedBox(width: 15),
              Expanded(child: _buildSummaryCard('Piutang', 'Rp 1.2M', Colors.green)),
            ],
          ),
          const SizedBox(height: 25),
          const Text('Daftar Kontak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          _buildDebtItem('Nia (Hutang)', 'Rp 100.000', '12 Mei', 0.5),
          _buildDebtItem('Wulan (Piutang)', 'Rp 1.000.000', '20 Juni', 0.2),
        ],
      ),
    );
  }

  // ── 2. TABUNGAN UI ──
  Widget _buildTabunganUI(BuildContext context, NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Tabungan Aktif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          _buildGoalMiniCard('Beli Laptop', 0.75, 'Rp 7.500.000 / 10M'),
          _buildGoalMiniCard('Liburan Bali', 0.30, 'Rp 1.500.000 / 5M'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
            child: const Row(
              children: [
                Icon(Icons.auto_graph, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(child: Text('Estimasi Tercapai: 4 Bulan lagi berdasarkan rata-rata setoran kamu.', style: TextStyle(fontSize: 12, color: Colors.blue))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. PENDIDIKAN UI ──
  Widget _buildPendidikanUI(NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Anggaran vs Realisasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          _buildBudgetLine('SPP / UKT', 1.0, 'Lunas'),
          _buildBudgetLine('Buku & Alat Tulis', 0.4, 'Rp 200k / 500k'),
          _buildBudgetLine('Les / Kursus', 0.0, 'Belum Bayar'),
          const SizedBox(height: 20),
          const Text('Jadwal Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ListTile(
            leading: const Icon(Icons.event, color: Colors.orange),
            title: const Text('Bayar Kursus Bahasa Inggris'),
            subtitle: const Text('Tenggat: 15 Mei 2024'),
            trailing: TextButton(onPressed: () {}, child: const Text('BAYAR')),
          ),
        ],
      ),
    );
  }

  // ── 4. UANG BULANAN UI ──
  Widget _buildMonthlyUI(NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alokasi Kebutuhan Pokok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          _buildSimpleTile(Icons.shopping_cart, 'Belanja Dapur', 'Sisa: Rp 300.000'),
          _buildSimpleTile(Icons.electric_bolt, 'Listrik & Air', 'Sudah Dibayar'),
          _buildSimpleTile(Icons.local_gas_station, 'Bensin', 'Rp 450.000 terpakai'),
          const SizedBox(height: 20),
          // Warning Limit
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(15)),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 10),
                Expanded(child: Text('Peringatan: Pengeluaran bulanan kamu sudah mencapai 85%!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. DANA DARURAT UI ──
  Widget _buildEmergencyUI(NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const Text('Target Ideal Dana Darurat', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Rp 15.000.000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                const Text('(Pengeluaran x 6 Bulan)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text('Kondisi Saat Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          _buildGoalMiniCard('Dana Darurat', 0.45, 'Rp 6.750.000 / 15M'),
          const SizedBox(height: 20),
          const Divider(),
          const Text('Catatan: Dana ini hanya untuk keadaan mendesak!', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
        ],
      ),
    );
  }

  // ── 6. UANG SAKU UI ──
  Widget _buildPocketMoneyUI(NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jatah Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Rp 50.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            ],
          ),
          const SizedBox(height: 15),
          _buildSimpleTile(Icons.coffee, 'Nongkrong & Kopi', 'Terpakai: Rp 25.000'),
          _buildSimpleTile(Icons.movie, 'Hiburan / Bioskop', 'Belum ada'),
          _buildSimpleTile(Icons.shopping_bag, 'Belanja Hobi', 'Terpakai: Rp 150.000'),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
              child: const Text('Transfer Sisa ke Tabungan'),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPER WIDGETS ──
  Widget _buildSummaryCard(String title, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: col.withOpacity(0.3))),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: col, fontWeight: FontWeight.bold)),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: col)),
        ],
      ),
    );
  }

  Widget _buildDebtItem(String name, String amount, String date, double prog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jatuh Tempo: $date'),
            const SizedBox(height: 5),
            LinearProgressIndicator(value: prog, color: Colors.red),
          ],
        ),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      ),
    );
  }

  Widget _buildGoalMiniCard(String title, double prog, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: prog, minHeight: 8, borderRadius: BorderRadius.circular(5)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBudgetLine(String title, double prog, String trailing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text(trailing, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: prog, minHeight: 5, borderRadius: BorderRadius.circular(5)),
        ],
      ),
    );
  }

  Widget _buildSimpleTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildGenericUI(NumberFormat fmt, Color color) {
    return const Padding(
      padding: EdgeInsets.all(40.0),
      child: Center(child: Text('Belum ada detail khusus untuk kategori ini.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
    );
  }
}
