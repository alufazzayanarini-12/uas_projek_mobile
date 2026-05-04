class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final int color;
  final int icon;
  final String status; // 'active', 'completed', 'cancelled'
  final String? imagePath;
  final double? autoDebitAmount;
  final int? autoDebitDate;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    this.color = 0xFF2196F3, // Default blue
    this.icon = 58162, // Default flag icon
    this.status = 'active',
    this.imagePath,
    this.autoDebitAmount,
    this.autoDebitDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'color': color,
      'icon': icon,
      'status': status,
      'image_path': imagePath,
      'auto_debit_amount': autoDebitAmount,
      'auto_debit_date': autoDebitDate,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['target_amount'],
      currentAmount: map['current_amount'],
      deadline: DateTime.parse(map['deadline']),
      color: map['color'] ?? 0xFF2196F3,
      icon: map['icon'] ?? 58162,
      status: map['status'] ?? 'active',
      imagePath: map['image_path'],
      autoDebitAmount: map['auto_debit_amount'],
      autoDebitDate: map['auto_debit_date'],
    );
  }

  Goal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    int? color,
    int? icon,
    String? status,
    String? imagePath,
    double? autoDebitAmount,
    int? autoDebitDate,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      autoDebitAmount: autoDebitAmount ?? this.autoDebitAmount,
      autoDebitDate: autoDebitDate ?? this.autoDebitDate,
    );
  }
}
