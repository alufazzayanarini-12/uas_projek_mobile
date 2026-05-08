import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../database/db_helper.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  
  // ── DATA DETAIL KATEGORI (SENTRALISASI) ──
  double savingsCurrent = 1500000;
  double savingsTarget = 5000000;
  
  double educationCurrent = 45000000;
  double educationTarget = 150000000;
  
  double monthlyBudget = 3000000;
  double monthlySpent = 1200000;

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
    } else if (name.contains('bulanan')) {
      if (type == 'withdrawal') monthlySpent += amount;
      if (type == 'deposit') monthlySpent -= amount;
    }
    
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
