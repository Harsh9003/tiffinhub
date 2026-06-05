import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/restaurant_model.dart';

class CustomerRestaurantService {
  CustomerRestaurantService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<RestaurantModel>> getRestaurants() {
    return _firestore
        .collection('restaurants')
        .where('isApproved', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final restaurants = snapshot.docs.map((doc) => RestaurantModel.fromDoc(doc)).where((restaurant) {
        final hasTrial = restaurant.trialPlanEnabled &&
            (restaurant.trialLunchPrice > 0 || restaurant.trialDinnerPrice > 0 || restaurant.trialLunchDinnerPrice > 0);
        final hasWeekly = restaurant.weeklyPlanEnabled &&
            (restaurant.weeklyLunchPrice > 0 || restaurant.weeklyDinnerPrice > 0 || restaurant.weeklyLunchDinnerPrice > 0);
        final hasMonthly = restaurant.monthlyPlanEnabled &&
            (restaurant.monthlyLunchPrice > 0 || restaurant.monthlyDinnerPrice > 0 || restaurant.monthlyLunchDinnerPrice > 0);
        return hasTrial && (hasWeekly || hasMonthly);
      }).toList();

      restaurants.sort((a, b) => b.rating.compareTo(a.rating));
      return restaurants;
    });
  }
}
