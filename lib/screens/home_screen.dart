import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/account.dart';
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
        title: const Text('Tabunganku', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF4A5568), size: 26),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer2<AccountProvider, TransactionProvider>(
        builder: (context, accProvider, txProvider, child) {
          double totalBalance = 0;
          for (var acc in accProvider.accounts) totalBalance += acc.balance;

          return RefreshIndicator(
            onRefresh: () async {
              await accProvider.loadAccounts();
              await txProvider.loadTransactions();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 10),
                _buildIndigoBalanceCard(totalBalance, fmt),
                const SizedBox(height: 30),
                const Text('Daftar Rekening', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8E99AF))),
                const SizedBox(height: 15),
                if (accProvider.accounts.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada rekening.')))
                else
                  ...accProvider.accounts.map((acc) => _buildModernAccountCard(acc, fmt)).toList(),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      // ── TOMBOL "+" PINDAH KE BAWAH (Sesuai Gambar) ──
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 5),
        child: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAccountScreen())),
            backgroundColor: const Color(0xFF00BCD4), // Warna Cyan sesuai gambar
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Bentuk kotak bulat
            child: const Icon(Icons.add, color: Colors.white, size: 35),
          ),
        ),
      ),
    );
  }

  Widget _buildIndigoBalanceCard(double total, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E3A91), Color(0xFF1B235A)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF2E3A91).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 10),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => Text(
              settings.isBalanceHidden ? '*******' : fmt.format(total),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Terakhir diupdate', style: TextStyle(color: Colors.white38, fontSize: 11)),
              Text(DateFormat('dd MMM yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernAccountCard(Account account, NumberFormat fmt) {
    final color = Color(account.colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(IconData(account.iconCodePoint, fontFamily: 'MaterialIcons'), color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A5568))),
                const Text('Saldo tersedia', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => Text(
              settings.isBalanceHidden ? '*******' : fmt.format(account.balance),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
