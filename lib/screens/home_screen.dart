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
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMenuOpen = false;

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

  void _toggleMenu() => setState(() => _isMenuOpen = !_isMenuOpen);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Tabunganku', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A237E), fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1A237E)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Consumer2<AccountProvider, TransactionProvider>(
            builder: (context, accProvider, txProvider, child) {
              double totalBalance = accProvider.totalBalance;
              final recentTxs = txProvider.transactions.take(10).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  await accProvider.loadAccounts();
                  await txProvider.loadTransactions();
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 10),
                    _buildPremiumBalanceCard(totalBalance, fmt),
                    const SizedBox(height: 35),
                    _buildSectionHeader('Daftar Rekening', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAccountScreen()))),
                    const SizedBox(height: 15),
                    ...accProvider.accounts.map((acc) => _buildModernAccountCard(acc, fmt)).toList(),
                    const SizedBox(height: 35),
                    const Text('Riwayat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8E99AF))),
                    const SizedBox(height: 15),
                    if (recentTxs.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada transaksi.', style: TextStyle(color: Colors.grey))))
                    else
                      ...recentTxs.map((tx) => _buildTransactionItem(tx, fmt, accProvider.accounts)).toList(),
                    const SizedBox(height: 120),
                  ],
                ),
              );
            },
          ),
          if (_isMenuOpen) _buildBlurOverlay(),
        ],
      ),
      floatingActionButton: _buildHomeSpeedDial(),
    );
  }

  Widget _buildPremiumBalanceCard(double total, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF3949AB).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo Tersedia', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => Text(
              settings.isBalanceHidden ? '*******' : fmt.format(total),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Update Terakhir', style: TextStyle(color: Colors.white38, fontSize: 11)),
              Text(DateFormat('dd MMMM yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernAccountCard(Account account, NumberFormat fmt) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(account: account))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
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

  Widget _buildTransactionItem(TransactionModel tx, NumberFormat fmt, List<Account> accounts) {
    final isDeposit = tx.type == 'deposit';
    final acc = accounts.firstWhere((a) => a.id == tx.accountId, orElse: () => Account(name: '?', balance: 0, colorValue: 0, iconCodePoint: 0));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDeposit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), 
            child: Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward, color: isDeposit ? Colors.green : Colors.red, size: 20)
          ),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(acc.name, style: const TextStyle(fontSize: 11, color: Colors.blueGrey))])),
          Text('${isDeposit ? '+' : '-'} ${fmt.format(tx.amount)}', style: TextStyle(fontWeight: FontWeight.bold, color: isDeposit ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8E99AF))), IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3949AB)), onPressed: onAdd)]);
  }

  Widget _buildBlurOverlay() => GestureDetector(onTap: _toggleMenu, child: Container(color: Colors.black.withOpacity(0.3)));

  Widget _buildHomeSpeedDial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isMenuOpen) ...[
          _buildMiniFab(Icons.add_shopping_cart, 'Catat Transaksi', Colors.blue, () => _showGeneralTxModal()),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: _toggleMenu,
          backgroundColor: _isMenuOpen ? Colors.black : const Color(0xFF00BCD4),
          child: Icon(_isMenuOpen ? Icons.close : Icons.add, color: Colors.white, size: 30),
        ),
      ],
    );
  }

  Widget _buildMiniFab(IconData icon, String label, Color col, VoidCallback onTap) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Card(elevation: 2, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
      const SizedBox(width: 10),
      FloatingActionButton.small(onPressed: onTap, backgroundColor: col, child: Icon(icon, color: Colors.white)),
    ]);
  }

  void _showGeneralTxModal() {
    final accounts = Provider.of<AccountProvider>(context, listen: false).accounts;
    if (accounts.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => _QuickTransactionForm(accounts: accounts, onSaved: () {
        _refreshData();
        if(_isMenuOpen) _toggleMenu();
      }),
    );
  }
}

class _QuickTransactionForm extends StatefulWidget {
  final List<Account> accounts;
  final VoidCallback onSaved;
  const _QuickTransactionForm({required this.accounts, required this.onSaved});

  @override
  State<_QuickTransactionForm> createState() => _QuickTransactionFormState();
}

class _QuickTransactionFormState extends State<_QuickTransactionForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late int _selectedAccountId;
  String _type = 'deposit';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.accounts.first.id!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 25, left: 25, right: 25),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catat Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // ── TOGGLE SETOR / TARIK ──
            Row(
              children: [
                Expanded(child: _buildTypeToggle('Setor', 'deposit', Colors.green)),
                const SizedBox(width: 15),
                Expanded(child: _buildTypeToggle('Tarik', 'withdrawal', Colors.red)),
              ],
            ),
            const SizedBox(height: 25),
            
            // ── PILIH REKENING ──
            const Text('Pilih Rekening', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedAccountId,
              items: widget.accounts.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name))).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val!),
            ),
            const SizedBox(height: 20),
            
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp ', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder())),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaving ? Colors.grey : (_type == 'deposit' ? Colors.green : Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('SIMPAN TRANSAKSI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(String label, String value, Color color) {
    bool isSelected = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _handleSave() async {
    String amountStr = _amountController.text.trim();
    double amount = double.tryParse(amountStr) ?? 0;
    
    // VALIDASI INSTAN: Beri tahu pengguna jika nominal salah
    if (amountStr.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Isi nominal dulu dengan benar!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final tx = TransactionModel(
        accountId: _selectedAccountId,
        type: _type,
        amount: amount,
        description: _noteController.text.isEmpty ? 'Tabungan Saya' : _noteController.text,
        date: DateTime.now()
      );
      
      // 1. Simpan ke Database (Melalui AccountProvider agar saldo update)
      await Provider.of<AccountProvider>(context, listen: false).addTransaction(tx);
      
      // 2. Beri pesan sukses instan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Transaksi Berhasil Disimpan!'), backgroundColor: Colors.green),
        );
      }

      // 3. Pemicu Update Riwayat (Dua Jalur agar Pasti Muncul)
      if (mounted) {
        await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
        widget.onSaved(); // Panggil refresh dari HomeScreen
        
        // Tutup Jendela
        Navigator.pop(context);
        
        // Jalur refresh tambahan setelah modal tutup (agar pasti muncul)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
            Provider.of<AccountProvider>(context, listen: false).loadAccounts();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Gagal: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
