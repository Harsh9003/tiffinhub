import 'package:flutter/material.dart';

class CustomerFaqPage extends StatelessWidget {
  const CustomerFaqPage({super.key});

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _softOrange = Color(0xFFFFF0E4);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF8A817A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
                children: const [
                  _IntroCard(),
                  SizedBox(height: 18),
                  _FaqSection(
                    title: 'Subscriptions & Plans',
                    items: [
                      _FaqItem(
                        question: 'How do I subscribe to a tiffin plan?',
                        answer:
                            'Open the home page, select a restaurant, choose a weekly or monthly plan, select your delivery address, and send a subscription request.',
                      ),
                      _FaqItem(
                        question: 'Where can I view my active subscription?',
                        answer:
                            'Go to Profile and open My Subscriptions. You will be able to view active, pending, rejected, and expired subscription details.',
                      ),
                      _FaqItem(
                        question: 'Why is my subscription not active yet?',
                        answer:
                            'Your subscription becomes active only after restaurant approval and payment verification are completed.',
                      ),
                    ],
                  ),
                  _FaqSection(
                    title: 'Address Management',
                    items: [
                      _FaqItem(
                        question: 'How do I manage my delivery addresses?',
                        answer:
                            'Go to Profile and open Saved Addresses. You can add, edit, delete, and select your default delivery address.',
                      ),
                      _FaqItem(
                        question: 'Can I change my address during an active plan?',
                        answer:
                            'Yes. If you already have an active delivery plan, the new address may require restaurant approval before it becomes active.',
                      ),
                    ],
                  ),
                  _FaqSection(
                    title: 'Payments',
                    items: [
                      _FaqItem(
                        question: 'Who receives the payment?',
                        answer:
                            'In the current phase, payment is made directly to the restaurant. TiffinHub does not hold customer money.',
                      ),
                      _FaqItem(
                        question: 'How is my payment verified?',
                        answer:
                            'After payment, you submit the transaction reference number. The restaurant verifies the payment from its own bank or UPI app.',
                      ),
                      _FaqItem(
                        question: 'What should I do if I entered the wrong transaction ID?',
                        answer:
                            'Create a support ticket from Help & Support and mention the correct transaction details clearly.',
                      ),
                    ],
                  ),
                  _FaqSection(
                    title: 'Delivery & Meals',
                    items: [
                      _FaqItem(
                        question: 'Can I choose lunch, dinner, or both?',
                        answer:
                            'Yes. Meal selection will be available during subscription request creation where supported by the restaurant.',
                      ),
                      _FaqItem(
                        question: 'Can I pause my meal plan?',
                        answer:
                            'Meal pause and resume options are planned features. Availability may depend on the restaurant policy.',
                      ),
                      _FaqItem(
                        question: 'What happens if the restaurant is closed?',
                        answer:
                            'Restaurant closure updates will be shared through app notifications once the restaurant-side system is active.',
                      ),
                    ],
                  ),
                  _FaqSection(
                    title: 'Reviews & Support',
                    items: [
                      _FaqItem(
                        question: 'Who can submit a restaurant review?',
                        answer:
                            'Only customers with an active or completed subscription should be able to submit restaurant reviews.',
                      ),
                      _FaqItem(
                        question: 'How do I report an issue?',
                        answer:
                            'Go to Profile, open Help & Support, create a new ticket, select the issue type, and submit your message.',
                      ),
                      _FaqItem(
                        question: 'Where can I check my support ticket status?',
                        answer:
                            'Open Help & Support and go to My Tickets. You can view ticket status and admin replies there.',
                      ),
                    ],
                  ),
                  _FaqSection(
                    title: 'Account & Technical Help',
                    items: [
                      _FaqItem(
                        question: 'What should I do if login is not working?',
                        answer:
                            'Check your internet connection, restart the app, and try signing in again with your Google account.',
                      ),
                      _FaqItem(
                        question: 'How do I switch my account?',
                        answer:
                            'Go to Profile and tap Switch Account. You can then sign in with another Google account.',
                      ),
                      _FaqItem(
                        question: 'How do I keep the app updated?',
                        answer:
                            'Install updates from the official app store whenever a new version is available.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(
            child: Text(
              'Frequently Asked Questions',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomerFaqPage._text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6A00),
            Color(0xFFFFA726),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: CustomerFaqPage._orange.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.help_rounded, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Find quick answers about subscriptions, payments, delivery, addresses and support.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  final String title;
  final List<_FaqItem> items;

  const _FaqSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CustomerFaqPage._text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomerFaqPage._orange.withOpacity(0.22)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: CustomerFaqPage._orange,
          collapsedIconColor: CustomerFaqPage._muted,
          leading: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: CustomerFaqPage._softOrange,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.question_answer_rounded,
              color: CustomerFaqPage._orange,
              size: 18,
            ),
          ),
          title: Text(
            question,
            style: const TextStyle(
              color: CustomerFaqPage._text,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  color: CustomerFaqPage._muted,
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}