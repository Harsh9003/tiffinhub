import 'package:flutter/material.dart';
import '../widgets/customer_header.dart';
import '../widgets/customer_search_bar.dart';
import '../widgets/customer_offer_card.dart';
import '../widgets/restaurant_card.dart';
import '../services/customer_restaurant_service.dart';
import '../../../models/restaurant_model.dart';
import 'restaurant_details_page.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      FocusManager.instance.primaryFocus?.unfocus();
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const SliverToBoxAdapter(child: CustomerHeader()),
            const SliverToBoxAdapter(child: CustomerSearchBar()),
            const SliverToBoxAdapter(child: CustomerOfferCard()),
            SliverToBoxAdapter(
              child: StreamBuilder<List<RestaurantModel>>(
                stream: CustomerRestaurantService.getRestaurants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error: ${snapshot.error}',
                      ),
                    );
                  }

                  final restaurants = snapshot.data ?? [];

                  if (restaurants.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No restaurants available',
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: restaurants.map((restaurant) {
                      return RestaurantCard(
                        restaurantName: restaurant.restaurantName,
                        monthlyPrice: '₹${restaurant.monthlyPrice.toInt()}/month',
                        rating: restaurant.rating,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestaurantDetailsPage(
                                restaurant: restaurant,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}


