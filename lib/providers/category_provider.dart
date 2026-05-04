import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../database/db_helper.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories.where((c) => !c.isArchived && c.parentId == null).toList();
  List<CategoryModel> get archivedCategories => _categories.where((c) => c.isArchived).toList();
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    _categories = await DatabaseHelper.instance.readAllCategories();

    _isLoading = false;
    notifyListeners();
  }

  List<CategoryModel> getSubCategories(int parentId) {
    return _categories.where((c) => c.parentId == parentId).toList();
  }

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

  Future<void> toggleArchive(CategoryModel category) async {
    final updated = category.copyWith(isArchived: !category.isArchived);
    await updateCategory(updated);
  }

  Future<void> togglePin(CategoryModel category) async {
    final updated = category.copyWith(isPinned: !category.isPinned);
    await updateCategory(updated);
  }

  Future<List<TransactionModel>> getCategoryTransactions(int categoryId) async {
    final allTransactions = await DatabaseHelper.instance.readAllTransactions();
    final subCategoryIds = _categories.where((c) => c.parentId == categoryId).map((c) => c.id).toList();
    
    return allTransactions.where((t) => 
      t.categoryId == categoryId || (t.categoryId != null && subCategoryIds.contains(t.categoryId))
    ).toList();
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final list = categories; // Reordering only among non-archived root categories
    final CategoryModel item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    
    // Update all categories with new order for these specific items
    await DatabaseHelper.instance.updateCategoryOrders(list);
    await loadCategories();
  }
}
