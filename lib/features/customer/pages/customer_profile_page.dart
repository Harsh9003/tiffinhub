
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tiffinhub/features/customer/pages/customer_faq_page.dart';
import 'package:tiffinhub/features/customer/pages/payment_billing_page.dart';

import 'customer_addresses_page.dart';
import 'address_change_request_page.dart';
import 'help_support_page.dart';
import 'privacy_policy_page.dart';
import 'about_tiffinhub_page.dart';
import 'my_subscriptions_page.dart';
import 'customer_payment_page.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF7B6250);

  Future<void> _logout(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _switchAccount(BuildContext context) async {
    await GoogleSignIn().disconnect().catchError((_) async {
      await GoogleSignIn().signOut();
    });
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Please login first.', style: TextStyle(fontWeight: FontWeight.w800))),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final name = _read(data, ['name', 'displayName', 'customerName', 'fullName'], fallback: user.displayName ?? 'Customer');
        final email = _read(data, ['email'], fallback: user.email ?? 'No email available');
        final phone = _read(data, ['phone', 'phoneNumber', 'mobile'], fallback: user.phoneNumber ?? 'Add phone number');
        final photoUrl = _read(data, ['photoUrl', 'photoURL', 'imageUrl'], fallback: user.photoURL ?? '');

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                    children: [
                      _ProfileHeroCard(name: name, email: email, phone: phone, photoUrl: photoUrl, uid: user.uid),
                      const SizedBox(height: 18),
                      const _SectionTitle(title: 'Account'),
                      const SizedBox(height: 10),
                      _PremiumTile(
                        icon: Icons.location_on_rounded,
                        title: 'Saved Addresses',
                        subtitle: 'Manage home, office and other delivery addresses',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerAddressesPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.compare_arrows_rounded,
                        title: 'Address Change Request',
                        subtitle: 'Request approval for active delivery address changes',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressChangeRequestPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.receipt_long_rounded,
                        title: 'My Subscriptions',
                        subtitle: 'View active and pending tiffin plans',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MySubscriptionsPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.payments_rounded,
                        title: 'Payment & Billing',
                        subtitle: 'Payment history, invoices and billing support',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentBillingPage())),
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle(title: 'Support'),
                      const SizedBox(height: 10),
                      _PremiumTile(
                        icon: Icons.quiz_rounded,
                        title: 'FAQ',
                        subtitle: 'Quick answers about plans, payments and app features',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerFaqPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.support_agent_rounded,
                        title: 'Help & Support',
                        subtitle: 'Get help with orders and subscriptions',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Privacy Policy',
                        subtitle: 'Read how your data is used and protected',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
                      ),
                      _PremiumTile(
                        icon: Icons.info_rounded,
                        title: 'About TiffinHub',
                        subtitle: 'App information and service details',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutTiffinHubPage())),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _switchAccount(context),
                              icon: const Icon(Icons.switch_account_rounded),
                              label: const Text('Switch Account'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _logout(context),
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(backgroundColor: _orange, foregroundColor: Colors.white),
                            ),
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
      },
    );
  }

  static String _read(Map<String, dynamic> data, List<String> keys, {required String fallback}) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString().trim();
    }
    return fallback;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
      child: Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
          const Expanded(
            child: Text('My Profile', textAlign: TextAlign.center, style: TextStyle(color: CustomerProfilePage._text, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.uid,
  });

  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('subscription_requests')
          .where('customerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final ad = _readDate(a.data()['createdAt']) ?? DateTime(2000);
          final bd = _readDate(b.data()['createdAt']) ?? DateTime(2000);
          return bd.compareTo(ad);
        });
        final latest = docs.isEmpty ? null : docs.first;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF5A00), Color(0xFFFFA726)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: const Color(0xFFFF6A00).withOpacity(.24), blurRadius: 28, offset: const Offset(0, 14))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _Avatar(photoUrl: photoUrl, name: name),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(.90), fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const _VerifiedBadge(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _PhoneStrip(phone: phone),
              const SizedBox(height: 14),
              if (latest == null)
                _NoRequestCard(onFindPlan: () => Navigator.pop(context))
              else
                _LatestRequestCard(doc: latest),
            ],
          ),
        );
      },
    );
  }
}

class _LatestRequestCard extends StatelessWidget {
  const _LatestRequestCard({required this.doc});

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final restaurant = _read(data, ['restaurantName'], fallback: 'Restaurant');
    final plan = _read(data, ['planName', 'planTitle'], fallback: 'Tiffin Plan');
    final status = _status(data);
    final date = _formatDate(_readDate(data['createdAt']));
    final canPay = status == 'restaurant_approved_payment_pending';

