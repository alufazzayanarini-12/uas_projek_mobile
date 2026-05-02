class Account {
  final int? id;
  final String name;
  final double balance;
  final int colorValue;
  final int iconCodePoint;
  final DateTime createdAt;

  Account({
    this.id,
    required this.name,
    this.balance = 0.0,
    required this.colorValue,
    required this.iconCodePoint,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'color': colorValue,
      'icon': iconCodePoint,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      colorValue: map['color'],
      iconCodePoint: map['icon'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    int? colorValue,
    int? iconCodePoint,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
