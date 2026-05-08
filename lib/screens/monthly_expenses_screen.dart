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
  
  // Data Sub-Kategori Dinamis
  List<Map<String, dynamic>> subCategories = [
    {'name': 'Makan & Minum', 'budget': 1500000.0, 'spent': 600000.0, 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Transportasi', 'budget': 500000.0, 'spent': 200000.0, 'icon': Icons.directions_car, 'color': Colors.blue},
    {'name': 'Tagihan (Listrik/WiFi)', 'budget': 1000000.0, 'spent': 400000.0, 'icon': Icons.receipt_long, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
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
            // ── DASHBOARD KESEHATAN ──
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.05), blurRadius: 20)]),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Health Meter Budget', style: TextStyle(fontWeight: FontWeight.bold)), Icon(Icons.monitor_heart, color: healthColor)]),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 140, height: 140, child: CircularProgressIndicator(value: healthPercentage, strokeWidth: 12, backgroundColor: Colors.grey[100], color: healthColor)),
                      Column(children: [Text('${(healthPercentage * 100).toInt()}%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: healthColor)), const Text('Terpakai', style: TextStyle(fontSize: 10, color: Colors.grey))])
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(healthPercentage >= 0.9 ? '⚠️ Anggaran Hampir Habis!' : '✅ Kondisi Keuangan Sehat', style: TextStyle(fontWeight: FontWeight.bold, color: healthColor)),
                  const Divider(height: 30),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildMiniStat('Budget Total', fmt.format(totalBudget)), _buildMiniStat('Sisa Saldo', fmt.format(totalBudget - spentSoFar))])
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Alokasi Sub-Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Klik item untuk bayar atau edit budget', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 15),
            ...subCategories.asMap().entries.map((entry) => _buildSubCatTile(entry.key, entry.value, catProvider)).toList(),

            const SizedBox(height: 30),
            _buildActionTile(Icons.bar_chart, 'Analisis Pengeluaran Harian', 'Lihat di tanggal mana Anda paling boros', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCatTile(int index, Map<String, dynamic> cat, CategoryProvider provider) {
    double progress = cat['spent'] / cat['budget'];
    return GestureDetector(
      onTap: () => _showSubCatDetail(index, cat, provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: progress > 0.9 ? Colors.red.withOpacity(0.3) : Colors.transparent)),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: cat['color'].withOpacity(0.1), child: Icon(cat['icon'], color: cat['color'], size: 20)),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text('${fmt.format(cat['spent'])} / ${fmt.format(cat['budget'])}', style: const TextStyle(fontSize: 10, color: Colors.grey))])),
                Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: progress > 0.9 ? Colors.red : Colors.teal)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress > 1.0 ? 1.0 : progress, backgroundColor: Colors.grey[100], color: progress > 0.9 ? Colors.red : cat['color'], minHeight: 6),
            ),
          ],
        ),
      ),
    );
  }

  // ── MODAL DETAIL SUB-KATEGORI ──
  void _showSubCatDetail(int index, Map<String, dynamic> cat, CategoryProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Detail ${cat['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => _showEditBudget(index, cat), icon: const Icon(Icons.settings_outlined, size: 20)),
              ]),
              const Divider(height: 30),
              
              // Grafik Harian Mini
              const Align(alignment: Alignment.centerLeft, child: Text('Pengeluaran 7 Hari Terakhir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              const SizedBox(height: 15),
              SizedBox(height: 100, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end, children: [
                _buildBar(40, 'Sen'), _buildBar(70, 'Sel'), _buildBar(30, 'Rab'), _buildBar(90, 'Kam'), _buildBar(50, 'Jum'), _buildBar(20, 'Sab'), _buildBar(10, 'Min'),
              ])),
              const SizedBox(height: 30),

              const Align(alignment: Alignment.centerLeft, child: Text('Transaksi Terakhir', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: ListView(children: [
                _buildTxItem('Makan Siang Warteg', 'Tadi Siang', 'Rp 25.000'),
                _buildTxItem('Bensin Pertalite', 'Kemarin', 'Rp 50.000'),
                _buildTxItem('Belanja Bulanan', '2 hari lalu', 'Rp 250.000'),
              ])),
              
              // TOMBOL BAYAR SEKARANG
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentOptions(index, cat, provider),
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text('BAYAR SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions(int index, Map<String, dynamic> cat, CategoryProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(leading: const Icon(Icons.qr_code, color: Colors.teal), title: const Text('Scan QRIS Merchant'), onTap: () => _processPayment(index, 50000, provider)),
            ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text('Input Manual (Tunai)'), onTap: () => _processPayment(index, 15000, provider)),
            if (cat['name'].contains('Tagihan'))
              ListTile(leading: const Icon(Icons.receipt_long, color: Colors.purple), title: const Text('Bayar Tagihan Aktif'), onTap: () => _processPayment(index, 350000, provider)),
          ],
        ),
      ),
    );
  }

  void _processPayment(int index, double amount, CategoryProvider provider) {
    setState(() {
      subCategories[index]['spent'] += amount;
      provider.monthlySpent += amount;
      provider.notifyListeners();
    });
    Navigator.pop(context); // Tutup opsi bayar
    Navigator.pop(context); // Tutup detail
    
    // Notifikasi Pintar
    double progress = subCategories[index]['spent'] / subCategories[index]['budget'];
    if (progress > 0.9) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('⚠️ Budget ${subCategories[index]['name']} hampir habis! Yuk lebih hemat.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.teal, content: Text('Pembayaran ${fmt.format(amount)} berhasil! Budget ter-update.')));
    }
  }

  void _showEditBudget(int index, Map<String, dynamic> cat) {
    // Logic edit alokasi budget
  }

  Widget _buildBar(double height, String label) {
    return Column(children: [Container(width: 15, height: height, decoration: BoxDecoration(color: Colors.teal[200], borderRadius: BorderRadius.circular(5))), const SizedBox(height: 5), Text(label, style: const TextStyle(fontSize: 8))]);
  }

  Widget _buildTxItem(String title, String date, String price) {
    return ListTile(contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), subtitle: Text(date, style: const TextStyle(fontSize: 10)), trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)));
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]);
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: Colors.teal[700]), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)), trailing: const Icon(Icons.chevron_right, size: 20), tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), onTap: onTap);
  }
}
