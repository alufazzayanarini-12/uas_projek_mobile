import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class MonthlyExpensesScreen extends StatefulWidget {
  const MonthlyExpensesScreen({super.key});

  @override
  State<MonthlyExpensesScreen> createState() => _MonthlyExpensesScreenState();
}

class _MonthlyExpensesScreenState extends State<MonthlyExpensesScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  // Data Sub-Kategori (Mock, bisa disambungkan ke DB nanti)
  List<Map<String, dynamic>> subCategories = [
    {'name': 'Makan & Minum', 'budget': 1500000, 'spent': 600000, 'icon': Icons.restaurant},
    {'name': 'Transportasi', 'budget': 500000, 'spent': 200000, 'icon': Icons.directions_car},
    {'name': 'Tagihan (Listrik/WiFi)', 'budget': 1000000, 'spent': 400000, 'icon': Icons.receipt_long},
  ];

  @override
  Widget build(BuildContext context) {
    // SINKRONISASI DATA DARI PROVIDER
    final catProvider = Provider.of<CategoryProvider>(context);
    double totalBudget = catProvider.monthlyBudget;
    double spentSoFar = catProvider.monthlySpent;
    
    double healthPercentage = spentSoFar / totalBudget;
    if (healthPercentage > 1.0) healthPercentage = 1.0;
    
    Color healthColor = healthPercentage > 0.8 ? Colors.red : (healthPercentage > 0.5 ? Colors.orange : Colors.teal);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Uang Bulanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SMART MONITORING DASHBOARD (REAL-TIME) ──
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.05), blurRadius: 20)]),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Health Meter Anggaran', style: TextStyle(fontWeight: FontWeight.bold)), Icon(Icons.monitor_heart, color: healthColor)]),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 130, height: 130, child: CircularProgressIndicator(value: healthPercentage, strokeWidth: 10, backgroundColor: Colors.grey[200], color: healthColor)),
                      Column(children: [Text('${(healthPercentage * 100).toInt()}%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: healthColor)), const Text('Terpakai', style: TextStyle(fontSize: 10, color: Colors.grey))])
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(healthPercentage >= 0.9 ? '⚠️ Anggaran Hampir Habis!' : '✅ Budget Masih Aman', style: TextStyle(fontWeight: FontWeight.bold, color: healthColor, fontSize: 13)),
                  const Divider(height: 30),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildMiniStat('Target Budget', fmt.format(totalBudget)), _buildMiniStat('Terpakai', fmt.format(spentSoFar))])
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Alokasi Sub-Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            ...subCategories.map((cat) => _buildSubCatTile(cat)).toList(),

            const SizedBox(height: 30),
            _buildActionTile(Icons.notifications_active_outlined, 'Auto-Tagihan Rutin', 'Kelola tagihan bulanan Anda', () {}),
            _buildActionTile(Icons.bar_chart, 'Analisis Budget vs Realita', 'Lihat laporan pengeluaran', () {}),
            const SizedBox(height: 10),
            const Center(child: Text('Data akan terupdate otomatis via tombol (+)', style: TextStyle(color: Colors.grey, fontSize: 11))),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCatTile(Map<String, dynamic> cat) {
    double progress = cat['spent'] / cat['budget'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.teal[50], child: Icon(cat['icon'], color: Colors.teal, size: 18)),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text('${fmt.format(cat['spent'])} / ${fmt.format(cat['budget'])}', style: const TextStyle(fontSize: 10, color: Colors.grey))])),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.teal[50], color: Colors.teal, minHeight: 4),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]);
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: onTap,
      ),
    );
  }
}
