import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final int orderIndex;
  final bool isArchived;
  final bool isPinned;
  final int? parentId;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.orderIndex = 0,
    this.isArchived = false,
    this.isPinned = false,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code_point': iconCodePoint,
      'color_value': colorValue,
      'order_index': orderIndex,
      'is_archived': isArchived ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'parent_id': parentId,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconCodePoint: map['icon_code_point'],
      colorValue: map['color_value'],
      orderIndex: map['order_index'] ?? 0,
      isArchived: map['is_archived'] == 1,
      isPinned: map['is_pinned'] == 1,
      parentId: map['parent_id'],
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    int? orderIndex,
    bool? isArchived,
    bool? isPinned,
    int? parentId,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      orderIndex: orderIndex ?? this.orderIndex,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      parentId: parentId ?? this.parentId,
    );
  }
}
