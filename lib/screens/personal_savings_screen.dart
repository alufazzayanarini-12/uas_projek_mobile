import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonalSavingsScreen extends StatefulWidget {
  const PersonalSavingsScreen({super.key});

  @override
  State<PersonalSavingsScreen> createState() => _PersonalSavingsScreenState();
}

class _PersonalSavingsScreenState extends State<PersonalSavingsScreen> {
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  // Data Tabungan Dinamis
  double targetAmount = 5000000;
  double currentSaved = 1500000;
  
  bool isRoundUpActive = true;
  int roundUpLevel = 5000;
  String selectedMethod = 'E-Wallet'; // Default metode pembayaran

  @override
  Widget build(BuildContext context) {
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
            // ── HEADER DASHBOARD (DINAMIS) ──
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 20)]),
              child: Column(
                children: [
                  const Icon(Icons.savings_outlined, size: 70, color: Colors.pink),
                  const SizedBox(height: 15),
                  const Text('Target: Beli HP Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  
                  // MENAMPILKAN SISA SECARA OTOMATIS
                  Text('Sisa ${fmt.format(remaining < 0 ? 0 : remaining)} lagi', style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                  
                  TextButton(
                    onPressed: () => _showInstallmentSimulation(remaining),
                    child: const Text('Cek Simulasi Cicilan', style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline)),
                  ),
                  
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress > 1.0 ? 1.0 : progress, 
                      backgroundColor: Colors.pink[50], 
                      color: Colors.pink, 
                      minHeight: 10
                    ),
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
            _buildClickableTile(Icons.history, 'Riwayat Menabung', 'Lihat detail transaksi', Colors.pink, () => _showSavingHistory()),
            _buildClickableTile(Icons.notifications_active_outlined, 'Pengingat Rutin', 'Mingguan', Colors.pink, () {}),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _showTopUpDialog(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('TAMBAH SALDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. MODAL TAMBAH SALDO (DINAMIS)
  void _showTopUpDialog() {
    final topUpController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 25, top: 25, left: 25, right: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tambah Saldo Tabungan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: topUpController,
                keyboardType: TextInputType.number, 
                decoration: const InputDecoration(labelText: 'Nominal Top Up', prefixText: 'Rp ', border: OutlineInputBorder())
              ),
              const SizedBox(height: 20),
              const Align(alignment: Alignment.centerLeft, child: Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              
              // METODE PEMBAYARAN INTERAKTIF
              _buildPaymentOption('Transfer Bank (VA)', Icons.account_balance, selectedMethod == 'Bank', () => setModalState(() => selectedMethod = 'Bank')),
              _buildPaymentOption('E-Wallet (Dana/OVO)', Icons.wallet, selectedMethod == 'E-Wallet', () => setModalState(() => selectedMethod = 'E-Wallet')),
              _buildPaymentOption('Saldo Utama Aplikasi', Icons.payments_outlined, selectedMethod == 'Saldo', () => setModalState(() => selectedMethod = 'Saldo')),
              
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    double amount = double.tryParse(topUpController.text) ?? 0.0;
                    if (amount > 0) {
                      setState(() {
                        currentSaved += amount;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Berhasil menambah ${fmt.format(amount)} via $selectedMethod!'),
                      ));
                    }
                  }, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), 
                  child: const Text('LANJUTKAN PEMBAYARAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.pink[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? Colors.pink : Colors.transparent, width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.pink : Colors.grey),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.pink : Colors.black87)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.pink) : null,
        onTap: onTap,
      ),
    );
  }

  // ── FUNGSI MODAL LAINNYA (HISTORY, ROUNDUP, SIMULATION) TETAP SAMA ──
  void _showInstallmentSimulation(double remaining) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => Container(padding: const EdgeInsets.all(25), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Simulasi Cicilan Tabungan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 20), _buildSimuRow('Jangka Waktu 3 Bulan', fmt.format(remaining / 3)), _buildSimuRow('Jangka Waktu 6 Bulan', fmt.format(remaining / 6)), _buildSimuRow('Jangka Waktu 12 Bulan', fmt.format(remaining / 12)), const Divider(height: 30), Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(15)), child: const Row(children: [Icon(Icons.lightbulb_outline, color: Colors.blue), SizedBox(width: 10), Expanded(child: Text('Saran: Tabung Rp 20.000/hari untuk capai target dalam 6 bulan.', style: TextStyle(fontSize: 12, color: Colors.blue)))],))])));
  }

  void _showRoundUpSettings() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => StatefulBuilder(builder: (context, setModalState) => Container(padding: const EdgeInsets.all(25), child: Column(mainAxisSize: MainAxisSize.min, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Fitur Round-up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Switch(value: isRoundUpActive, activeColor: Colors.pink, onChanged: (val) { setState(() => isRoundUpActive = val); setModalState(() {}); }),],), const Text('Kumpulkan recehan belanja otomatis ke tabungan ini.', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 20), const Align(alignment: Alignment.centerLeft, child: Text('Kelipatan Pembulatan', style: TextStyle(fontWeight: FontWeight.bold))), RadioListTile(title: const Text('Rp 5.000'), value: 5000, groupValue: roundUpLevel, onChanged: (val) { setState(() => roundUpLevel = val as int); setModalState(() {}); }), RadioListTile(title: const Text('Rp 10.000'), value: 10000, groupValue: roundUpLevel, onChanged: (val) { setState(() => roundUpLevel = val as int); setModalState(() {}); }), const Divider(), const Text('Contoh: Belanja Rp 12.200 -> Dibulatkan Rp 15.000. Selisih Rp 2.800 masuk tabungan.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),],),)));
  }

  void _showSavingHistory() {
    String activeFilter = 'Mingguan';
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => StatefulBuilder(builder: (context, setModalState) => Container(height: MediaQuery.of(context).size.height * 0.7, padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Center(child: Text('Riwayat Menabung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), const SizedBox(height: 25), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['Mingguan', 'Bulanan', 'Custom'].map((filter) => ChoiceChip(label: Text(filter), selected: activeFilter == filter, selectedColor: Colors.pink[100], onSelected: (val) { setModalState(() => activeFilter = filter); })).toList(),), const SizedBox(height: 20), Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.pink.withOpacity(0.05), borderRadius: BorderRadius.circular(20)), child: Column(children: [Text('Total Terkumpul ($activeFilter)', style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 5), Text(activeFilter == 'Mingguan' ? 'Rp 202.800' : 'Rp 1.500.000', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink)),],),), const SizedBox(height: 20), const Text('Daftar Transaksi', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: ListView(children: activeFilter == 'Mingguan' ? [_buildHistoryItem('Top Up Manual', '12 Mei 2026', 'Rp 200.000', 'Berhasil', Colors.green), _buildHistoryItem('Round-up Belanja', '10 Mei 2026', 'Rp 2.800', 'Berhasil', Colors.green)] : [_buildHistoryItem('Saldo Awal Bulan', '01 Mei 2026', 'Rp 500.000', 'Berhasil', Colors.green)],),)],),),),);
  }

  Widget _buildClickableTile(IconData icon, String title, String status, Color color, VoidCallback onTap) {
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: ListTile(leading: Icon(icon, color: color), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(status, style: TextStyle(color: color, fontSize: 11)), trailing: const Icon(Icons.chevron_right, size: 20), onTap: onTap));
  }

  Widget _buildSimuRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
  }

  Widget _buildHistoryItem(String title, String date, String amount, String status, Color statusColor) {
    return ListTile(contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text('$date • $status', style: TextStyle(fontSize: 11, color: statusColor)), trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)));
  }
}
