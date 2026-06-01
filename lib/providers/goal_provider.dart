import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/notification_service.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;

  GoalProvider() {
    loadGoals();
  }

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
    final created = await DatabaseHelper.instance.createGoal(goal);
    await loadGoals();

    // Schedule reminders for the goal
    try {
      final ns = NotificationService();
      final gid = created.id ?? 0;
      // If goal has explicit reminderDateTime, schedule it
      if (created.reminderDateTime != null) {
        await ns.scheduleNotification(
          id: 4000 + gid,
          title: 'Pengingat Target: ${created.name}',
          body: 'Ingat target Anda: ${created.name}',
          scheduledDateTime: created.reminderDateTime!,
        );
      } else {
        // Default: reminder 1 day before deadline at 09:00
        final oneDayBefore = DateTime(created.deadline.year, created.deadline.month, created.deadline.day)
            .subtract(const Duration(days: 1))
            .add(const Duration(hours: 9));
        if (oneDayBefore.isAfter(DateTime.now())) {
          await ns.scheduleNotification(
            id: 2000 + gid,
            title: 'Ingat Target ${created.name}',
            body: 'Target ${created.name} hampir jatuh tempo pada ${created.deadline.toLocal().toString().split(' ').first}',
            scheduledDateTime: oneDayBefore,
          );
        }

        // Also schedule a reminder on the deadline day at 09:00
        final deadlineAtNine = DateTime(created.deadline.year, created.deadline.month, created.deadline.day, 9, 0);
        if (deadlineAtNine.isAfter(DateTime.now())) {
          await ns.scheduleNotification(
            id: 1000 + gid,
            title: 'Target ${created.name} - Jatuh Tempo',
            body: 'Target ${created.name} jatuh tempo hari ini.',
            scheduledDateTime: deadlineAtNine,
          );
        }
      }
    } catch (e) {
      // ignore notification errors
      // ignore: avoid_print
      print('GoalProvider: notification schedule error: $e');
    }
  }

  Future<void> updateGoal(Goal goal) async {
    // Check if goal is completed
    if (goal.currentAmount >= goal.targetAmount && goal.status != 'completed') {
      goal = goal.copyWith(status: 'completed');
    }
    await DatabaseHelper.instance.updateGoal(goal);
    await loadGoals();

    // Reschedule/cancel notifications for this goal
    try {
      final ns = NotificationService();
      final gid = goal.id ?? 0;
      // Cancel previous scheduled ids for this goal
      await ns.cancelNotification(1000 + gid);
      await ns.cancelNotification(2000 + gid);
      await ns.cancelNotification(4000 + gid);

      if (goal.reminderDateTime != null) {
        await ns.scheduleNotification(
          id: 4000 + gid,
          title: 'Pengingat Target: ${goal.name}',
          body: 'Ingat target Anda: ${goal.name}',
          scheduledDateTime: goal.reminderDateTime!,
        );
      } else {
        final oneDayBefore = DateTime(goal.deadline.year, goal.deadline.month, goal.deadline.day)
            .subtract(const Duration(days: 1))
            .add(const Duration(hours: 9));
        if (oneDayBefore.isAfter(DateTime.now())) {
          await ns.scheduleNotification(
            id: 2000 + gid,
            title: 'Ingat Target ${goal.name}',
            body: 'Target ${goal.name} hampir jatuh tempo pada ${goal.deadline.toLocal().toString().split(' ').first}',
            scheduledDateTime: oneDayBefore,
          );
        }
        final deadlineAtNine = DateTime(goal.deadline.year, goal.deadline.month, goal.deadline.day, 9, 0);
        if (deadlineAtNine.isAfter(DateTime.now())) {
          await ns.scheduleNotification(
            id: 1000 + gid,
            title: 'Target ${goal.name} - Jatuh Tempo',
            body: 'Target ${goal.name} jatuh tempo hari ini.',
            scheduledDateTime: deadlineAtNine,
          );
        }
      }
    } catch (e) {
      // ignore
      // ignore: avoid_print
      print('GoalProvider: notification reschedule error: $e');
    }
  }

  Future<void> addSavingsToGoal(int goalId, double amount, int accountId, {DateTime? date, String? description}) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount + amount);
      
      // 1. Create a deposit transaction for the account
      final transaction = TransactionModel(
        accountId: accountId,
        goalId: goalId,
        type: 'deposit',
        amount: amount,
        description: description ?? 'Setoran ke target: ${goal.name}',
        date: date,
      );
      
      await DatabaseHelper.instance.createTransaction(transaction);
      
      // 2. Update the goal amount in DB
      await updateGoal(updatedGoal);

      // Send immediate confirmation notification about the deposit
      try {
        final ns = NotificationService();
        final gid = goalId;
        await ns.showImmediateNotification(
          id: 3000 + gid,
          title: 'Setoran ke target',
          body: 'Anda telah menyetor Rp ${amount.toStringAsFixed(0)} ke target ${goal.name}',
        );
      } catch (e) {
        // ignore
      }
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
