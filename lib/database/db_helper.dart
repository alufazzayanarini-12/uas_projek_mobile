import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/goal.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
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
  type $textType,
  amount $realType,
  description $textType,
  date $textType,
      FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
    )
    ''');

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

      // 2. Update account balance
      final accountMap = await txn.query('accounts', where: 'id = ?', whereArgs: [transaction.accountId]);
      if (accountMap.isNotEmpty) {
        final account = Account.fromMap(accountMap.first);
        double newBalance = account.balance;
        if (transaction.type == 'deposit') {
          newBalance += transaction.amount;
        } else if (transaction.type == 'withdrawal') {
          newBalance -= transaction.amount;
        }
        
        await txn.update(
          'accounts',
          {'balance': newBalance},
          where: 'id = ?',
          whereArgs: [transaction.accountId],
        );
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
