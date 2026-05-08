import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({super.key});

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Data Hutang Dinamis
  List<Map<String, dynamic>> debts = [
    {'name': 'Nia', 'total': 2000000.0, 'remaining': 800000.0, 'installments': 2, 'color': Colors.orange},
    {'name': 'Wulan', 'total': 5000000.0, 'remaining': 3500000.0, 'installments': 4, 'color': Colors.red},
  ];

  List<Map<String, dynamic>> paymentHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manajemen Hutang', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDebtHeader('Daftar Kontak & Hutang'),
            ...debts.asMap().entries.map((entry) {
              int idx = entry.key;
              var d = entry.value;
              double progress = 1 - ((d['remaining'] as num) / (d['total'] as num)).toDouble();
              return _buildDebtCard(idx, d['name'], fmt.format(d['total']), progress, fmt.format(d['remaining']), d['color'], '${d['installments']}x');
            }).toList(),

            const SizedBox(height: 25),
            _buildDebtHeader('Jatuh Tempo Terdekat'),
            _buildDueItem('Nia', '15 Mei 2026', 'Rp 400.000 (Cicilan 3)'),
            _buildDueItem('Wulan', '20 Mei 2026', 'Rp 1.000.000 (Cicilan 1)'),
            const SizedBox(height: 25),
            _buildDebtHeader('Opsi Lainnya'),
            
            _buildOptionTile(
              Icons.history, 
              'Riwayat Cicilan', 
              '${paymentHistory.length} catatan pembayaran',
              onTap: () => _showHistoryBottomSheet(),
            ),
            _buildOptionTile(
              Icons.person_add_outlined, 
              'Tambah Kontak', 
              'Catat hutang baru',
              onTap: () => _showAddDebtDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtCard(int index, String name, String total, double progress, String remaining, Color color, String remInstallments) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(total, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.1), color: color, minHeight: 8),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sisa: $remaining', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () => _showPaymentDialog(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3F2FD),
                  foregroundColor: Colors.blue[700],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Bayar Cicilan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text('Sisa Cicilan: $remInstallments', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAddDebtDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final installmentController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Catat Hutang Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Kontak')),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Hutang (Rp)')),
            TextField(controller: installmentController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Cicilan')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                setState(() {
                  debts.add({
                    'name': nameController.text,
                    'total': double.parse(amountController.text),
                    'remaining': double.parse(amountController.text),
                    'installments': int.parse(installmentController.text),
                    'color': Colors.blueGrey,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kontak baru berhasil ditambahkan!')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(int index) {
    final debt = debts[index];
    final nominalController = TextEditingController(text: '400000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text('Bayar Cicilan ${debt['name']}', style: const TextStyle(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Sisa Hutang', fmt.format(debt['remaining'])),
            _buildInfoRow('Sisa Cicilan', '${debt['installments']}x'),
            const SizedBox(height: 15),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nominal Bayar (Rp)', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              double payAmount = double.tryParse(nominalController.text) ?? 0.0;
              setState(() {
                debts[index]['remaining'] -= payAmount;
                if (debts[index]['installments'] > 0) debts[index]['installments'] -= 1;
                if (debts[index]['remaining'] < 0) debts[index]['remaining'] = 0;
                paymentHistory.insert(0, {'name': debt['name'], 'amount': payAmount, 'date': DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())});
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Pembayaran Cicilan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            Expanded(
              child: paymentHistory.isEmpty
                  ? const Center(child: Text('Belum ada riwayat pembayaran', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: paymentHistory.length,
                      itemBuilder: (context, i) {
                        final h = paymentHistory[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: Colors.green[50], child: const Icon(Icons.check, color: Colors.green, size: 18)),
                          title: Text('Bayar ke ${h['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(h['date'], style: const TextStyle(fontSize: 11)),
                          trailing: Text(fmt.format(h['amount']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]));
  }

  Widget _buildDueItem(String name, String date, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue[50]!, shape: BoxShape.circle), child: const Icon(Icons.calendar_month, color: Colors.blue, size: 20)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
          Text(desc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A237E)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onTap: onTap,
    );
  }
}
