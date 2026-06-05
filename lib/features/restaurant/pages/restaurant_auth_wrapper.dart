import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'restaurant_dashboard_page.dart';
import 'restaurant_registration_page.dart';
import 'restaurant_registration_status_page.dart';

class RestaurantAuthWrapper extends StatelessWidget {
  const RestaurantAuthWrapper({super.key});

  static const Color _bg = Color(0xFFFFFBF7);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Please sign in before accessing the restaurant portal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _RestaurantLoadingScreen();
        }

        if (snapshot.hasError) {
          return _RestaurantErrorScreen(
            message: 'Unable to load restaurant profile. Please try again.',
            onRetry: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RestaurantAuthWrapper()),
              );
            },
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const RestaurantRegistrationPage();
        }

        final doc = docs.first;
        final data = doc.data();

        final status = (data['registrationStatus'] ?? '').toString();
        final isApproved = data['isApproved'] == true;
        final isActive = data['isActive'] == true;

        if (status == 'approved' && isApproved && isActive) {
          return const RestaurantDashboardPage();
        }

        return RestaurantRegistrationStatusPage(
          restaurantId: doc.id,
        );
      },
    );
  }
}

class _RestaurantLoadingScreen extends StatelessWidget {
  const _RestaurantLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: RestaurantAuthWrapper._bg,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _RestaurantErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RestaurantErrorScreen({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RestaurantAuthWrapper._bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 42),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
