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
        version: 8,
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

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const realType = 'REAL NOT NULL';
      
      await db.execute('''
      CREATE TABLE goals (
        id $idType,
        name $textType,
        target_amount $realType,
        current_amount $realType,
        deadline $textType
      )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE goals ADD COLUMN color INTEGER DEFAULT 4278190080'); // 0xFF000000 dummy
      await db.execute('ALTER TABLE goals ADD COLUMN icon INTEGER DEFAULT 58162');
      await db.execute('ALTER TABLE goals ADD COLUMN status TEXT DEFAULT "active"');
      await db.execute('ALTER TABLE goals ADD COLUMN image_path TEXT');
      await db.execute('ALTER TABLE goals ADD COLUMN auto_debit_amount REAL');
      await db.execute('ALTER TABLE goals ADD COLUMN auto_debit_date INTEGER');
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE transactions ADD COLUMN goal_id INTEGER');
    }

    if (oldVersion < 5) {
      await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code_point INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        order_index INTEGER NOT NULL
      )
      ''');
      await _seedDefaultCategories(db);
    }

    if (oldVersion < 6) {
      await db.execute('ALTER TABLE categories ADD COLUMN is_archived INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE categories ADD COLUMN is_pinned INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE categories ADD COLUMN parent_id INTEGER');
    }

    if (oldVersion < 7) {
      await db.execute('ALTER TABLE transactions ADD COLUMN category_id INTEGER');
    }
    
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE transactions ADD COLUMN target_account_id INTEGER');
    }
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final List<Map<String, dynamic>> defaults = [
      {'name': 'Gadget', 'icon_code_point': 58167, 'color_value': 4280391411, 'order_index': 0}, // computer
      {'name': 'Kendaraan', 'icon_code_point': 58162, 'color_value': 4294918656, 'order_index': 1}, // directions_car
      {'name': 'Liburan', 'icon_code_point': 58156, 'color_value': 4280361249, 'order_index': 2}, // airplanemode_active
      {'name': 'Pendidikan', 'icon_code_point': 58169, 'color_value': 4288534784, 'order_index': 3}, // school
      {'name': 'Dana Darurat', 'icon_code_point': 58161, 'color_value': 4294901760, 'order_index': 4}, // warning
    ];

    for (var cat in defaults) {
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
      auto_debit_date INTEGER
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
      parent_id INTEGER
    )
    ''');

    await _seedDefaultCategories(db);
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
