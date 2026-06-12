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

  const RestaurantDetailsPage({super.key, required this.restaurant});

  void _openSubscriptionPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StartSubscriptionSheet(
          restaurantId: restaurant.id,
          restaurantName: restaurant.restaurantName,
          planPrice: restaurant.monthlyPrice,
          trialPrice: restaurant.trialPrice,
          weeklyPrice: restaurant.weeklyPrice,
          ownerName: restaurant.ownerName,
          lunchSlots: restaurant.lunchSlots,
          dinnerSlots: restaurant.dinnerSlots,
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
    final plans = <Widget>[];

    if (restaurant.trialPlanEnabled) {
      plans.add(RestaurantPlanCard(
        title: 'Trial Tiffin',
        description: 'Single meal trial available',
        price: restaurant.trialPrice,
      ));
    }

    if (restaurant.weeklyPlanEnabled) {
      plans.add(RestaurantPlanCard(
        title: 'Weekly Veg Plan',
        description: 'Weekly lunch, dinner or both meals',
        price: restaurant.weeklyPrice,
      ));
    }

    if (restaurant.monthlyPlanEnabled) {
      plans.add(RestaurantPlanCard(
        title: 'Monthly Veg Plan',
        description: 'Monthly lunch, dinner or both meals',
        price: restaurant.monthlyPrice,
      ));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      body: SafeArea(
        child: Column(
          children: [
            RestaurantDetailHeader(restaurant: restaurant),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 14),
                children: [
                  const RestaurantImageGallery(),
                  const SizedBox(height: 14),
                  RestaurantInfoCard(restaurant: restaurant),
                  const SizedBox(height: 14),
                  const _SectionTitle(title: 'Available Tiffin Plans'),
                  const SizedBox(height: 10),
                  if (plans.isEmpty)
                    const _EmptyPlansCard()
                  else
                    ...plans.expand((plan) => [plan, const SizedBox(height: 10)]),
                  const SizedBox(height: 8),
                  RestaurantMenuPreview(restaurantId: restaurant.id),
                  const SizedBox(height: 14),
                  RestaurantReviewsSection(restaurantId: restaurant.id),
                  const SizedBox(height: 86),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
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
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      );
}

class _EmptyPlansCard extends StatelessWidget {
  const _EmptyPlansCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: const Text(
        'No tiffin plans are available right now.',
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
