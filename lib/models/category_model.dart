class CategoryModel {
  final int? id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final double budgetLimit;
  final bool isArchived;
  final bool isPinned;      // Tambahkan ini
  final int? parentId;     // Tambahkan ini untuk sub-kategori
  final int orderIndex;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.budgetLimit = 0.0,
    this.isArchived = false,
    this.isPinned = false,
    this.parentId,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'budgetLimit': budgetLimit,
      'isArchived': isArchived ? 1 : 0,
      'isPinned': isPinned ? 1 : 0,
      'parentId': parentId,
      'orderIndex': orderIndex,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconCodePoint: map['iconCodePoint'],
      colorValue: map['colorValue'],
      budgetLimit: (map['budgetLimit'] ?? 0.0).toDouble(),
      isArchived: map['isArchived'] == 1,
      isPinned: map['isPinned'] == 1,
      parentId: map['parentId'],
      orderIndex: map['orderIndex'] ?? 0,
    );
  }

  // ── FUNGSI COPYWITH UNTUK MODIFIKASI DATA ──
  CategoryModel copyWith({
    int? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    double? budgetLimit,
    bool? isArchived,
    bool? isPinned,
    int? parentId,
    int? orderIndex,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      parentId: parentId ?? this.parentId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
