import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';

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
    final settings = Provider.of<SettingsProvider>(context);
    double currentSaved = catProvider.savingsCurrent;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(settings.translate('tabungan_saya'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  const Icon(Icons.savings_outlined, size: 80, color: Colors.pink),
                  const SizedBox(height: 15),
                  Text(settings.translate('uang_hasil_tabungan'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 10),
                  Text(fmt.format(currentSaved), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _buildClickableTile(Icons.auto_awesome, settings.translate('uang_tabungan_bulanan'), settings.translate('uang_tabungan_bulanan_desc'), Colors.pink, () => _showMonthlySavingsSettings(catProvider)),
            _buildClickableTile(Icons.history, settings.translate('riwayat_menabung'), settings.translate('riwayat_menabung_desc'), Colors.pink, () => _showSavingHistory(catProvider)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _showTopUpDialog(catProvider),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(settings.translate('tambah_saldo'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUpDialog(CategoryProvider catProvider) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final topUpController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 25, top: 25, left: 25, right: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(settings.translate('tambah_saldo_tabungan'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: topUpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: settings.translate('nominal_top_up'), prefixText: 'Rp ', border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  double amount = double.tryParse(topUpController.text) ?? 0.0;
                  if (amount > 0) {
                    catProvider.addSavingsTransaction('Tambah Saldo Tabungan', amount);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(settings.translate('berhasil_menambah_saldo').replaceAll('{amount}', fmt.format(amount))),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(settings.translate('lanjutkan_pembayaran'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavingHistory(CategoryProvider catProvider) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final history = catProvider.savingsHistory;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Text(settings.translate('riwayat_menabung'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const Divider(height: 30),
            Expanded(
              child: history.isEmpty
                  ? Center(child: Text(settings.translate('belum_ada_riwayat_menabung'), style: const TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final amount = item['amount'] as double;
                        final dateStr = item['date'] as String;
                        DateTime? dateParsed = DateTime.tryParse(dateStr);
                        String formattedDate = 'Hari ini';
                        if (dateParsed != null) {
                          formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dateParsed);
                        }
                        return _buildHistoryItem(
                          item['title'] ?? 'Top Up',
                          formattedDate,
                          fmt.format(amount),
                          item['status'] ?? settings.translate('berhasil_menabung'),
                          Colors.green,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthlySavingsSettings(CategoryProvider catProvider) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          top: 25,
          left: 25,
          right: 25,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              settings.translate('uang_tabungan_bulanan'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              settings.translate('uang_tabungan_bulanan_desc'),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [5000, 10000, 20000, 30000, 50000, 100000].map((nominal) {
                return InkWell(
                  onTap: () {
                    controller.text = nominal.toString();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink[100]!),
                    ),
                    child: Text(
                      fmt.format(nominal),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                labelText: settings.translate('nominal_tabungan'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  double amount = double.tryParse(controller.text) ?? 0.0;
                  if (amount > 0) {
                    catProvider.addSavingsTransaction('Uang Tabungan Bulanan', amount);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(settings.translate('berhasil_menabung').replaceAll('{amount}', fmt.format(amount))),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(settings.translate('simpan_dan_nabung'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableTile(IconData icon, String title, String status, Color color, VoidCallback onTap) {
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: ListTile(leading: Icon(icon, color: color), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(status, style: TextStyle(color: color, fontSize: 11)), trailing: const Icon(Icons.chevron_right, size: 20), onTap: onTap));
  }

  Widget _buildHistoryItem(String title, String date, String amount, String status, Color statusColor) {
    return ListTile(contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text('$date • $status', style: TextStyle(fontSize: 11, color: statusColor)), trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)));
  }
}
