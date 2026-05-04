import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import 'add_account_screen.dart';
import 'account_detail_screen.dart';
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
    // Load accounts when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabunganku', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: const Color(0xFF00B4D8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: Consumer2<AccountProvider, SettingsProvider>(
        builder: (context, accountProvider, settingsProvider, child) {
          if (accountProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final balanceText = settingsProvider.isBalanceHidden 
              ? 'Rp *********' 
              : NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(accountProvider.totalBalance);

          return CustomScrollView(
            slivers: [
              // Total Balance Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B4D8), // primary
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Saldo',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        balanceText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Daftar Rekening',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Accounts List
              accountProvider.accounts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: const [
                              Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Belum ada rekening tabungan.', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final account = accountProvider.accounts[index];
                          final accountBalanceText = settingsProvider.isBalanceHidden 
                              ? 'Rp *****' 
                              : NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(account.balance);
                              
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Color(account.colorValue).withOpacity(0.1),
                                child: Icon(IconData(account.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(account.colorValue)),
                              ),
                              title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(accountBalanceText),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountDetailScreen(account: account),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: accountProvider.accounts.length,
                      ),
                    ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00B4D8),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAccountScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
