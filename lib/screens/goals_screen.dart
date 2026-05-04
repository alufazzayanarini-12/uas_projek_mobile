import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/goal_provider.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalProvider>(context, listen: false).loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Target Tabungan', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.goals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Mulai Wujudkan Mimpimu',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat target tabungan pertama kamu sekarang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen())),
                      child: const Text('Buat Target Baru'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.goals.length,
            itemBuilder: (context, index) {
              final goal = provider.goals[index];
              final progress = goal.currentAmount / goal.targetAmount;
              final isCompleted = progress >= 1.0;
              final goalColor = Color(goal.color);

              return GestureDetector(
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal))
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: goalColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Background Image if exists
                        if (goal.imagePath != null)
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.1,
                              child: Image.file(File(goal.imagePath!), fit: BoxFit.cover),
                            ),
                          ),
                        
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: goalColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      IconData(goal.icon, fontFamily: 'MaterialIcons'),
                                      color: goalColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        Text(
                                          'Tenggat: ${DateFormat('dd MMM yyyy').format(goal.deadline)}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCompleted)
                                    const Icon(Icons.check_circle, color: Colors.green, size: 30),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(goal.currentAmount),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: goalColor),
                                  ),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress > 1.0 ? 1.0 : progress,
                                  backgroundColor: Colors.grey[100],
                                  color: progress < 0.3 ? Colors.red : (progress < 0.7 ? Colors.orange : Colors.green),
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Target: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(goal.targetAmount)}',
                                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen())),
        label: const Text('Target Baru'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
