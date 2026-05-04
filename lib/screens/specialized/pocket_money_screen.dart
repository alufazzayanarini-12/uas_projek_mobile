import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../category_history_screen.dart';

class PocketMoneyScreen extends StatefulWidget {
  final CategoryModel category;
  const PocketMoneyScreen({super.key, required this.category});

  @override
  State<PocketMoneyScreen> createState() => _PocketMoneyScreenState();
}

class _PocketMoneyScreenState extends State<PocketMoneyScreen> {
  @override
  Widget build(BuildContext context) {
    final isMonthly = widget.category.name.toLowerCase().contains('bulan');
    final color = Color(widget.category.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: color,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAllowanceCard(isMonthly, color),
            const SizedBox(height: 32),
            const Text('Statistik Penggunaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildUsageSummary(),
            const SizedBox(height: 32),
            const Text('Daftar Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: CategoryHistoryScreen(category: widget.category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllowanceCard(bool isMonthly, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isMonthly ? 'Jatah Bulanan' : 'Jatah Harian', style: const TextStyle(color: Colors.white70)),
              const Icon(Icons.account_balance_wallet, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Rp 2.000.000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const LinearProgressIndicator(
            value: 0.65,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tersisa: Rp 700.000', style: TextStyle(color: Colors.white, fontSize: 12)),
              Text('65% Terpakai', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSummary() {
    return Row(
      children: [
        _buildStatBox('Makan', '40%', Colors.orange),
        const SizedBox(width: 16),
        _buildStatBox('Transport', '30%', Colors.blue),
        const SizedBox(width: 16),
        _buildStatBox('Lainnya', '30%', Colors.grey),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
