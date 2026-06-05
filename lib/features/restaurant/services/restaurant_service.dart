import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/restaurant_model.dart';

class RestaurantService {
  RestaurantService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static CollectionReference<Map<String, dynamic>> get _restaurants =>
      _db.collection('restaurants');

  static Stream<RestaurantModel?> watchMyRestaurant() {
    return _restaurants.where('ownerId', isEqualTo: _uid).limit(1).snapshots().map(
      (snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return RestaurantModel.fromDoc(snapshot.docs.first);
      },
    );
  }

  static Future<String?> getMyRestaurantId() async {
    final snapshot = await _restaurants.where('ownerId', isEqualTo: _uid).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  static Future<void> registerOrUpdateRestaurant({
    String? restaurantId,
    required Map<String, dynamic> data,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please sign in before submitting restaurant details.');
    }

    final existingId = restaurantId ?? await getMyRestaurantId();
    final docRef = existingId == null ? _restaurants.doc() : _restaurants.doc(existingId);

    final payload = <String, dynamic>{
      ...data,
      'id': docRef.id,
      'restaurantId': docRef.id,
      'ownerId': user.uid,
      'ownerEmail': user.email ?? '',
      'registrationStatus': 'pending_review',
      'isApproved': false,
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (existingId == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
      payload['rating'] = 0.0;
      payload['totalRatings'] = 0;
      payload['activeCustomers'] = 0;
      payload['todayDeliveries'] = 0;
      payload['pendingDeliveries'] = 0;
      payload['revenueToday'] = 0;
      payload['healthScore'] = 0;
    }

    await docRef.set(payload, SetOptions(merge: true));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchSubscriptionRequests(String restaurantId) {
    return _db
        .collection('subscription_requests')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchTodayDeliveries(String restaurantId) {
    return _db
        .collection('deliveries')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots();
  }

  static Future<void> updateRestaurantOpenStatus({
    required String restaurantId,
    required bool isOpen,
  }) async {
    await _restaurants.doc(restaurantId).update({
      'isOpenNow': isOpen,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  static Future<Map<String, dynamic>?> getMyRestaurantData() async {
    final snapshot =
        await _restaurants.where('ownerId', isEqualTo: _uid).limit(1).get();

    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.data();
  }
}
