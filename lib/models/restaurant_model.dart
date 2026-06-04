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
  final double trialPrice;
  final double weeklyPrice;

  final double monthlyLunchPrice;
  final double monthlyDinnerPrice;
  final double monthlyLunchDinnerPrice;
  final double weeklyLunchPrice;
  final double weeklyDinnerPrice;
  final double weeklyLunchDinnerPrice;
  final double trialLunchPrice;
  final double trialDinnerPrice;
  final double trialLunchDinnerPrice;

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
    required this.trialPrice,
    required this.weeklyPrice,
    required this.monthlyLunchPrice,
    required this.monthlyDinnerPrice,
    required this.monthlyLunchDinnerPrice,
    required this.weeklyLunchPrice,
    required this.weeklyDinnerPrice,
    required this.weeklyLunchDinnerPrice,
    required this.trialLunchPrice,
    required this.trialDinnerPrice,
    required this.trialLunchDinnerPrice,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    final monthlyPrice = (map['monthlyPrice'] ?? 0).toDouble();
    final weeklyPrice = (map['weeklyPrice'] ?? 0).toDouble();
    final trialPrice = (map['trialPrice'] ?? 0).toDouble();

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
      monthlyPrice: monthlyPrice,
      trialPrice: trialPrice,
      weeklyPrice: weeklyPrice,
      imageUrl: map['imageUrl'],
      isApproved: map['isApproved'] ?? false,
      isActive: map['isActive'] ?? true,
      rating: (map['rating'] ?? 0).toDouble(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      monthlyLunchPrice: (map['monthlyLunchPrice'] ?? monthlyPrice).toDouble(),
      monthlyDinnerPrice: (map['monthlyDinnerPrice'] ?? monthlyPrice).toDouble(),
      monthlyLunchDinnerPrice:
          (map['monthlyLunchDinnerPrice'] ?? monthlyPrice).toDouble(),
      weeklyLunchPrice: (map['weeklyLunchPrice'] ?? weeklyPrice).toDouble(),
      weeklyDinnerPrice: (map['weeklyDinnerPrice'] ?? weeklyPrice).toDouble(),
      weeklyLunchDinnerPrice:
          (map['weeklyLunchDinnerPrice'] ?? weeklyPrice).toDouble(),
      trialLunchPrice: (map['trialLunchPrice'] ?? trialPrice).toDouble(),
      trialDinnerPrice: (map['trialDinnerPrice'] ?? trialPrice).toDouble(),
      trialLunchDinnerPrice:
          (map['trialLunchDinnerPrice'] ?? trialPrice).toDouble(),
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
      'trialPrice': trialPrice,
      'weeklyPrice': weeklyPrice,
      'monthlyLunchPrice': monthlyLunchPrice,
      'monthlyDinnerPrice': monthlyDinnerPrice,
      'monthlyLunchDinnerPrice': monthlyLunchDinnerPrice,
      'weeklyLunchPrice': weeklyLunchPrice,
      'weeklyDinnerPrice': weeklyDinnerPrice,
      'weeklyLunchDinnerPrice': weeklyLunchDinnerPrice,
      'trialLunchPrice': trialLunchPrice,
      'trialDinnerPrice': trialDinnerPrice,
      'trialLunchDinnerPrice': trialLunchDinnerPrice,
      'imageUrl': imageUrl,
      'isApproved': isApproved,
      'isActive': isActive,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
