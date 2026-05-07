import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../database/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseHelper.instance.readAllTransactions();
    } catch (e) {
      print("Error loading transactions: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await DatabaseHelper.instance.createTransaction(transaction);
      await loadTransactions(); // Paksa reload setelah tambah
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadTransactions();
  }
}
