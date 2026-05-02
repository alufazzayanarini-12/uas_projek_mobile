import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../database/db_helper.dart';

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
    await DatabaseHelper.instance.updateGoal(goal);
    await loadGoals();
  }

  Future<void> deleteGoal(int id) async {
    await DatabaseHelper.instance.deleteGoal(id);
    await loadGoals();
  }
}
