import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../database/db_helper.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  bool _isLoading = false;

  AccountProvider() {
    loadAccounts();
  }

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  double get totalBalance {
    return _accounts.fold(0, (sum, item) => sum + item.balance);
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    _accounts = await DatabaseHelper.instance.readAllAccounts();
    if (_accounts.isEmpty) {
      final defaultAcc = Account(
        name: 'Main Balance',
        balance: 12500000.0,
        colorValue: Colors.teal.value,
        iconCodePoint: Icons.account_balance_wallet.codePoint,
        createdAt: DateTime.now(),
      );
      await DatabaseHelper.instance.createAccount(defaultAcc);
      _accounts = await DatabaseHelper.instance.readAllAccounts();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    await DatabaseHelper.instance.createAccount(account);
    await loadAccounts();
  }

  Future<void> updateAccount(Account account) async {
    await DatabaseHelper.instance.updateAccount(account);
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    await DatabaseHelper.instance.deleteAccount(id);
    await loadAccounts();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.createTransaction(transaction);
    await loadAccounts(); // Reload accounts to get updated balances
  }

  Future<List<TransactionModel>> getTransactionsForAccount(int accountId) async {
    return await DatabaseHelper.instance.readTransactionsByAccount(accountId);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    return await DatabaseHelper.instance.readAllTransactions();
  }
}
