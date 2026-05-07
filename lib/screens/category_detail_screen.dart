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
  // ── DATA DUMMY HUTANG & PIUTANG ──
  final List<Map<String, dynamic>> _debtList = [
    {
      'name': 'Nia (Hutang)', 
      'total': 500000, 
      'paid': 150000, 
      'date': '12 Mei', 
      'type': 'hutang',
      'history': <Map<String, dynamic>>[{'date': '01 Mei', 'amount': 150000}]
    },
    {
      'name': 'Wulan (Piutang)', 
      'total': 1500000, 
      'paid': 500000, 
      'date': '20 Juni', 
      'type': 'piutang',
      'history': <Map<String, dynamic>>[{'date': '15 Apr', 'amount': 500000}]
    },
  ];

  final List<Map<String, dynamic>> _eduItems = [
    {'name': 'Uang Kuliah Sem. 5', 'target': 4500000, 'saved': 1500000, 'deadline': '15 Aug'},
  ];

  final TextEditingController _inputController = TextEditingController();

  void _addPayment(int index, double amount) {
    setState(() {
      _debtList[index]['paid'] += amount;
      (_debtList[index]['history'] as List).insert(0, {
        'date': DateFormat('dd MMM').format(DateTime.now()),
        'amount': amount,
      });
    });
    _inputController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cicilan berhasil dicatat! ✅'), backgroundColor: Colors.green),
    );
  }

  void _markAsLunas(int index) {
    setState(() {
      _debtList[index]['paid'] = _debtList[index]['total'];
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status: LUNAS! 🎉'), backgroundColor: Colors.blue),
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
            else if (widget.category.name.toLowerCase().contains('pendidikan'))
              _buildPendidikanUI(context, fmt, themeColor)
            else
              _buildGenericUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralHeader(NumberFormat fmt, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
      child: const Column(children: [Text('Manajemen Keuangan', style: TextStyle(color: Colors.white70, fontSize: 14)), SizedBox(height: 8), Text('Detail Catatan', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))]),
    );
  }

  // ── UI HUTANG (NIA & WULAN) ──
  Widget _buildHutangUI(BuildContext context, NumberFormat fmt, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daftar Pinjaman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          ...List.generate(_debtList.length, (index) {
            final item = _debtList[index];
            double progress = item['paid'] / item['total'];
            return _buildDebtCard(context, index, item, fmt, color, progress);
          }),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, int index, Map<String, dynamic> item, NumberFormat fmt, Color color, double progress) {
    bool isLunas = item['paid'] >= item['total'];
    return GestureDetector(
      onTap: () => _showDebtDetailModal(context, index, item, fmt, color),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: isLunas ? Colors.green.withOpacity(0.3) : color.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isLunas) const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress > 1.0 ? 1.0 : progress, minHeight: 6, color: isLunas ? Colors.green : color, backgroundColor: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sisa: ${fmt.format(item['total'] - item['paid'])}', style: TextStyle(fontWeight: FontWeight.bold, color: isLunas ? Colors.green : Colors.red, fontSize: 13)),
                Text('Tempo: ${item['date']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDebtDetailModal(BuildContext context, int index, Map<String, dynamic> item, NumberFormat fmt, Color color) {
    double sisa = item['total'] - item['paid'];
    bool isLunas = sisa <= 0;

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
            Text('Detail: ${item['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 15),
            
            // ── RINGKASAN SALDO ──
            Row(
              children: [
                Expanded(child: _buildInfoBox('Total Tagihan', fmt.format(item['total']), Colors.grey)),
                const SizedBox(width: 15),
                Expanded(child: _buildInfoBox('Sisa Saldo', fmt.format(sisa), isLunas ? Colors.green : Colors.red)),
              ],
            ),
            
            const SizedBox(height: 25),
            if (!isLunas) ...[
              const Text('Aksi Cepat', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildActionButton(Icons.payment, 'Cicil', Colors.blue, () => _showCicilInput(context, index))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildActionButton(Icons.done_all, 'Lunas', Colors.green, () => _markAsLunas(index))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildActionButton(Icons.message, 'Tagih WA', Colors.teal, () => _sendWhatsApp(item, fmt))),
                ],
              ),
            ],
            
            const SizedBox(height: 25),
            const Text('Riwayat Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView(
                shrinkWrap: true,
                children: (item['history'] as List).map<Widget>((h) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, size: 16),
                  title: Text(fmt.format(h['amount'])),
                  trailing: Text(h['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                )).toList(),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showCicilInput(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Masukkan Nominal Cicilan'),
        content: TextField(controller: _inputController, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rp ')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () => _addPayment(index, double.parse(_inputController.text)), child: const Text('Simpan')),
        ],
      ),
    );
  }

  void _sendWhatsApp(Map<String, dynamic> item, NumberFormat fmt) async {
    String message = "Halo ${item['name']}, sekedar mengingatkan tagihan ${item['type']} sebesar ${fmt.format(item['total'] - item['paid'])}. Terima kasih.";
    String url = "https://wa.me/?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildInfoBox(String title, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: col.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: col.withOpacity(0.2))),
      child: Column(children: [Text(title, style: TextStyle(fontSize: 11, color: col)), Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: col))]),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color col, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, color: col, size: 20), const SizedBox(height: 5), Text(label, style: TextStyle(fontSize: 10, color: col, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildPendidikanUI(BuildContext context, NumberFormat fmt, Color color) {
    return const Padding(padding: EdgeInsets.all(40.0), child: Center(child: Text('Fitur Pendidikan Aktif.')));
  }

  Widget _buildGenericUI() {
    return const Padding(padding: EdgeInsets.all(40.0), child: Center(child: Text('Kategori ini menggunakan tampilan standar.')));
  }
}
