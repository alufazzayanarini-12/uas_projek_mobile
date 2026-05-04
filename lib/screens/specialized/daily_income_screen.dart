import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../category_history_screen.dart';

class DailyIncomeScreen extends StatefulWidget {
  final CategoryModel category;
  const DailyIncomeScreen({super.key, required this.category});

  @override
  State<DailyIncomeScreen> createState() => _DailyIncomeScreenState();
}

class _DailyIncomeScreenState extends State<DailyIncomeScreen> {
  double _dailyTarget = 500000;
  double _todayIncome = 0;
  List<double> _hourlyData = List.filled(24, 0.0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // In a real app, this would fetch from a provider
    setState(() {
      _todayIncome = 350000; // Simulated
      _hourlyData[8] = 50000;
      _hourlyData[10] = 150000;
      _hourlyData[13] = 100000;
      _hourlyData[17] = 50000;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final progress = (_todayIncome / _dailyTarget).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Harian'),
        backgroundColor: Colors.teal,
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
            _buildTargetCard(currencyFormat, progress),
            const SizedBox(height: 32),
            const Text('Analisis Waktu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Kapan biasanya uang masuk?', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            _buildTimeChart(),
            const SizedBox(height: 32),
            const Text('Rangkuman Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: CategoryHistoryScreen(category: widget.category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetCard(NumberFormat formatter, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal, Colors.teal[700]!]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Target Hari Ini', style: TextStyle(color: Colors.white70)),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: () {
                  // Show dialog to change target
                },
              ),
            ],
          ),
          Text(formatter.format(_dailyTarget), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terkumpul: ${formatter.format(_todayIncome)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChart() {
    return Container(
      height: 150,
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val % 4 == 0) return Text('${val.toInt()}:00', style: const TextStyle(fontSize: 10, color: Colors.grey));
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _hourlyData.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(toY: e.value, color: Colors.teal, width: 8, borderRadius: BorderRadius.circular(4))],
            );
          }).toList(),
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
