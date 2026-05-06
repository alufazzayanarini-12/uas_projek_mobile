import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
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
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Target Saya', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.track_changes, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Belum ada target', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.goals.length,
            itemBuilder: (context, index) {
              final goal = provider.goals[index];
              final progress = goal.progressFraction;
              final goalColor = Color(goal.color);

              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Kartu
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: goalColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                image: goal.imagePath != null ? DecorationImage(image: FileImage(File(goal.imagePath!)), fit: BoxFit.cover) : null,
                              ),
                              child: goal.imagePath == null ? Icon(IconData(goal.icon, fontFamily: 'MaterialIcons'), color: goalColor) : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(goal.category, style: TextStyle(color: goalColor, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
                                  Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                            ),
                            if (goal.isCompleted) const Icon(Icons.check_circle, color: Colors.green, size: 28),
                          ],
                        ),
                      ),

                      // Progress Bar Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(fmt.format(goal.currentAmount), style: TextStyle(fontWeight: FontWeight.bold, color: goalColor)),
                                Text('${goal.progressPercent.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor: Colors.grey[100],
                                color: goalColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Target: ${fmt.format(goal.targetAmount)}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                Text(DateFormat('dd MMM yyyy').format(goal.deadline), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── KOTAK KUNING (TIPS HARIAN) ──
                      if (!goal.isCompleted && goal.daysRemaining > 0)
                        Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.yellow.shade700.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.orange[800], size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tips: Tabung ${fmt.format(goal.dailySuggestion)} setiap hari agar target tercapai tepat waktu!',
                                  style: TextStyle(fontSize: 12, color: Colors.orange[900], fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen())),
        label: const Text('Buat Target'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }
}
