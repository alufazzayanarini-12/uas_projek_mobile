import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import 'add_account_screen.dart';
import 'account_detail_screen.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tabunganku', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1A237E)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer2<AccountProvider, TransactionProvider>(
        builder: (context, accProvider, txProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 15),
              _buildModernProfileCard(accProvider.totalBalance, fmt),
              const SizedBox(height: 30),
              _buildSectionHeader('Daftar Rekening', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAccountScreen()))),
              const SizedBox(height: 15),
              ...accProvider.accounts.map((acc) => _buildAccountCard(acc, fmt)).toList(),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showActionCenter,
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildModernProfileCard(double total, NumberFormat fmt) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        String initials = settings.userName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase();
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.white24, radius: 22, child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => _showEditProfileModal(context, settings),
                    child: Text(settings.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(fmt.format(total), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountCard(Account account, NumberFormat fmt) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(account: account))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Color(account.colorValue).withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(IconData(account.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(account.colorValue))),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const Text('Saldo tersedia', style: TextStyle(fontSize: 11, color: Colors.grey))])),
            Text(fmt.format(account.balance), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8E99AF))), IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1A237E)), onPressed: onAdd)]);
  }

  void _showActionCenter() {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final accProvider = Provider.of<AccountProvider>(context, listen: false);
    
    // Hitung Ringkasan Bulan Ini
    double income = 0;
    double expense = 0;
    final now = DateTime.now();
    for (var tx in txProvider.transactions) {
      if (tx.date.month == now.month && tx.date.year == now.year) {
        if (tx.type == 'deposit') income += tx.amount; else expense += tx.amount;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text('Pusat Aksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            // ── RINGKASAN CEPAT ──
            Row(
              children: [
                _buildSummaryBox('Pemasukan', income, Colors.green),
                const SizedBox(width: 15),
                _buildSummaryBox('Pengeluaran', expense, Colors.red),
              ],
            ),
            const SizedBox(height: 35),
            // ── MENU UTAMA ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionMenu(Icons.south_west, 'Setor', Colors.green, () {
                  Navigator.pop(context);
                  if (accProvider.accounts.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen(account: accProvider.accounts.first)));
                }),
                _buildActionMenu(Icons.north_east, 'Tarik', Colors.red, () {}),
                _buildActionMenu(Icons.sync_alt, 'Kirim', Colors.blue, () {}),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            _buildListAction(Icons.picture_as_pdf, 'Unduh Laporan (PDF)', Colors.orange),
            _buildListAction(Icons.track_changes, 'Set Target Tabungan', Colors.purple),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String label, double amount, Color color) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(fmt.format(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(IconData icon, String label, Color col, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: col.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: col, size: 28)),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildListAction(IconData icon, String title, Color col) {
    return ListTile(
      leading: Icon(icon, color: col),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }

  void _showEditProfileModal(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.userName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 25, left: 25, right: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ganti Nama Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Nama Baru', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () { settings.setUserName(controller.text); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)), child: const Text('SIMPAN', style: TextStyle(color: Colors.white)))),
          ],
        ),
      ),
    );
  }
}
