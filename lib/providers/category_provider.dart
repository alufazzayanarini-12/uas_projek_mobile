import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  
  // ── DATA DETAIL KATEGORI (SENTRALISASI) ──
  double savingsCurrent = 1500000;
  double savingsTarget = 5000000;
  
  double educationCurrent = 45000000;
  double educationTarget = 150000000;

  double emergencyCurrent = 45000000;
  double emergencyTarget = 50000000;
  
  double monthlyBudget = 3000000;
  double monthlySpent = 1200000;

  List<Map<String, dynamic>> _savingsHistory = [];
  List<Map<String, dynamic>> get savingsHistory => _savingsHistory;

  CategoryProvider() {
    loadCategories();
    _loadSavingsHistory();
  }

  Future<void> _loadSavingsHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = prefs.getString('savings_history');
      if (historyStr != null) {
        final List<dynamic> decoded = json.decode(historyStr);
        _savingsHistory = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        _savingsHistory = [
          {
            'title': 'Saldo Awal Tabungan',
            'amount': 1500000.0,
            'date': DateTime.now().toIso8601String(),
            'status': 'Berhasil',
          }
        ];
      }
      savingsCurrent = prefs.getDouble('savings_current') ?? 1500000.0;
      emergencyCurrent = prefs.getDouble('emergency_current') ?? 45000000.0;
      educationCurrent = prefs.getDouble('education_current') ?? 45000000.0;
      notifyListeners();
    } catch (e) {
      print("Error loading savings history: $e");
    }
  }

  Future<void> _saveSavingsHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savings_history', json.encode(_savingsHistory));
      await prefs.setDouble('savings_current', savingsCurrent);
      await prefs.setDouble('emergency_current', emergencyCurrent);
      await prefs.setDouble('education_current', educationCurrent);
    } catch (e) {
      print("Error saving savings history: $e");
    }
  }

  void addSavingsTransaction(String title, double amount) {
    savingsCurrent += amount;
    _savingsHistory.insert(0, {
      'title': title,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'status': 'Berhasil',
    });
    _saveSavingsHistory();
    notifyListeners();
  }

  void topUpEmergency(double amount) {
    emergencyCurrent += amount;
    _saveSavingsHistory();
    notifyListeners();
  }

  void topUpEducation(double amount) {
    educationCurrent += amount;
    _saveSavingsHistory();
    notifyListeners();
  }

  // Getter hanya untuk kategori yang tidak diarsip
  List<CategoryModel> get categories => _categories.where((c) => !c.isArchived).toList();
  List<CategoryModel> get allCategories => _categories;

  Future<void> loadCategories() async {
    _categories = await DatabaseHelper.instance.readAllCategories();
    
    // Auto-seed jika database kosong
    if (_categories.isEmpty) {
      await DatabaseHelper.instance.seedDefaultCategoriesManually();
      _categories = await DatabaseHelper.instance.readAllCategories();
    }
    notifyListeners();
  }

  // ── LOGIKA INTEGRASI TRANSAKSI ──
  void processTransaction(String categoryName, String type, double amount) {
    final name = categoryName.toLowerCase();
    
    if (name.contains('tabungan')) {
      if (type == 'deposit') savingsCurrent += amount;
      if (type == 'withdrawal') savingsCurrent -= amount;
    } else if (name.contains('pendidikan')) {
      if (type == 'deposit') educationCurrent += amount;
      if (type == 'withdrawal') educationCurrent -= amount;
    } else if (name.contains('darurat') || name.contains('emergency')) {
      if (type == 'deposit') emergencyCurrent += amount;
      if (type == 'withdrawal') emergencyCurrent -= amount;
    } else if (name.contains('bulanan')) {
      if (type == 'withdrawal') monthlySpent += amount;
      if (type == 'deposit') monthlySpent -= amount;
    }
    
    _saveSavingsHistory();
    notifyListeners();
  }

  // ── OPERASI DATABASE ──
  Future<void> addCategory(CategoryModel category) async {
    await DatabaseHelper.instance.createCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await DatabaseHelper.instance.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    await loadCategories();
  }

  // ── FITUR KHUSUS ──
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final activeCats = categories;
    if (newIndex > oldIndex) newIndex -= 1;
    
    final item = activeCats.removeAt(oldIndex);
    activeCats.insert(newIndex, item);
    
    await DatabaseHelper.instance.updateCategoryOrders(activeCats);
    await loadCategories();
  }

  Future<void> toggleArchive(CategoryModel category) async {
    final updated = category.copyWith(isArchived: !category.isArchived);
    await DatabaseHelper.instance.updateCategory(updated);
    await loadCategories();
  }
}
