import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/restaurant_model.dart';

class CustomerRestaurantService {
  CustomerRestaurantService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Stream<List<RestaurantModel>> getRestaurants() {
    return _firestore
        .collection('restaurants')
        .where('isApproved', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => RestaurantModel.fromMap(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}