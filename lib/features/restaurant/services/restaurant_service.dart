import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/restaurant_model.dart';

class RestaurantService {
  RestaurantService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _restaurantsRef {
    return _firestore.collection('restaurants');
  }

  static Future<void> createRestaurantProfile({
    required String restaurantName,
    required String ownerName,
    required String phone,
    required String address,
    required String city,
    required String serviceArea,
    required bool isVegAvailable,
    required bool isNonVegAvailable,
    required bool isLunchAvailable,
    required bool isDinnerAvailable,
    required double monthlyPrice,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final docRef = _restaurantsRef.doc();

    final restaurant = RestaurantModel(
      id: docRef.id,
      ownerId: currentUser.uid,
      restaurantName: restaurantName,
      ownerName: ownerName,
      phone: phone,
      address: address,
      city: city,
      serviceArea: serviceArea,
      isVegAvailable: isVegAvailable,
      isNonVegAvailable: isNonVegAvailable,
      isLunchAvailable: isLunchAvailable,
      isDinnerAvailable: isDinnerAvailable,
      monthlyPrice: monthlyPrice,
      imageUrl: null,
      isApproved: false,
      isActive: true,
      rating: 0,
      createdAt: DateTime.now(),
    );

    await docRef.set(restaurant.toMap());
  }

  static Stream<List<RestaurantModel>> approvedRestaurantsStream() {
    return _restaurantsRef
        .where('isApproved', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RestaurantModel.fromMap(doc.data()))
              .toList(),
        );
  }

  static Future<RestaurantModel?> getMyRestaurantProfile() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) return null;

    final snapshot = await _restaurantsRef
        .where('ownerId', isEqualTo: currentUser.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return RestaurantModel.fromMap(snapshot.docs.first.data());
  }
}