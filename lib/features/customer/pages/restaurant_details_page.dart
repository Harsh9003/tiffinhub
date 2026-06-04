import 'package:flutter/material.dart';

import '../../../models/restaurant_model.dart';
import '../widgets/restaurant_details/restaurant_detail_header.dart';
import '../widgets/restaurant_details/restaurant_image_gallery.dart';
import '../widgets/restaurant_details/restaurant_info_card.dart';
import '../widgets/restaurant_details/restaurant_menu_preview.dart';
import '../widgets/restaurant_details/restaurant_plan_card.dart';
import '../widgets/restaurant_details/restaurant_reviews_section.dart';
import '../widgets/restaurant_details/start_subscription_sheet.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailsPage({
    super.key,
    required this.restaurant,
  });

  void _openSubscriptionPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StartSubscriptionSheet(
          restaurantName: restaurant.restaurantName,
          planPrice: restaurant.monthlyPrice,
          trialPrice: restaurant.trialPrice,
          weeklyPrice: restaurant.weeklyPrice,
          monthlyLunchPrice: restaurant.monthlyLunchPrice,
          monthlyDinnerPrice: restaurant.monthlyDinnerPrice,
          monthlyLunchDinnerPrice: restaurant.monthlyLunchDinnerPrice,
          weeklyLunchPrice: restaurant.weeklyLunchPrice,
          weeklyDinnerPrice: restaurant.weeklyDinnerPrice,
          weeklyLunchDinnerPrice: restaurant.weeklyLunchDinnerPrice,
          trialLunchPrice: restaurant.trialLunchPrice,
          trialDinnerPrice: restaurant.trialDinnerPrice,
          trialLunchDinnerPrice: restaurant.trialLunchDinnerPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthlyDisplayPrice = restaurant.monthlyLunchDinnerPrice > 0
        ? restaurant.monthlyLunchDinnerPrice
        : restaurant.monthlyPrice;

    final weeklyDisplayPrice =
        restaurant.weeklyLunchDinnerPrice > 0 ? restaurant.weeklyLunchDinnerPrice : restaurant.weeklyPrice;

    final trialDisplayPrice =
        restaurant.trialLunchPrice > 0 ? restaurant.trialLunchPrice : restaurant.trialPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      body: SafeArea(
        child: Column(
          children: [
            RestaurantDetailHeader(restaurant: restaurant),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 18),
                children: [
                  const RestaurantImageGallery(),
                  const SizedBox(height: 18),
                  RestaurantInfoCard(restaurant: restaurant),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'Available Tiffin Plans'),
                  const SizedBox(height: 12),
                  RestaurantPlanCard(
                    title: 'Monthly Veg Plan',
                    description: 'Lunch + Dinner • 30 Days',
                    price: monthlyDisplayPrice,
                  ),
                  const SizedBox(height: 12),
                  RestaurantPlanCard(
                    title: 'Weekly Veg Plan',
                    description: 'Lunch + Dinner • 7 Days',
                    price: weeklyDisplayPrice,
                  ),
                  const SizedBox(height: 12),
                  RestaurantPlanCard(
                    title: 'Trial Tiffin',
                    description: 'Single meal trial',
                    price: trialDisplayPrice,
                  ),
                  const SizedBox(height: 18),
                  const RestaurantMenuPreview(),
                  const SizedBox(height: 18),
                  const RestaurantReviewsSection(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _openSubscriptionPage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.orange.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Subscription',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
