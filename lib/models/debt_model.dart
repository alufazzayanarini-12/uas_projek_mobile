class DebtModel {
  final int? id;
  final String contactName;
  final double amount;
  final double remainingAmount;
  final DateTime? dueDate;
  final String type; // 'debt' (hutang) or 'credit' (piutang)
  final String status; // 'active' or 'paid'

  DebtModel({
    this.id,
    required this.contactName,
    required this.amount,
    required this.remainingAmount,
    this.dueDate,
    required this.type,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_name': contactName,
      'amount': amount,
      'remaining_amount': remainingAmount,
      'due_date': dueDate?.toIso8601String(),
      'type': type,
      'status': status,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'],
      contactName: map['contact_name'],
      amount: map['amount'],
      remainingAmount: map['remaining_amount'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      type: map['type'],
      status: map['status'],
    );
  }
}
