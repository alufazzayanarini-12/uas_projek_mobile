import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    _goals = await DatabaseHelper.instance.readAllGoals();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    await DatabaseHelper.instance.createGoal(goal);
    await loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    // Check if goal is completed
    if (goal.currentAmount >= goal.targetAmount && goal.status != 'completed') {
      goal = goal.copyWith(status: 'completed');
    }
    await DatabaseHelper.instance.updateGoal(goal);
    await loadGoals();
  }

  Future<void> addSavingsToGoal(int goalId, double amount, int accountId) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount + amount);
      
      // 1. Create a withdrawal transaction for the account
      final transaction = TransactionModel(
        accountId: accountId,
        goalId: goalId,
        type: 'withdrawal',
        amount: amount,
        description: 'Setoran ke target: ${goal.name}',
      );
      
      await DatabaseHelper.instance.createTransaction(transaction);
      
      // 2. Update the goal amount in DB
      await updateGoal(updatedGoal);
    }
  }

  Future<List<TransactionModel>> getGoalTransactions(int goalId) async {
    final allTransactions = await DatabaseHelper.instance.readAllTransactions();
    return allTransactions.where((t) => t.goalId == goalId).toList();
  }

  Future<void> deleteGoal(int id) async {
    await DatabaseHelper.instance.deleteGoal(id);
    await loadGoals();
  }

  Future<void> checkAndProcessAutoDebits(int accountId) async {
    final now = DateTime.now();
    for (var goal in _goals) {
      if (goal.status == 'active' && goal.autoDebitAmount != null && goal.autoDebitDate != null) {
        // Check if today is the autodebit date
        if (now.day == goal.autoDebitDate) {
          // Simple check: check if we already processed it today using shared preferences
          // For simplicity in this demo, we'll just add the savings
          await addSavingsToGoal(goal.id!, goal.autoDebitAmount!, accountId);
        }
      }
    }
  }
}
