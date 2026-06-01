class DebtModel {
  final int? id;
  final String contactName;
  final double amount;
  final double remainingAmount;
  final DateTime? dueDate;
  final String type; // 'debt' (hutang) or 'credit' (piutang)
  final String status; // 'active' or 'paid'
  final DateTime? reminderDateTime;

  DebtModel({
    this.id,
    required this.contactName,
    required this.amount,
    required this.remainingAmount,
    this.dueDate,
    required this.type,
    this.status = 'active',
    this.reminderDateTime,
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
      'reminder_date_time': reminderDateTime?.toIso8601String(),
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
      reminderDateTime: map['reminder_date_time'] != null ? DateTime.parse(map['reminder_date_time']) : null,
    );
  }

  DebtModel copyWith({
    int? id,
    String? contactName,
    double? amount,
    double? remainingAmount,
    DateTime? dueDate,
    String? type,
    String? status,
    DateTime? reminderDateTime,
  }) {
    return DebtModel(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      amount: amount ?? this.amount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      status: status ?? this.status,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
    );
  }
}
