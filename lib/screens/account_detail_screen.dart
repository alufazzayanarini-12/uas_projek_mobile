import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;
  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = Provider.of<AccountProvider>(context, listen: false)
        .getTransactionsForAccount(widget.account.id!);
  }

  void _toggleMenu() => setState(() => _isMenuOpen = !_isMenuOpen);

  @override
  Widget build(BuildContext context) {
    final currentAccount = Provider.of<AccountProvider>(context).accounts.firstWhere(
      (a) => a.id == widget.account.id,
      orElse: () => widget.account,
    );
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildBlueHeader(currentAccount, fmt),
          Expanded(child: _buildTransactionList(fmt)),
        ],
      ),
      floatingActionButton: _buildModernFAB(currentAccount),
    );
  }

  Widget _buildBlueHeader(Account acc, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF2196F3), // Warna Biru sesuai gambar
      ),
      child: Column(
        children: [
          // Bar Atas: Tombol Back & Judul
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Buku Tabungan',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Spacer agar judul tetap di tengah
            ],
          ),
          const SizedBox(height: 20),
          // Ikon Akun
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 35),
          ),
          const SizedBox(height: 15),
          // Nama Akun
          Text(
            acc.name.toLowerCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          const Text(
            'Saldo Saat Ini',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          // Nominal Saldo
          Text(
            fmt.format(acc.balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(NumberFormat fmt) {
    return FutureBuilder<List<TransactionModel>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text('Belum ada riwayat transaksi.'));
        
        final txs = snapshot.data!;
        return ListView.separated(
          itemCount: txs.length,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
          itemBuilder: (context, index) {
            final tx = txs[index];
            final isDeposit = tx.type == 'deposit';
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDeposit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isDeposit ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              title: Text(
                tx.description,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(tx.date),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: Text(
                '${isDeposit ? '+ ' : '- '}${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(tx.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDeposit ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernFAB(Account acc) {
    return InkWell(
      onTap: _showQuickModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Transaksi',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => _QuickForm(
        account: widget.account,
        onSaved: () {
          setState(() => _loadTransactions());
        },
      ),
    );
  }
}

class _QuickForm extends StatefulWidget {
  final Account account;
  final VoidCallback onSaved;
  const _QuickForm({required this.account, required this.onSaved});

  @override
  State<_QuickForm> createState() => _QuickFormState();
}

class _QuickFormState extends State<_QuickForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'deposit';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 25, left: 25, right: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Catat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Setor')),
                  selected: _type == 'deposit',
                  onSelected: (s) => setState(() => _type = 'deposit'),
                  selectedColor: Colors.green.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Tarik')),
                  selected: _type == 'withdrawal',
                  onSelected: (s) => setState(() => _type = 'withdrawal'),
                  selectedColor: Colors.red.withOpacity(0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp ', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                double amount = double.tryParse(_amountController.text) ?? 0;
                if (amount <= 0) return;
                
                final tx = TransactionModel(
                  accountId: widget.account.id!,
                  type: _type,
                  amount: amount,
                  description: _noteController.text.isEmpty ? 'Transaksi' : _noteController.text,
                  date: DateTime.now(),
                );
                
                await Provider.of<AccountProvider>(context, listen: false).addTransaction(tx);
                widget.onSaved();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
              child: const Text('SIMPAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
