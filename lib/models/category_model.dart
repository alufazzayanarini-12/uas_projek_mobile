class CategoryModel {
  final int? id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final double budgetLimit;
  final bool isArchived;
  final bool isPinned;
  final int? parentId;
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

  // ── SESUAIKAN DENGAN NAMA KOLOM DI DATABASE (SNAKE_CASE) ──
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code_point': iconCodePoint,
      'color_value': colorValue,
      'budget_limit': budgetLimit,
      'is_archived': isArchived ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'parent_id': parentId,
      'order_index': orderIndex,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconCodePoint: map['icon_code_point'],
      colorValue: map['color_value'],
      budgetLimit: (map['budget_limit'] ?? 0.0).toDouble(),
      isArchived: map['is_archived'] == 1,
      isPinned: map['is_pinned'] == 1,
      parentId: map['parent_id'],
      orderIndex: map['order_index'] ?? 0,
    );
  }

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
