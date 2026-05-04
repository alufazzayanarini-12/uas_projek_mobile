import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import '../models/goal.dart';
import '../models/transaction_model.dart';
import '../providers/goal_provider.dart';
import '../providers/account_provider.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late ConfettiController _confettiController;
  late Goal _currentGoal;
  List<TransactionModel> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _currentGoal = widget.goal;
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    if (_currentGoal.currentAmount >= _currentGoal.targetAmount) {
      _confettiController.play();
    }
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await Provider.of<GoalProvider>(context, listen: false)
        .getGoalTransactions(_currentGoal.id!);
    setState(() {
      _history = history..sort((a, b) => a.date.compareTo(b.date));
      _loadingHistory = false;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getDailySuggestion() {
    final remaining = _currentGoal.targetAmount - _currentGoal.currentAmount;
    if (remaining <= 0) return 'Target tercapai!';
    
    final daysLeft = _currentGoal.deadline.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return 'Waktu habis!';
    
    final daily = remaining / daysLeft;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(daily);
  }

  String _getMonthlySuggestion() {
    final remaining = _currentGoal.targetAmount - _currentGoal.currentAmount;
    if (remaining <= 0) return 'Target tercapai!';
    
    final daysLeft = _currentGoal.deadline.difference(DateTime.now()).inDays;
    final monthsLeft = (daysLeft / 30).ceil();
    if (monthsLeft <= 0) return 'Waktu habis!';
    
    final monthly = remaining / monthsLeft;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(monthly);
  }

  void _showAddSavingsDialog() {
    final amountController = TextEditingController();
    int? selectedAccountId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Simpanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Consumer<AccountProvider>(
                builder: (context, accProvider, _) {
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Pilih Akun Sumber'),
                    value: selectedAccountId,
                    items: accProvider.accounts.map((acc) => DropdownMenuItem(
                      value: acc.id,
                      child: Text(acc.name),
                    )).toList(),
                    onChanged: (val) => setDialogState(() => selectedAccountId = val),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isNotEmpty && selectedAccountId != null) {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  if (amount <= 0) return;

                  await Provider.of<GoalProvider>(context, listen: false)
                      .addSavingsToGoal(_currentGoal.id!, amount, selectedAccountId!);
                  
                  // Update current view
                  setState(() {
                    _currentGoal = _currentGoal.copyWith(currentAmount: _currentGoal.currentAmount + amount);
                  });

                  if (_currentGoal.currentAmount >= _currentGoal.targetAmount) {
                    _confettiController.play();
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentGoal.currentAmount / _currentGoal.targetAmount;
    final remainingAmount = _currentGoal.targetAmount - _currentGoal.currentAmount;
    final daysLeft = _currentGoal.deadline.difference(DateTime.now()).inDays;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(_currentGoal.name, style: const TextStyle(shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                  background: _currentGoal.imagePath != null
                      ? Image.file(File(_currentGoal.imagePath!), fit: BoxFit.cover)
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(_currentGoal.color), Color(_currentGoal.color).withOpacity(0.7)],
                            ),
                          ),
                          child: Icon(IconData(_currentGoal.icon, fontFamily: 'MaterialIcons'), size: 100, color: Colors.white24),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Card
                      Card(
                        elevation: 8,
                        shadowColor: Color(_currentGoal.color).withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Progres Tabungan', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(progress * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(_currentGoal.color)),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(_currentGoal.color).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(IconData(_currentGoal.icon, fontFamily: 'MaterialIcons'), size: 40, color: Color(_currentGoal.color)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress > 1.0 ? 1.0 : progress,
                                  minHeight: 14,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progress < 0.3 ? Colors.red : (progress < 0.7 ? Colors.orange : Colors.green),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoColumn('Target', NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_currentGoal.targetAmount)),
                                  _buildInfoColumn('Terkumpul', NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_currentGoal.currentAmount)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Smart Suggestions
                      const Text('Saran Menabung Cerdas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Berdasarkan sisa waktu dan target kamu', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildSuggestionCard('Harian', _getDailySuggestion(), Icons.calendar_view_day, Colors.blue)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSuggestionCard('Bulanan', _getMonthlySuggestion(), Icons.calendar_view_month, Colors.purple)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Growth Chart
                      const Text('Grafik Pertumbuhan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _loadingHistory 
                          ? const Center(child: CircularProgressIndicator())
                          : _history.isEmpty 
                            ? const Center(child: Text('Belum ada data pertumbuhan', style: TextStyle(color: Colors.grey)))
                            : _buildChart(),
                      ),
                      const SizedBox(height: 32),

                      // Details
                      const Text('Informasi Target', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.timer_outlined, 'Sisa Waktu', '$daysLeft Hari'),
                      _buildDetailRow(Icons.event_note, 'Tenggat Waktu', DateFormat('dd MMMM yyyy').format(_currentGoal.deadline)),
                      if (_currentGoal.autoDebitAmount != null)
                        _buildDetailRow(Icons.auto_awesome_outlined, 'Simulasi Autodebit', 'Rp ${NumberFormat('#,###').format(_currentGoal.autoDebitAmount)} / bulan'),
                      
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showAddSavingsDialog,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('TAMBAH SIMPANAN', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Color(_currentGoal.color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow],
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildSuggestionCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChart() {
    double cumulative = 0;
    List<FlSpot> spots = [];
    
    // Add start point
    spots.add(const FlSpot(0, 0));
    
    for (int i = 0; i < _history.length; i++) {
      cumulative += _history[i].amount;
      spots.add(FlSpot((i + 1).toDouble(), cumulative));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Color(_currentGoal.color),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Color(_currentGoal.color).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
