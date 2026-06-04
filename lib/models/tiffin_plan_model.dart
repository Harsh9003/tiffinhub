import 'package:cloud_firestore/cloud_firestore.dart';

class TiffinPlanModel {
  final String id;
  final String restaurantId;

  final String title;
  final String description;

  final double price;

  final bool lunch;
  final bool dinner;

  final bool veg;
  final bool nonVeg;

  final bool active;

  final DateTime createdAt;

  const TiffinPlanModel({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.price,
    required this.lunch,
    required this.dinner,
    required this.veg,
    required this.nonVeg,
    required this.active,
    required this.createdAt,
  });

  factory TiffinPlanModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return TiffinPlanModel(
      id: map['id'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      lunch: map['lunch'] ?? false,
      dinner: map['dinner'] ?? false,
      veg: map['veg'] ?? true,
      nonVeg: map['nonVeg'] ?? false,
      active: map['active'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'title': title,
      'description': description,
      'price': price,
      'lunch': lunch,
      'dinner': dinner,
      'veg': veg,
      'nonVeg': nonVeg,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}