import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';

class CategoryHistoryScreen extends StatefulWidget {
  final CategoryModel category;
  const CategoryHistoryScreen({super.key, required this.category});

  @override
  State<CategoryHistoryScreen> createState() => _CategoryHistoryScreenState();
}

class _CategoryHistoryScreenState extends State<CategoryHistoryScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String _timeFilter = 'Semua';
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final transactions = await Provider.of<CategoryProvider>(context, listen: false)
        .getCategoryTransactions(widget.category.id!);
    setState(() {
      _transactions = transactions..sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
    });
  }

  List<TransactionModel> get _filteredTransactions {
    List<TransactionModel> filtered = _transactions;
    
    // Time Filter
    if (_timeFilter != 'Semua') {
      final now = DateTime.now();
      filtered = filtered.where((t) {
        if (_timeFilter == 'Bulan Ini') return t.date.month == now.month && t.date.year == now.year;
        if (_timeFilter == 'Bulan Lalu') {
          final lastMonth = now.month == 1 ? 12 : now.month - 1;
          final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
          return t.date.month == lastMonth && t.date.year == lastMonthYear;
        }
        return true;
      }).toList();
    }

    // Search Query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => 
        t.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  double get _totalSpent {
    return _filteredTransactions
        .where((t) => t.type == 'withdrawal')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get _totalEarned {
    return _filteredTransactions
        .where((t) => t.type == 'deposit')
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, List<TransactionModel>> get _groupedTransactions {
    final Map<String, List<TransactionModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var t in _filteredTransactions) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      String key;
      if (tDate == today) {
        key = 'Hari Ini';
      } else if (tDate == yesterday) {
        key = 'Kemarin';
      } else {
        key = DateFormat('dd MMMM yyyy', 'id_ID').format(t.date);
      }
      
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(t);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            )
          : Text('Riwayat ${widget.category.name}'),
        elevation: 0,
        backgroundColor: Color(widget.category.colorValue),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchQuery = '';
            }),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              // TODO: Export logic
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Ekspor sedang disiapkan...')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          _buildTimeFilters(),
          if (_filteredTransactions.isNotEmpty) _buildTrendChart(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : _buildGroupedTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 20),
      decoration: BoxDecoration(
        color: Color(widget.category.colorValue),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(widget.category.colorValue).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Pengeluaran', currencyFormat.format(_totalSpent), Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem('Pemasukan', currencyFormat.format(_totalEarned), Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 13, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildTrendChart() {
    // Basic trend chart showing daily sums
    final Map<DateTime, double> dailySums = {};
    for (var t in _filteredTransactions) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      dailySums[date] = (dailySums[date] ?? 0) + (t.type == 'withdrawal' ? -t.amount : t.amount);
    }
    
    final sortedDates = dailySums.keys.toList()..sort();
    if (sortedDates.length < 2) return const SizedBox.shrink();

    final spots = sortedDates.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), dailySums[e.value]!);
    }).toList();

    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Color(widget.category.colorValue).withOpacity(0.7),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true, 
                gradient: LinearGradient(
                  colors: [
                    Color(widget.category.colorValue).withOpacity(0.2),
                    Color(widget.category.colorValue).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['Semua', 'Bulan Ini', 'Bulan Lalu'].map((filter) {
          final isSelected = _timeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _timeFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? Color(widget.category.colorValue) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[200]),
          ),
          const SizedBox(height: 24),
          Text('Tidak ada transaksi ditemukan', 
            style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactionList() {
    final grouped = _groupedTransactions;
    final keys = grouped.keys.toList();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final dateKey = keys[index];
        final transactions = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
              child: Text(
                dateKey.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[400],
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...transactions.map((t) {
              final isExpense = t.type == 'withdrawal';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isExpense ? Icons.trending_down : Icons.trending_up,
                      color: isExpense ? Colors.red : Colors.green,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    t.description, 
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('HH:mm').format(t.date),
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ),
                  trailing: Text(
                    '${isExpense ? "-" : "+"}${currencyFormat.format(t.amount)}',
                    style: TextStyle(
                      color: isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
