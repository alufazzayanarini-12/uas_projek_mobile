class TransactionModel {
  final int? id;
  final int accountId;
  final int? goalId;
  final int? categoryId;
  final int? targetAccountId; // For transfers
  final String type; // 'deposit', 'withdrawal', 'transfer'
  final double amount;
  final String description;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.accountId,
    this.goalId,
    this.categoryId,
    this.targetAccountId,
    required this.type,
    required this.amount,
    required this.description,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'goal_id': goalId,
      'category_id': categoryId,
      'target_account_id': targetAccountId,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      accountId: map['account_id'],
      goalId: map['goal_id'],
      categoryId: map['category_id'],
      targetAccountId: map['target_account_id'],
      type: map['type'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}
