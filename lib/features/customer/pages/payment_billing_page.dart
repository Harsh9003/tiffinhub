import 'package:flutter/material.dart';

class PaymentBillingPage extends StatelessWidget {
  const PaymentBillingPage({super.key});

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
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                children: const [
                  _HeaderCard(),
                  SizedBox(height: 18),

                  _SectionTitle('Payment History'),
                  SizedBox(height: 10),
                  _EmptyPaymentCard(),

                  SizedBox(height: 20),
                  _SectionTitle('Billing Information'),
                  SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'Invoices',
                    description:
                        'Verified payments will generate invoice records. You will be able to preview and download invoices from this section.',
                  ),
                  SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.payments_rounded,
                    title: 'Supported Payment Modes',
                    description:
                        'TiffinHub supports UPI and Cash payment flows. UPI payments are verified through transaction reference details. Cash payments are verified through delivery OTP confirmation.',
                  ),
                  SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.verified_rounded,
                    title: 'Payment Verification',
                    description:
                        'Invoices are generated only after successful payment verification by the restaurant or delivery verification flow.',
                  ),

                  SizedBox(height: 20),
                  _SectionTitle('Payment Support'),
                  SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.support_agent_rounded,
                    title: 'Need help with a payment?',
                    description:
                        'If you entered the wrong transaction ID, paid the wrong amount, or have a billing issue, create a support ticket from Help & Support.',
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
              'Payment & Billing',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaymentBillingPage._text,
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

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
            color: PaymentBillingPage._orange.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Track verified payments, billing records, invoices and payment support details.',
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: PaymentBillingPage._text,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _EmptyPaymentCard extends StatelessWidget {
  const _EmptyPaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: PaymentBillingPage._orange.withOpacity(0.18),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: PaymentBillingPage._orange,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No verified payments yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PaymentBillingPage._text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your payment history and downloadable invoices will appear here after payment verification.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PaymentBillingPage._muted,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: PaymentBillingPage._orange.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: PaymentBillingPage._softOrange,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: PaymentBillingPage._orange,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PaymentBillingPage._text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: PaymentBillingPage._muted,
                    fontSize: 12.3,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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