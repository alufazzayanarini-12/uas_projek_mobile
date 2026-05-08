import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyExpensesScreen extends StatefulWidget {
  const MonthlyExpensesScreen({super.key});

  @override
  State<MonthlyExpensesScreen> createState() => _MonthlyExpensesScreenState();
}

class _MonthlyExpensesScreenState extends State<MonthlyExpensesScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  // Data Anggaran
  double totalBudget = 3000000;
  double spentSoFar = 1200000;
  
  // Sub-Kategori
  List<Map<String, dynamic>> subCategories = [
    {'name': 'Makan & Minum', 'budget': 1500000, 'spent': 600000, 'icon': Icons.restaurant},
    {'name': 'Transportasi', 'budget': 500000, 'spent': 200000, 'icon': Icons.directions_car},
    {'name': 'Tagihan (Listrik/WiFi)', 'budget': 1000000, 'spent': 400000, 'icon': Icons.receipt_long},
  ];

  @override
  Widget build(BuildContext context) {
    double healthPercentage = spentSoFar / totalBudget;
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
            // ── HEALTH METER DASHBOARD ──
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
                  Text(healthPercentage > 0.8 ? '⚠️ Segera Hemat!' : '✅ Budget Masih Aman', style: TextStyle(fontWeight: FontWeight.bold, color: healthColor, fontSize: 13)),
                  const Divider(height: 30),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildMiniStat('Target Budget', fmt.format(totalBudget)), _buildMiniStat('Sisa Uang', fmt.format(totalBudget - spentSoFar))])
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Alokasi Sub-Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            ...subCategories.map((cat) => _buildSubCatTile(cat)).toList(),

            const SizedBox(height: 30),
            const Text('Manajemen Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            _buildActionTile(Icons.notifications_active_outlined, 'Auto-Tagihan Rutin', 'WiFi & Listrik akan jatuh tempo', () => _showBillReminders()),
            _buildActionTile(Icons.bar_chart, 'Analisis Budget vs Realita', 'Perbandingan belanja bulan ini', () => _showAnalysis()),
            _buildActionTile(Icons.swap_horiz, 'Pindahkan Sisa Saldo', 'Kirim sisa uang ke Dana Darurat', () => _showTransferOption()),
          ],
        ),
      ),
    );
  }

  // 1. MODAL TAGIHAN
  void _showBillReminders() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tagihan Mendatang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildBillItem('Internet (IndiHome)', 'Rp 350.000', '15 Mei 2026', Colors.blue),
            _buildBillItem('Listrik (PLN)', 'Rp 450.000', '20 Mei 2026', Colors.orange),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), child: const Text('BAYAR SEMUA SEKARANG', style: TextStyle(color: Colors.white)))),
          ],
        ),
      ),
    );
  }

  // 2. MODAL ANALISIS
  void _showAnalysis() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Budget vs Realita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildAnalysisBar('Makan', 0.4),
            _buildAnalysisBar('Hiburan', 0.9), // Contoh boros
            _buildAnalysisBar('Transport', 0.2),
            const SizedBox(height: 15),
            const Text('Saran: Pengeluaran "Hiburan" hampir melewati batas!', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 3. MODAL TRANSFER SISA
  void _showTransferOption() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pindahkan Sisa Saldo?'),
        content: const Text('Sisa saldo bulan ini akan otomatis dipindahkan ke kategori "Dana Darurat" saat tanggal 1 bulan depan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mungkin Nanti')),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), child: const Text('AKTIFKAN AUTO-MOVE', style: TextStyle(color: Colors.white))),
        ],
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

  Widget _buildBillItem(String title, String amount, String date, Color color) {
    return ListTile(
      leading: Icon(Icons.receipt, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('Jatuh tempo: $date', style: const TextStyle(fontSize: 11)),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
    );
  }

  Widget _buildAnalysisBar(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(child: LinearProgressIndicator(value: val, color: val > 0.8 ? Colors.red : Colors.teal, backgroundColor: Colors.grey[200], minHeight: 8)),
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
