import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../models/debt_model.dart';
import '../../providers/category_provider.dart';
import '../category_history_screen.dart';

class DebtManagementScreen extends StatefulWidget {
  final CategoryModel category;
  const DebtManagementScreen({super.key, required this.category});

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> {
  List<DebtModel> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  void _loadDebts() {
    // Simulated data
    setState(() {
      _debts = [
        DebtModel(
          personName: 'Andi',
          totalAmount: 500000,
          remainingAmount: 200000,
          dueDate: DateTime.now().add(const Duration(days: 5)),
          type: 'to_others',
        ),
        DebtModel(
          personName: 'Budi',
          totalAmount: 1000000,
          remainingAmount: 1000000,
          dueDate: DateTime.now().add(const Duration(days: 12)),
          type: 'to_me',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Hutang'),
        backgroundColor: Colors.orange[800],
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
      body: Column(
        children: [
          _buildSummaryHeader(currencyFormat),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _debts.length,
              itemBuilder: (context, index) {
                final debt = _debts[index];
                return _buildDebtCard(debt, currencyFormat);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Pinjaman/Hutang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(NumberFormat formatter) {
    double totalIowe = _debts.where((d) => d.type == 'to_others').fold(0, (sum, d) => sum + d.remainingAmount);
    double totalTheyOwe = _debts.where((d) => d.type == 'to_me').fold(0, (sum, d) => sum + d.remainingAmount);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[800],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Saya Hutang', formatter.format(totalIowe), Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildSummaryItem('Piutang Saya', formatter.format(totalTheyOwe), Colors.white),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDebtCard(DebtModel debt, NumberFormat formatter) {
    final isIowe = debt.type == 'to_others';
    final progress = (1 - (debt.remainingAmount / debt.totalAmount)).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: (isIowe ? Colors.red : Colors.green).withOpacity(0.1),
                  child: Icon(isIowe ? Icons.outbound : Icons.login, color: isIowe ? Colors.red : Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.personName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(isIowe ? 'Saya berhutang' : 'Berhutang ke saya', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatter.format(debt.remainingAmount), style: TextStyle(color: isIowe ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                    Text('Jatuh Tempo: ${DateFormat('dd MMM').format(debt.dueDate)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[100],
              color: isIowe ? Colors.orange : Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lunas: ${formatter.format(debt.totalAmount - debt.remainingAmount)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                TextButton(
                  onPressed: () {},
                  child: const Text('Bayar Cicilan', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
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
