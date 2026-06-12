import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantReviewsSection extends StatelessWidget {
  const RestaurantReviewsSection({super.key, required this.restaurantId});

  final String restaurantId;

  static const Color _orange = Color(0xFFFF7A00);
  static const Color _border = Color(0xFFFFE0B2);

  @override
  Widget build(BuildContext context) {
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
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .where('restaurantId', isEqualTo: restaurantId)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingReviews();
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const _EmptyReviewsState();
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final name = _read(
                    data,
                    ['customerName', 'userName', 'name'],
                    fallback: 'Customer',
                  );
                  final comment = _read(
                    data,
                    ['comment', 'review', 'text', 'message'],
                    fallback: 'No comment added.',
                  );
                  final rating = _readRating(data['rating']);

                  return _ReviewCard(
                    name: name,
                    comment: comment,
                    rating: rating,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _read(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  static double _readRating(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.comment,
    required this.rating,
  });

  final String name;
  final String comment;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RestaurantReviewsSection._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFF3E0),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: RestaurantReviewsSection._orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
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
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReviewsState extends StatelessWidget {
  const _EmptyReviewsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RestaurantReviewsSection._border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No customer reviews yet.',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF202124),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Reviews will appear here after subscribed customers share feedback.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingReviews extends StatelessWidget {
  const _LoadingReviews();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RestaurantReviewsSection._border),
      ),
      child: const LinearProgressIndicator(minHeight: 2),
    );
  }
}
