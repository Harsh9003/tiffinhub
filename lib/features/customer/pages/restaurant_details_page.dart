import 'package:flutter/material.dart';

import '../../../models/restaurant_model.dart';
import '../widgets/restaurant_details/restaurant_bottom_button.dart';
import '../widgets/restaurant_details/restaurant_detail_header.dart';
import '../widgets/restaurant_details/restaurant_image_gallery.dart';
import '../widgets/restaurant_details/restaurant_info_card.dart';
import '../widgets/restaurant_details/restaurant_menu_preview.dart';
import '../widgets/restaurant_details/restaurant_plan_card.dart';
import '../widgets/restaurant_details/restaurant_reviews_section.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailsPage({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
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
                    price: restaurant.monthlyPrice,
                  ),

                  const SizedBox(height: 18),
                  const RestaurantMenuPreview(),

                  const SizedBox(height: 18),
                  const RestaurantReviewsSection(),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            const RestaurantBottomButton(),
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