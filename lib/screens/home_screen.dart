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
import 'category_management_screen.dart';
import 'add_goal_screen.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _expandedAccountIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tabungan Saya', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<AccountProvider, TransactionProvider>(
        builder: (context, accProvider, txProvider, child) {
          if (accProvider.isLoading) return const Center(child: CircularProgressIndicator());

          double totalBalance = 0;
          for (var acc in accProvider.accounts) totalBalance += acc.balance;

          return RefreshIndicator(
            onRefresh: () async {
              await accProvider.loadAccounts();
              await txProvider.loadTransactions();
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
              // Total Balance Card
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.black, Color(0xFF333333)]),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Saldo Tersedia', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 12),
                        Text(
                          settings.isBalanceHidden ? '*******' : fmt.format(totalBalance),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  );
                },
              ),
                const SizedBox(height: 35),
                const Text('Daftar Rekening', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                
                if (accProvider.accounts.isEmpty)
                  const Center(child: Text('Belum ada rekening.'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accProvider.accounts.length,
                    itemBuilder: (context, index) {
                      final account = accProvider.accounts[index];
                      final accountTransactions = txProvider.transactions
                          .where((tx) => tx.accountId == account.id)
                          .toList();
                      return _buildAccountCard(account, index, fmt, accountTransactions);
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen())),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Target'),
      ),
    );
  }

  Widget _buildAccountCard(Account account, int index, NumberFormat fmt, List<TransactionModel> txs) {
    final isExpanded = _expandedAccountIndex == index;
    final accountColor = Color(account.colorValue);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _expandedAccountIndex = isExpanded ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isExpanded ? Colors.blue.withOpacity(0.3) : Colors.grey.shade100,
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: accountColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(IconData(account.iconCodePoint, fontFamily: 'MaterialIcons'), color: accountColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, _) {
                          return Text(
                            settings.isBalanceHidden ? '*******' : fmt.format(account.balance),
                            style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
            
            if (isExpanded) ...[
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 15),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('Tren Bulan Ini', '+5%', Colors.green),
                  _buildMiniStat('Aktivitas', txs.isEmpty ? 'Baru' : 'Aktif', Colors.blue),
                ],
              ),
              const SizedBox(height: 20),
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Transaksi Terakhir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              if (txs.isEmpty)
                const Text('Belum ada transaksi', style: TextStyle(fontSize: 12, color: Colors.grey))
              else
                ...txs.take(2).map((tx) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(tx.type == 'deposit' ? Icons.arrow_downward : Icons.arrow_upward, 
                        size: 14, color: tx.type == 'deposit' ? Colors.green : Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tx.description, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(fmt.format(tx.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen(account: account))),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Catat Transaksi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(account: account))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      Provider.of<AccountProvider>(context, listen: false).deleteAccount(account.id!);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
