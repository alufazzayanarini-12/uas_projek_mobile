class DebtModel {
  final int? id;
  final String personName;
  final double totalAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final String type; // 'to_me' (others owe me) or 'to_others' (I owe others)
  final String status; // 'active', 'paid'

  DebtModel({
    this.id,
    required this.personName,
    required this.totalAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.type,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_name': personName,
      'total_amount': totalAmount,
      'remaining_amount': remainingAmount,
      'due_date': dueDate.toIso8601String(),
      'type': type,
      'status': status,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'],
      personName: map['person_name'],
      totalAmount: map['total_amount'],
      remainingAmount: map['remaining_amount'],
      dueDate: DateTime.parse(map['due_date']),
      type: map['type'],
      status: map['status'],
    );
  }
}
