import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../database/db_helper.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    _categories = await DatabaseHelper.instance.readAllCategories();

    _isLoading = false;
    notifyListeners();
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

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final CategoryModel item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    notifyListeners();

    await DatabaseHelper.instance.updateCategoryOrder(_categories);
  }
}
