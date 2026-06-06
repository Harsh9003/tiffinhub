import 'package:flutter/material.dart';

class AboutTiffinHubPage extends StatelessWidget {
  const AboutTiffinHubPage({super.key});

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
          'About TiffinHub',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: const [
            _HeroCard(),
            SizedBox(height: 18),
            _InfoTile(
              icon: Icons.apps_rounded,
              title: 'App Name',
              value: 'TiffinHub',
            ),
            _InfoTile(
              icon: Icons.verified_rounded,
              title: 'Version',
              value: '1.0.0+1',
            ),
            _InfoTile(
              icon: Icons.restaurant_menu_rounded,
              title: 'Service Type',
              value: 'Tiffin subscription and restaurant discovery platform',
            ),
            _InfoTile(
              icon: Icons.phone_android_rounded,
              title: 'Current Module',
              value: 'Customer App',
            ),
            SizedBox(height: 8),
            _SectionCard(
              icon: Icons.flag_rounded,
              title: 'Our Purpose',
              body:
                  'TiffinHub helps customers discover nearby tiffin services, view restaurant details, manage addresses, send subscription requests and track support tickets from one place.',
            ),
            _SectionCard(
              icon: Icons.account_tree_rounded,
              title: 'Project Roadmap',
              body:
                  'The customer app is being completed first. Restaurant, delivery and admin modules will be developed separately so every side of the service remains clean, scalable and easy to maintain.',
            ),
            _SectionCard(
              icon: Icons.payment_rounded,
              title: 'Payment Note',
              body:
                  'In Phase 1, customer payments are planned to go directly to the restaurant. TiffinHub will only manage request status, payment reference tracking and support records.',
            ),
            _SectionCard(
              icon: Icons.support_agent_rounded,
              title: 'Support',
              body:
                  'For subscription, delivery, payment, address or app-related issues, customers can create a support ticket from the Help & Support section.',
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
            color: AboutTiffinHubPage._orange.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.restaurant_rounded,
              color: AboutTiffinHubPage._orange,
              size: 31,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TiffinHub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'A professional platform for tiffin subscriptions, customer requests and service support.',
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AboutTiffinHubPage._softOrange),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AboutTiffinHubPage._softOrange,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AboutTiffinHubPage._orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AboutTiffinHubPage._muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AboutTiffinHubPage._text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
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

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _SectionCard({
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
        border: Border.all(color: AboutTiffinHubPage._softOrange),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AboutTiffinHubPage._orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AboutTiffinHubPage._text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  body,
                  style: const TextStyle(
                    color: AboutTiffinHubPage._muted,
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
        color: AboutTiffinHubPage._softOrange,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        '© 2026 TiffinHub. All rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AboutTiffinHubPage._text,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
