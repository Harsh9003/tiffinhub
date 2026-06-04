import 'package:flutter/material.dart';

class RestaurantReviewsSection extends StatelessWidget {
  const RestaurantReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      (
        'Rahul Sharma',
        'Food quality is excellent and delivery is always on time.',
        5.0
      ),
      (
        'Priya Verma',
        'Good taste and reasonable pricing.',
        4.5
      ),
      (
        'Amit Singh',
        'Perfect for office lunch plans.',
        4.8
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Reviews',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),

          ...reviews.map(
            (review) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFFE0B2),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            const Color(0xFFFFF3E0),
                        child: Text(
                          review.$1[0],
                          style: const TextStyle(
                            color: Color(0xFFFF7A00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          review.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFB300),
                            size: 18,
                          ),
                          Text(
                            review.$3.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    review.$2,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}