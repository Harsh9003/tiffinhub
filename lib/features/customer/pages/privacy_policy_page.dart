import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _softOrange = Color(0xFFFFF0E4);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF8A7365);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _text,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: const [
            _HeroCard(),
            SizedBox(height: 18),
            _PolicySection(
              icon: Icons.person_rounded,
              title: 'Information We Collect',
              body:
                  'TiffinHub may collect your name, email address, phone number, saved delivery addresses, subscription details, support tickets and basic app activity required to provide the service.',
            ),
            _PolicySection(
              icon: Icons.location_on_rounded,
              title: 'Address and Delivery Data',
              body:
                  'Your delivery address is used to show nearby restaurants, send subscription requests and help restaurants verify whether delivery is available in your area.',
            ),
            _PolicySection(
              icon: Icons.payments_rounded,
              title: 'Payment Information',
              body:
                  'In Phase 1, payments are made directly from the customer to the restaurant. TiffinHub may store payment reference details submitted by the customer for request status and verification purposes. TiffinHub does not hold customer money.',
            ),
            _PolicySection(
              icon: Icons.support_agent_rounded,
              title: 'Support Tickets',
              body:
                  'When you create a support ticket, the issue type, subject, description, ticket status and support replies are stored so that your complaint or request can be tracked properly.',
            ),
            _PolicySection(
              icon: Icons.restaurant_rounded,
              title: 'Restaurant Responsibility',
              body:
                  'Restaurants are responsible for their own menu, delivery availability, payment verification, meal quality, refund handling and cancellation handling according to their service policy.',
            ),
            _PolicySection(
              icon: Icons.security_rounded,
              title: 'Data Protection',
              body:
                  'We aim to keep your information secure and use it only for app functionality, support, subscription management, service communication and legal or safety requirements where applicable.',
            ),
            _PolicySection(
              icon: Icons.delete_outline_rounded,
              title: 'Data Updates and Requests',
              body:
                  'You may update your profile and saved addresses from the app. For account-related or data-related requests, create a support ticket from the Help & Support section.',
            ),
            _FooterNote(),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A1A), Color(0xFFFFA24A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: PrivacyPolicyPage._orange.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.privacy_tip_rounded,
              color: PrivacyPolicyPage._orange,
              size: 30,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy matters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'This page explains how TiffinHub uses customer information for service and support.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PolicySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PrivacyPolicyPage._softOrange),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: PrivacyPolicyPage._softOrange,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: PrivacyPolicyPage._orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PrivacyPolicyPage._text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  body,
                  style: const TextStyle(
                    color: PrivacyPolicyPage._muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PrivacyPolicyPage._softOrange,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'Last updated: June 2026. This policy may be updated as TiffinHub adds new customer, restaurant, delivery or admin features.',
        style: TextStyle(
          color: PrivacyPolicyPage._text,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
      ),
    );
  }
}
