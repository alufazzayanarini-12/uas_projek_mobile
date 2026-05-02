class TransactionModel {
  final int? id;
  final int accountId;
  final String type; // 'deposit', 'withdrawal', 'transfer'
  final double amount;
  final String description;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.description,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
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
      type: map['type'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}
