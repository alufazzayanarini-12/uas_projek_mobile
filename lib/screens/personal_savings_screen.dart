import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class PersonalSavingsScreen extends StatefulWidget {
  const PersonalSavingsScreen({super.key});

  @override
  State<PersonalSavingsScreen> createState() => _PersonalSavingsScreenState();
}

class _PersonalSavingsScreenState extends State<PersonalSavingsScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  bool isRoundUpActive = true;
  int roundUpLevel = 5000;
  String selectedMethod = 'E-Wallet';

  @override
  Widget build(BuildContext context) {
    // SINKRONISASI DATA DARI PROVIDER
    final catProvider = Provider.of<CategoryProvider>(context);
    double targetAmount = catProvider.savingsTarget;
    double currentSaved = catProvider.savingsCurrent;
    double progress = currentSaved / targetAmount;
    double remaining = targetAmount - currentSaved;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Tabungan Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 20)]),
              child: Column(
                children: [
                  const Icon(Icons.savings_outlined, size: 70, color: Colors.pink),
                  const SizedBox(height: 15),
                  const Text('Target: Beli HP Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Sisa ${fmt.format(remaining < 0 ? 0 : remaining)} lagi', style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: progress > 1.0 ? 1.0 : progress, backgroundColor: Colors.pink[50], color: Colors.pink, minHeight: 10),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${((progress > 1.0 ? 1.0 : progress) * 100).toInt()}% Tercapai', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Target: ${fmt.format(targetAmount)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Terkumpul: ${fmt.format(currentSaved)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _buildClickableTile(Icons.auto_awesome, 'Fitur Round-up', isRoundUpActive ? 'Aktif (Kelipatan ${fmt.format(roundUpLevel)})' : 'Nonaktif', Colors.pink, () => _showRoundUpSettings()),
            _buildClickableTile(Icons.history, 'Riwayat Menabung', 'Lihat detail transaksi', Colors.pink, () => _showSavingHistory(catProvider)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _showTopUpDialog(catProvider),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('TAMBAH SALDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUpDialog(CategoryProvider catProvider) {
    final topUpController = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => StatefulBuilder(builder: (context, setModalState) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 25, top: 25, left: 25, right: 25), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Tambah Saldo Tabungan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 20), TextField(controller: topUpController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal Top Up', prefixText: 'Rp ', border: OutlineInputBorder())), const SizedBox(height: 25), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { double amount = double.tryParse(topUpController.text) ?? 0.0; catProvider.savingsCurrent += amount; catProvider.notifyListeners(); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('LANJUTKAN PEMBAYARAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),)],),),),);
  }

  void _showSavingHistory(CategoryProvider catProvider) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => Container(padding: const EdgeInsets.all(25), child: Column(children: [const Text('Riwayat Menabung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Divider(height: 30), Expanded(child: ListView(children: [_buildHistoryItem('Top Up via (+)', 'Hari ini', 'Rp 0', 'Berhasil', Colors.green)],))],),),);
  }

  void _showRoundUpSettings() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => StatefulBuilder(builder: (context, setModalState) => Container(padding: const EdgeInsets.all(25), child: Column(mainAxisSize: MainAxisSize.min, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Fitur Round-up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Switch(value: isRoundUpActive, activeColor: Colors.pink, onChanged: (val) { setState(() => isRoundUpActive = val); setModalState(() {}); }),],), RadioListTile(title: const Text('Rp 5.000'), value: 5000, groupValue: roundUpLevel, onChanged: (val) { setState(() => roundUpLevel = val as int); setModalState(() {}); }),],),)));
  }

  Widget _buildClickableTile(IconData icon, String title, String status, Color color, VoidCallback onTap) {
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: ListTile(leading: Icon(icon, color: color), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(status, style: TextStyle(color: color, fontSize: 11)), trailing: const Icon(Icons.chevron_right, size: 20), onTap: onTap));
  }

  Widget _buildHistoryItem(String title, String date, String amount, String status, Color statusColor) {
    return ListTile(contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text('$date • $status', style: TextStyle(fontSize: 11, color: statusColor)), trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)));
  }
}
