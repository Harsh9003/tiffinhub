import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String ownerId;
  final String restaurantName;
  final String ownerName;
  final String phone;
  final String address;
  final String city;
  final String serviceArea;
  final bool isVegAvailable;
  final bool isNonVegAvailable;
  final bool isLunchAvailable;
  final bool isDinnerAvailable;
  final double monthlyPrice;
  final String? imageUrl;
  final bool isApproved;
  final bool isActive;
  final double rating;
  final DateTime createdAt;

  const RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.restaurantName,
    required this.ownerName,
    required this.phone,
    required this.address,
    required this.city,
    required this.serviceArea,
    required this.isVegAvailable,
    required this.isNonVegAvailable,
    required this.isLunchAvailable,
    required this.isDinnerAvailable,
    required this.monthlyPrice,
    this.imageUrl,
    required this.isApproved,
    required this.isActive,
    required this.rating,
    required this.createdAt,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      serviceArea: map['serviceArea'] ?? '',
      isVegAvailable: map['isVegAvailable'] ?? true,
      isNonVegAvailable: map['isNonVegAvailable'] ?? false,
      isLunchAvailable: map['isLunchAvailable'] ?? true,
      isDinnerAvailable: map['isDinnerAvailable'] ?? true,
      monthlyPrice: (map['monthlyPrice'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      isApproved: map['isApproved'] ?? false,
      isActive: map['isActive'] ?? true,
      rating: (map['rating'] ?? 0).toDouble(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'restaurantName': restaurantName,
      'ownerName': ownerName,
      'phone': phone,
      'address': address,
      'city': city,
      'serviceArea': serviceArea,
      'isVegAvailable': isVegAvailable,
      'isNonVegAvailable': isNonVegAvailable,
      'isLunchAvailable': isLunchAvailable,
      'isDinnerAvailable': isDinnerAvailable,
      'monthlyPrice': monthlyPrice,
      'imageUrl': imageUrl,
      'isApproved': isApproved,
      'isActive': isActive,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}