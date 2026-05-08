import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/goal.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('savings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        filePath,
        version: 9,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 11,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
    await checkAndFixColumns(db); // Paksa cek kolom saat baru buka
    return db;
  }

  // ── FITUR PENYEMBUHAN OTOMATIS: CEK & TAMBAH KOLOM JIKA KURANG ──
  Future<void> checkAndFixColumns(Database db) async {
    List<String> columns = [];
    var result = await db.rawQuery('PRAGMA table_info(categories)');
    for (var row in result) {
      columns.add(row['name'] as String);
    }

    if (!columns.contains('budget_limit')) {
      await db.execute('ALTER TABLE categories ADD COLUMN budget_limit REAL DEFAULT 0.0');
    }
    if (!columns.contains('is_archived')) {
      await db.execute('ALTER TABLE categories ADD COLUMN is_archived INTEGER DEFAULT 0');
    }
    if (!columns.contains('is_pinned')) {
      await db.execute('ALTER TABLE categories ADD COLUMN is_pinned INTEGER DEFAULT 0');
    }
    if (!columns.contains('parent_id')) {
      await db.execute('ALTER TABLE categories ADD COLUMN parent_id INTEGER');
    }
    if (!columns.contains('order_index')) {
      await db.execute('ALTER TABLE categories ADD COLUMN order_index INTEGER DEFAULT 0');
    }
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await checkAndFixColumns(db); // Selalu cek saat upgrade
    // ... logic upgrade lainnya tetap ada
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final List<Map<String, dynamic>> defaultCategories = [
      {'name': 'Hutang', 'icon_code_point': 0xf0289, 'color_value': 0xFFF44336, 'order_index': 0},
      {'name': 'Tabungan Saya', 'icon_code_point': 0xe54e, 'color_value': 0xFFE91E63, 'order_index': 1},
      {'name': 'Pendidikan', 'icon_code_point': 0xe5bc, 'color_value': 0xFF2196F3, 'order_index': 2},
      {'name': 'Uang Bulanan', 'icon_code_point': 0xe040, 'color_value': 0xFF4CAF50, 'order_index': 3},
      {'name': 'Dana Darurat', 'icon_code_point': 0xe30d, 'color_value': 0xFFFF9800, 'order_index': 4},
      {'name': 'Uang Saku', 'icon_code_point': 0xe541, 'color_value': 0xFF9C27B0, 'order_index': 5},
      {'name': 'Lainnya', 'icon_code_point': 0xe1b1, 'color_value': 0xFF607D8B, 'order_index': 6},
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', cat);
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE accounts (
  id $idType,
  name $textType,
  balance $realType,
  color $intType,
  icon $intType,
  created_at $textType
)
''');

    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  account_id $intType,
  goal_id $intType,
  category_id $intType,
  target_account_id $intType,
  type $textType,
  amount $realType,
  description $textType,
  date $textType,
  FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
  FOREIGN KEY (goal_id) REFERENCES goals (id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL,
  FOREIGN KEY (target_account_id) REFERENCES accounts (id) ON DELETE SET NULL
)
''');

    await db.execute('''
    CREATE TABLE goals (
      id $idType,
      name $textType,
      target_amount $realType,
      current_amount $realType,
      deadline $textType,
      color $intType,
      icon $intType,
      status $textType,
      image_path TEXT,
      auto_debit_amount REAL,
      auto_debit_date INTEGER,
      category TEXT DEFAULT 'Lainnya'
    )
    ''');

    await db.execute('''
    CREATE TABLE categories (
      id $idType,
      name $textType,
      icon_code_point $intType,
      color_value $intType,
      order_index $intType,
      is_archived INTEGER DEFAULT 0,
      is_pinned INTEGER DEFAULT 0,
      parent_id INTEGER,
      budget_limit REAL DEFAULT 0.0
    )
    ''');

    await _seedDefaultCategories(db);
    await db.execute('''
    CREATE TABLE debts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_name TEXT NOT NULL,
      amount REAL NOT NULL,
      remaining_amount REAL NOT NULL,
      due_date TEXT,
      type TEXT NOT NULL,
      status TEXT NOT NULL
    )
    ''');
  }

  // Account Operations
  Future<Account> createAccount(Account account) async {
    final db = await instance.database;
    final id = await db.insert('accounts', account.toMap());
    return account.copyWith(id: id);
  }

  Future<List<Account>> readAllAccounts() async {
    final db = await instance.database;
    final result = await db.query('accounts', orderBy: 'created_at ASC');
    return result.map((json) => Account.fromMap(json)).toList();
  }

  Future<int> updateAccount(Account account) async {
    final db = await instance.database;
    return db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await instance.database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction Operations
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    
    await db.transaction((txn) async {
      // 1. Insert transaction
      await txn.insert('transactions', transaction.toMap());

      // 2. Update account balance(s)
      final accountMap = await txn.query('accounts', where: 'id = ?', whereArgs: [transaction.accountId]);
      if (accountMap.isNotEmpty) {
        final account = Account.fromMap(accountMap.first);
        double newBalance = account.balance;
        if (transaction.type == 'deposit') {
          newBalance += transaction.amount;
        } else if (transaction.type == 'withdrawal' || transaction.type == 'transfer') {
          newBalance -= transaction.amount;
        }
        
        await txn.update(
          'accounts',
          {'balance': newBalance},
          where: 'id = ?',
          whereArgs: [transaction.accountId],
        );
      }

      // 3. If transfer, update target account balance
      if (transaction.type == 'transfer' && transaction.targetAccountId != null) {
        final targetAccountMap = await txn.query('accounts', where: 'id = ?', whereArgs: [transaction.targetAccountId]);
        if (targetAccountMap.isNotEmpty) {
          final targetAccount = Account.fromMap(targetAccountMap.first);
          double targetNewBalance = targetAccount.balance + transaction.amount;
          
          await txn.update(
            'accounts',
            {'balance': targetNewBalance},
            where: 'id = ?',
            whereArgs: [transaction.targetAccountId],
          );
        }
      }
    });

    return transaction;
  }

  Future<List<TransactionModel>> readTransactionsByAccount(int accountId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<List<TransactionModel>> readAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<void> deleteTransaction(int id) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 1. Dapatkan data transaksi sebelum dihapus untuk update saldo
      final txMap = await txn.query('transactions', where: 'id = ?', whereArgs: [id]);
      if (txMap.isNotEmpty) {
        final tx = TransactionModel.fromMap(txMap.first);
        
        // 2. Update saldo akun asal (Kebalikan dari saat simpan)
        final accountMap = await txn.query('accounts', where: 'id = ?', whereArgs: [tx.accountId]);
        if (accountMap.isNotEmpty) {
          final account = Account.fromMap(accountMap.first);
          double newBalance = account.balance;
          if (tx.type == 'deposit') {
            newBalance -= tx.amount; // Jika setoran dihapus, saldo berkurang
          } else {
            newBalance += tx.amount; // Jika penarikan dihapus, saldo bertambah
          }
          await txn.update('accounts', {'balance': newBalance}, where: 'id = ?', whereArgs: [tx.accountId]);
        }
      }
      
      // 3. Hapus transaksinya
      await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Goal Operations
  Future<Goal> createGoal(Goal goal) async {
    final db = await instance.database;
    final id = await db.insert('goals', goal.toMap());
    return goal.copyWith(id: id);
  }

  Future<List<Goal>> readAllGoals() async {
    final db = await instance.database;
    final result = await db.query('goals', orderBy: 'deadline ASC');
    return result.map((json) => Goal.fromMap(json)).toList();
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await instance.database;
    return db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category Operations
  Future<int> createCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> readAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'order_index ASC');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCategoryOrders(List<CategoryModel> categories) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      for (int i = 0; i < categories.length; i++) {
        await txn.update(
          'categories',
          {'order_index': i},
          where: 'id = ?',
          whereArgs: [categories[i].id],
        );
      }
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
