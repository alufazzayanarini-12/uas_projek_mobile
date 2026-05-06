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
  final String category; // 'Gadget', 'Liburan', 'Pendidikan', 'Kendaraan', 'Dana Darurat', 'Lainnya'

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    this.color = 0xFF2196F3,
    this.icon = 58162,
    this.status = 'active',
    this.imagePath,
    this.autoDebitAmount,
    this.autoDebitDate,
    this.category = 'Lainnya',
  });

  // ── Calculated Properties ──
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0, double.infinity);

  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  double get progressFraction =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentAmount >= targetAmount;

  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  bool get isOverdue => daysRemaining < 0 && !isCompleted;

  double get dailySuggestion {
    if (isCompleted || daysRemaining <= 0) return 0;
    return remainingAmount / daysRemaining;
  }

  double get monthlySuggestion {
    if (isCompleted) return 0;
    final months = (daysRemaining / 30.0).ceil().clamp(1, 9999);
    return remainingAmount / months;
  }

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
      'category': category,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline']),
      color: map['color'] ?? 0xFF2196F3,
      icon: map['icon'] ?? 58162,
      status: map['status'] ?? 'active',
      imagePath: map['image_path'],
      autoDebitAmount: map['auto_debit_amount'] != null
          ? (map['auto_debit_amount'] as num).toDouble()
          : null,
      autoDebitDate: map['auto_debit_date'],
      category: map['category'] ?? 'Lainnya',
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
    String? category,
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
      category: category ?? this.category,
    );
  }

  // ── Preset Categories ──
  static const List<Map<String, dynamic>> presetCategories = [
    {'name': 'Gadget', 'icon': 0xe325, 'color': 0xFF2196F3},       // Icons.smartphone
    {'name': 'Liburan', 'icon': 0xe0b2, 'color': 0xFF4CAF50},      // Icons.flight
    {'name': 'Pendidikan', 'icon': 0xe80c, 'color': 0xFF9C27B0},    // Icons.school
    {'name': 'Kendaraan', 'icon': 0xe1d7, 'color': 0xFFFF9800},     // Icons.directions_car
    {'name': 'Dana Darurat', 'icon': 0xe8e8, 'color': 0xFFF44336},  // Icons.shield
    {'name': 'Rumah', 'icon': 0xe318, 'color': 0xFF795548},         // Icons.home
    {'name': 'Kesehatan', 'icon': 0xea6b, 'color': 0xFFE91E63},     // Icons.health_and_safety
    {'name': 'Lainnya', 'icon': 0xe1b1, 'color': 0xFF607D8B},       // Icons.category
  ];

  static Map<String, dynamic>? getCategoryPreset(String name) {
    try {
      return presetCategories.firstWhere((c) => c['name'] == name);
    } catch (_) {
      return presetCategories.last;
    }
  }
}
