import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String restaurantName;
  final String ownerId;
  final String ownerName;
  final String phone;
  final String email;
  final String city;
  final String address;
  final String googleMapLink;
  final String serviceArea;
  final double deliveryRadiusKm;
  final String foodType;
  final String ratingLabel;
  final double rating;
  final int totalRatings;
  final String serviceAreaLabel;
  final String estimatedDeliveryTime;
  final bool isApproved;
  final bool isActive;
  final String registrationStatus;
  final bool trialPlanEnabled;
  final bool weeklyPlanEnabled;
  final bool monthlyPlanEnabled;
  final double trialLunchPrice;
  final double trialDinnerPrice;
  final double trialLunchDinnerPrice;
  final double weeklyLunchPrice;
  final double weeklyDinnerPrice;
  final double weeklyLunchDinnerPrice;
  final double monthlyLunchPrice;
  final double monthlyDinnerPrice;
  final double monthlyLunchDinnerPrice;
  final bool isDeliveryAvailable;
  final bool isPickupAvailable;
  final bool isDineInAvailable;
  final List<String> lunchSlots;
  final List<String> dinnerSlots;
  final List<String> weeklyOffDays;
  final String orderCutoffTime;
  final String upiId;
  final String qrCodeUrl;
  final String accountHolderName;
  final String fssaiNumber;
  final String logoUrl;
  final String coverImageUrl;
  final String rejectionReason;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const RestaurantModel({
    required this.id,
    required this.restaurantName,
    required this.ownerId,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.city,
    required this.address,
    required this.googleMapLink,
    required this.serviceArea,
    required this.deliveryRadiusKm,
    required this.foodType,
    required this.ratingLabel,
    required this.rating,
    required this.totalRatings,
    required this.serviceAreaLabel,
    required this.estimatedDeliveryTime,
    required this.isApproved,
    required this.isActive,
    required this.registrationStatus,
    required this.trialPlanEnabled,
    required this.weeklyPlanEnabled,
    required this.monthlyPlanEnabled,
    required this.trialLunchPrice,
    required this.trialDinnerPrice,
    required this.trialLunchDinnerPrice,
    required this.weeklyLunchPrice,
    required this.weeklyDinnerPrice,
    required this.weeklyLunchDinnerPrice,
    required this.monthlyLunchPrice,
    required this.monthlyDinnerPrice,
    required this.monthlyLunchDinnerPrice,
    required this.isDeliveryAvailable,
    required this.isPickupAvailable,
    required this.isDineInAvailable,
    required this.lunchSlots,
    required this.dinnerSlots,
    required this.weeklyOffDays,
    required this.orderCutoffTime,
    required this.upiId,
    required this.qrCodeUrl,
    required this.accountHolderName,
    required this.fssaiNumber,
    required this.logoUrl,
    required this.coverImageUrl,
    required this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return RestaurantModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return RestaurantModel(
      id: id.isNotEmpty ? id : _readString(data, ['id', 'restaurantId']),
      restaurantName: _readString(data, ['restaurantName', 'name'], fallback: 'Restaurant'),
      ownerId: _readString(data, ['ownerId', 'restaurantOwnerId']),
      ownerName: _readString(data, ['ownerName']),
      phone: _readString(data, ['phone', 'mobile']),
      email: _readString(data, ['email']),
      city: _readString(data, ['city'], fallback: 'Jaipur'),
      address: _readString(data, ['address', 'fullAddress']),
      googleMapLink: _readString(data, ['googleMapLink', 'mapLink']),
      serviceArea: _readString(data, ['serviceArea'], fallback: '5 KM'),
      deliveryRadiusKm: _readDouble(data, ['deliveryRadiusKm'], fallback: 5),
      foodType: _readString(data, ['foodType', 'vegType'], fallback: 'Pure Veg'),
      ratingLabel: _readString(data, ['ratingLabel'], fallback: 'Pure Veg'),
      rating: _readDouble(data, ['rating'], fallback: 4.6),
      totalRatings: _readInt(data, ['totalRatings', 'ratingsCount'], fallback: 0),
      serviceAreaLabel: _readString(data, ['serviceAreaLabel'], fallback: _readString(data, ['serviceArea'], fallback: '5 KM')),
      estimatedDeliveryTime: _readString(data, ['estimatedDeliveryTime', 'deliveryTime'], fallback: '30-45 min'),
      isApproved: data['isApproved'] == true,
      isActive: data['isActive'] == true,
      registrationStatus: _readString(data, ['registrationStatus'], fallback: 'pending_review'),
      trialPlanEnabled: data['trialPlanEnabled'] != false,
      weeklyPlanEnabled: data['weeklyPlanEnabled'] == true,
      monthlyPlanEnabled: data['monthlyPlanEnabled'] != false,
      trialLunchPrice: _readDouble(data, ['trialLunchPrice', 'trialPrice']),
      trialDinnerPrice: _readDouble(data, ['trialDinnerPrice', 'trialPrice']),
      trialLunchDinnerPrice: _readDouble(data, ['trialLunchDinnerPrice']),
      weeklyLunchPrice: _readDouble(data, ['weeklyLunchPrice', 'weeklyPrice']),
      weeklyDinnerPrice: _readDouble(data, ['weeklyDinnerPrice', 'weeklyPrice']),
      weeklyLunchDinnerPrice: _readDouble(data, ['weeklyLunchDinnerPrice']),
      monthlyLunchPrice: _readDouble(data, ['monthlyLunchPrice', 'monthlyPrice']),
      monthlyDinnerPrice: _readDouble(data, ['monthlyDinnerPrice', 'monthlyPrice']),
      monthlyLunchDinnerPrice: _readDouble(data, ['monthlyLunchDinnerPrice']),
      isDeliveryAvailable: data['isDeliveryAvailable'] != false,
      isPickupAvailable: data['isPickupAvailable'] != false,
      isDineInAvailable: data['isDineInAvailable'] == true,
      lunchSlots: _readStringList(data['lunchSlots'], fallback: const ['12:00 PM - 2:00 PM']),
      dinnerSlots: _readStringList(data['dinnerSlots'], fallback: const ['7:00 PM - 9:00 PM']),
      weeklyOffDays: _readStringList(data['weeklyOffDays']),
      orderCutoffTime: _readString(data, ['orderCutoffTime'], fallback: '10:00 AM'),
      upiId: _readString(data, ['upiId']),
      qrCodeUrl: _readString(data, ['qrCodeUrl']),
      accountHolderName: _readString(data, ['accountHolderName', 'businessName']),
      fssaiNumber: _readString(data, ['fssaiNumber']),
      logoUrl: _readString(data, ['logoUrl']),
      coverImageUrl: _readString(data, ['coverImageUrl']),
      rejectionReason: _readString(data, ['rejectionReason']),
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null,
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] as Timestamp : null,
    );
  }

  double get monthlyPrice => monthlyLunchDinnerPrice > 0 ? monthlyLunchDinnerPrice : monthlyLunchPrice;
  double get weeklyPrice => weeklyLunchDinnerPrice > 0 ? weeklyLunchDinnerPrice : weeklyLunchPrice;
  double get trialPrice => trialLunchPrice;

  static String _readString(Map<String, dynamic> data, List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString().trim();
    }
    return fallback;
  }

  static double _readDouble(Map<String, dynamic> data, List<String> keys, {double fallback = 0}) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  static int _readInt(Map<String, dynamic> data, List<String> keys, {int fallback = 0}) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  static List<String> _readStringList(dynamic value, {List<String> fallback = const []}) {
    if (value is List) {
      return value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
    }
    return fallback;
  }
}
