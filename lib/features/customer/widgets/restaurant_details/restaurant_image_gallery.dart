import 'package:flutter/material.dart';

class RestaurantImageGallery extends StatelessWidget {
  const RestaurantImageGallery({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          return Container(
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF7A00),
                  Color(0xFFFFA726),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.restaurant,
                size: 80,
                color: Colors.white,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemCount: 3,
      ),
    );
  }
}