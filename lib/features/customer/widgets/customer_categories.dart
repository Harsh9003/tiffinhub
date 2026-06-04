import 'package:flutter/material.dart';

class CustomerCategories extends StatelessWidget {
  const CustomerCategories({super.key});

  static const List<_TiffinCategory> categories = [
    _TiffinCategory('Veg', Icons.eco_rounded),
    _TiffinCategory('Non-Veg', Icons.restaurant_rounded),
    _TiffinCategory('Monthly', Icons.calendar_month_rounded),
    _TiffinCategory('Student', Icons.school_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = categories[index];

          return Container(
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFE0B2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: const Color(0xFFFF7A00),
                  size: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TiffinCategory {
  final String title;
  final IconData icon;

  const _TiffinCategory(
    this.title,
    this.icon,
  );
}