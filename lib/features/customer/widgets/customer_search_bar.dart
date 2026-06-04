import 'package:flutter/material.dart';

class CustomerSearchBar extends StatelessWidget {
  const CustomerSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: Color(0xFFFF7A00),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search tiffin services, meals, areas...',
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
            ),
            Icon(
              Icons.tune_rounded,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}