    return Material(
      color: const Color(0xFFFFF8FF).withOpacity(.96),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (canPay) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPaymentPage(requestId: doc.id, requestData: data)));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MySubscriptionsPage()));
          }
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE7D8FF))),
          child: Column(
            children: [
              Row(
                children: [
                  Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFF0E6FF), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.room_service_rounded, color: Color(0xFF7B35D8))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(plan, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: CustomerProfilePage._text, fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(restaurant, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black.withOpacity(.55), fontWeight: FontWeight.w700, fontSize: 12)),
                    ]),
                  ),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.78), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEBDFFF))),
                child: Row(
                  children: [
                    Icon(canPay ? Icons.payments_rounded : Icons.schedule_rounded, color: const Color(0xFF7B35D8), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _message(status),
                        style: const TextStyle(color: Color(0xFF7B35D8), fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                    Text(date, style: TextStyle(color: Colors.black.withOpacity(.55), fontWeight: FontWeight.w800, fontSize: 11)),
                  ],
                ),
              ),
              if (canPay) ...[
                const SizedBox(height: 10),
                const Text('Tap here to complete online payment or choose cash on delivery.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7B35D8), fontWeight: FontWeight.w800, fontSize: 11.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _message(String status) {
    switch (status) {
      case 'restaurant_approved_payment_pending':
        return 'Restaurant approved your request. Payment is pending.';
      case 'customer_payment_submitted':
        return 'Payment proof submitted. Awaiting restaurant verification.';
      case 'payment_verified_plan_active':
      case 'active':
      case 'plan_active':
        return 'Your subscription plan is active.';
      case 'rejected_by_restaurant':
        return 'Request rejected by restaurant.';
      default:
        return 'Awaiting restaurant response';
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'restaurant_approved_payment_pending' => 'Pay Now',
      'customer_payment_submitted' => 'Verification',
      'payment_verified_plan_active' || 'active' || 'plan_active' => 'Active',
      'rejected_by_restaurant' => 'Rejected',
      _ => 'Request Sent',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFEFE3FF), borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: const TextStyle(color: Color(0xFF7B35D8), fontWeight: FontWeight.w900, fontSize: 11)),
    );
  }
}

class _NoRequestCard extends StatelessWidget {
  const _NoRequestCard({required this.onFindPlan});
  final VoidCallback onFindPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.92), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFFEFE4), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.event_busy_rounded, color: CustomerProfilePage._orange)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('No Active Plan', style: TextStyle(color: CustomerProfilePage._text, fontWeight: FontWeight.w900, fontSize: 15)),
              SizedBox(height: 4),
              Text('You do not have any active or pending request.', style: TextStyle(color: CustomerProfilePage._muted, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
          ),
          ElevatedButton(
            onPressed: onFindPlan,
            style: ElevatedButton.styleFrom(backgroundColor: CustomerProfilePage._orange, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Find Plan'),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white.withOpacity(.25))),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: Colors.white, size: 14),
          SizedBox(width: 5),
          Text('Verified Customer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.name});
  final String photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 27,
        backgroundColor: const Color(0xFFE93E7B),
        backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
        child: photoUrl.isEmpty ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)) : null,
      ),
    );
  }
}

class _PhoneStrip extends StatelessWidget {
  const _PhoneStrip({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white.withOpacity(.22))),
      child: Row(
        children: [
          const Icon(Icons.call_rounded, color: Colors.white, size: 17),
          const SizedBox(width: 9),
          Expanded(child: Text(phone, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
          Icon(Icons.edit_square, color: Colors.white.withOpacity(.78), size: 18),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: CustomerProfilePage._text, fontSize: 15.5, fontWeight: FontWeight.w900));
  }
}

class _PremiumTile extends StatelessWidget {
  const _PremiumTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFFFD9BD))),
            child: Row(
              children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFF0E4), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: CustomerProfilePage._orange)),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(color: CustomerProfilePage._text, fontSize: 14.5, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: CustomerProfilePage._muted, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: CustomerProfilePage._muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _status(Map<String, dynamic> data) {
  return (data['status'] ?? data['requestStatus'] ?? '').toString().toLowerCase().trim();
}

String _read(Map<String, dynamic> data, List<String> keys, {required String fallback}) {
  for (final key in keys) {
    final value = data[key];
    if (value != null && value.toString().trim().isNotEmpty) return value.toString().trim();
  }
  return fallback;
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Not available';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
