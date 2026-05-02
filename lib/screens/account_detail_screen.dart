import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../providers/account_provider.dart';
import 'add_transaction_screen.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;
  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = Provider.of<AccountProvider>(context, listen: false)
        .getTransactionsForAccount(widget.account.id!);
  }

  @override
  Widget build(BuildContext context) {
    // Get updated account from provider to reflect balance changes
    final currentAccount = Provider.of<AccountProvider>(context).accounts.firstWhere(
      (a) => a.id == widget.account.id,
      orElse: () => widget.account,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Tabungan'),
        backgroundColor: Color(currentAccount.colorValue),
      ),
      body: Column(
        children: [
          // Account Summary Header
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Color(currentAccount.colorValue),
            width: double.infinity,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(IconData(currentAccount.iconCodePoint, fontFamily: 'MaterialIcons'), size: 36, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  currentAccount.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Saldo Saat Ini', style: TextStyle(color: Colors.white70)),
                Text(
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(currentAccount.balance),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Transactions List (Mutasi)
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Belum ada transaksi di rekening ini.', style: TextStyle(color: Colors.grey)),
                  );
                }

                final transactions = snapshot.data!;
                return ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isDeposit = tx.type == 'deposit';
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isDeposit ? Colors.green[100] : Colors.red[100],
                        child: Icon(
                          isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isDeposit ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(tx.date)),
                      trailing: Text(
                        '${isDeposit ? '+' : '-'} ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(tx.amount)}',
                        style: TextStyle(
                          color: isDeposit ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(account: currentAccount),
            ),
          );
          // Reload transactions after adding new one
          setState(() {
            _loadTransactions();
          });
        },
        backgroundColor: Color(currentAccount.colorValue),
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
      ),
    );
  }
}
