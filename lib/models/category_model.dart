class CategoryModel {
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final int orderIndex;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_value': colorValue,
      'order_index': orderIndex,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconCode: map['icon_code'],
      colorValue: map['color_value'],
      orderIndex: map['order_index'] ?? 0,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    int? iconCode,
    int? colorValue,
    int? orderIndex,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
