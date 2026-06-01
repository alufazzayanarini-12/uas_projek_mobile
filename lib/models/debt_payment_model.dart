class DebtPaymentModel {
  final int? id;
  final int debtId;
  final double amount;
  final DateTime date;

  DebtPaymentModel({
    this.id,
    required this.debtId,
    required this.amount,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debt_id': debtId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory DebtPaymentModel.fromMap(Map<String, dynamic> map) {
    return DebtPaymentModel(
      id: map['id'],
      debtId: map['debt_id'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  DebtPaymentModel copyWith({
    int? id,
    int? debtId,
    double? amount,
    DateTime? date,
  }) {
    return DebtPaymentModel(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
