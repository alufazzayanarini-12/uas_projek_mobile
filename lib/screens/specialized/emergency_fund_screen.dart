import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../category_history_screen.dart';

class EmergencyFundScreen extends StatefulWidget {
  final CategoryModel category;
  const EmergencyFundScreen({super.key, required this.category});

  @override
  State<EmergencyFundScreen> createState() => _EmergencyFundScreenState();
}

class _EmergencyFundScreenState extends State<EmergencyFundScreen> {
  double _currentAmount = 0;
  double _avgMonthlyExpense = 1500000; // Default placeholder
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  Future<void> _calculateStats() async {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final allTransactions = await accountProvider.getAllTransactions();
    
    // Calculate total amount in this category
    double amount = 0;
    for (var t in allTransactions) {
      if (t.categoryId == widget.category.id) {
        amount += (t.type == 'deposit' ? t.amount : -t.amount);
      }
    }

    // Estimate monthly expense from all transactions
    final expenseTransactions = allTransactions.where((t) => t.type == 'withdrawal').toList();
    if (expenseTransactions.isNotEmpty) {
      final totalExpense = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
      final dates = expenseTransactions.map((t) => t.date).toList()..sort();
      final months = (dates.last.difference(dates.first).inDays / 30).clamp(1, 12);
      _avgMonthlyExpense = totalExpense / months;
    }

    setState(() {
      _currentAmount = amount;
      _isLoading = false;
    });
  }

  double get _idealAmount => _avgMonthlyExpense * 6;
  double get _progress => (_currentAmount / _idealAmount).clamp(0.0, 1.0);

  Color get _statusColor {
    if (_progress < 0.3) return Colors.red;
    if (_progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  String get _statusText {
    if (_progress < 0.3) return 'Bahaya';
    if (_progress < 0.7) return 'Waspada';
    return 'Aman';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dana Darurat'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              final provider = Provider.of<CategoryProvider>(context, listen: false);
              switch (value) {
                case 'pin': provider.togglePin(widget.category); break;
                case 'archive': 
                  provider.toggleArchive(widget.category);
                  Navigator.pop(context);
                  break;
                case 'delete': _confirmDelete(provider); break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin', 
                child: ListTile(
                  leading: Icon(widget.category.isPinned ? Icons.push_pin_outlined : Icons.push_pin, size: 20),
                  title: Text(widget.category.isPinned ? 'Lepas Pin' : 'Sematkan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'archive', 
                child: const ListTile(
                  leading: Icon(Icons.archive_outlined, size: 20),
                  title: Text('Arsipkan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete', 
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  title: Text('Hapus', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(currencyFormat),
                const SizedBox(height: 32),
                _buildCalculator(currencyFormat),
                const SizedBox(height: 32),
                const Text('Riwayat Penggunaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: CategoryHistoryScreen(category: widget.category), // Reusing history for the bottom part
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatusCard(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status Keamanan', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  color: _statusColor,
                ),
              ),
              Column(
                children: [
                  Text('${(_progress * 100).toStringAsFixed(0)}%', 
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _statusColor)),
                  const Text('Terkumpul', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(formatter.format(_currentAmount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('dari target ${formatter.format(_idealAmount)}', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCalculator(NumberFormat formatter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calculate_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text('Kalkulator Ideal', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Berdasarkan pengeluaran bulanan Anda:', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(formatter.format(_avgMonthlyExpense), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const Text('Dana Darurat Ideal (6x Pengeluaran):', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(formatter.format(_idealAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(CategoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              provider.deleteCategory(widget.category.id!);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to management
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
