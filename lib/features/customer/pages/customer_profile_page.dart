import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'customer_addresses_page.dart';
import 'address_change_request_page.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _softOrange = Color(0xFFFFF0E4);
  static const Color _text = Color(0xFF241A14);

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
        body: Center(
          child: Text(
            'Please login first.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};

        final name = _readString(
          data,
          ['name', 'displayName', 'customerName', 'fullName'],
          fallback: user.displayName ?? 'Customer',
        );

        final email = _readString(
          data,
          ['email'],
          fallback: user.email ?? 'No email available',
        );

        final phone = _readString(
          data,
          ['phone', 'phoneNumber', 'mobile'],
          fallback: user.phoneNumber ?? 'Add phone number',
        );

        final photoUrl = _readString(
          data,
          ['photoUrl', 'photoURL', 'imageUrl'],
          fallback: user.photoURL ?? '',
        );

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
                      _ProfileHeroCard(
                        name: name,
                        email: email,
                        phone: phone,
                        photoUrl: photoUrl,
                        uid: user.uid,
                      ),
                      const SizedBox(height: 18),
                      _SectionTitle(title: 'Account'),
                      const SizedBox(height: 10),
                      _PremiumTile(
                        icon: Icons.location_on_rounded,
                        title: 'Saved Addresses',
                        subtitle: 'Manage home, office and other delivery addresses',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerAddressesPage(),
                            ),
                          );
                        },
                      ),
                      _PremiumTile(
                        icon: Icons.compare_arrows_rounded,
                        title: 'Address Change Request',
                        subtitle: 'Request approval for active delivery address changes',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressChangeRequestPage(),
                            ),
                          );
                        },
                      ),
                      _PremiumTile(
                        icon: Icons.receipt_long_rounded,
                        title: 'My Subscriptions',
                        subtitle: 'View active and pending tiffin plans',
                        onTap: () => _comingSoon(context),
                      ),
                      _PremiumTile(
                        icon: Icons.payments_rounded,
                        title: 'Payment Preference',
                        subtitle: 'Cash, UPI and delivery payment status',
                        onTap: () => _comingSoon(context),
                      ),
                      const SizedBox(height: 18),
                      _SectionTitle(title: 'Support'),
                      const SizedBox(height: 10),
                      _PremiumTile(
                        icon: Icons.support_agent_rounded,
                        title: 'Help & Support',
                        subtitle: 'Get help with orders and subscriptions',
                        onTap: () => _comingSoon(context),
                      ),
                      _PremiumTile(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Privacy Policy',
                        subtitle: 'Read how your data is used and protected',
                        onTap: () => _comingSoon(context),
                      ),
                      _PremiumTile(
                        icon: Icons.info_rounded,
                        title: 'About TiffinHub',
                        subtitle: 'App information and service details',
                        onTap: () => _comingSoon(context),
                      ),
                      const SizedBox(height: 20),
                      _ActionButtons(
                        onSwitchAccount: () => _switchAccount(context),
                        onLogout: () => _logout(context),
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

  static String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }

  static void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This section will be available soon.'),
        behavior: SnackBarBehavior.floating,
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
              'My Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomerProfilePage._text,
                fontSize: 20,
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

class _ProfileHeroCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String uid;

  const _ProfileHeroCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final plan = _PlanSummary.fromDocs(docs);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF5A00),
                Color(0xFFFFA726),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6A00).withOpacity(0.24),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _Avatar(photoUrl: photoUrl),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.90),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _VerifiedBadge(),
                      ],
                    ),
                  ),
                  if (plan.state == _PlanState.active)
                    _SmallPillButton(
                      label: 'Renew',
                      icon: Icons.refresh_rounded,
                      onTap: () => _renewPlan(context, plan),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _PhoneStrip(phone: phone),
              const SizedBox(height: 14),
              _PlanStateCard(
                plan: plan,
                onFindPlan: () => Navigator.pop(context),
                onRenew: () => _renewPlan(context, plan),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _renewPlan(BuildContext context, _PlanSummary plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          plan.state == _PlanState.active
              ? 'Renew plan flow will be available soon.'
              : 'Please select a plan first.',
        ),
        behavior: SnackBarBehavior.floating,
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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: Colors.white, size: 14),
          SizedBox(width: 5),
          Text(
            'Verified Customer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneStrip extends StatelessWidget {
  final String phone;

  const _PhoneStrip({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.call_rounded, color: Colors.white, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              phone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Icon(Icons.edit_square, color: Colors.white.withOpacity(0.78), size: 18),
        ],
      ),
    );
  }
}

class _SmallPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SmallPillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PlanState { active, pending, none }

class _PlanSummary {
  final _PlanState state;
  final String planName;
  final String restaurantName;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? requestedAt;
  final int totalDays;
  final int usedDays;
  final int leftDays;

  const _PlanSummary({
    required this.state,
    required this.planName,
    required this.restaurantName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.requestedAt,
    required this.totalDays,
    required this.usedDays,
    required this.leftDays,
  });

  factory _PlanSummary.none() {
    return const _PlanSummary(
      state: _PlanState.none,
      planName: '',
      restaurantName: '',
      status: '',
      startDate: null,
      endDate: null,
      requestedAt: null,
      totalDays: 0,
      usedDays: 0,
      leftDays: 0,
    );
  }

  factory _PlanSummary.fromDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) return _PlanSummary.none();

    final sorted = [...docs]..sort((a, b) {
        final ad = _readDate(a.data()['createdAt']) ?? _readDate(a.data()['startDate']) ?? DateTime(2000);
        final bd = _readDate(b.data()['createdAt']) ?? _readDate(b.data()['startDate']) ?? DateTime(2000);
        return bd.compareTo(ad);
      });

    QueryDocumentSnapshot<Map<String, dynamic>>? activeDoc;
    QueryDocumentSnapshot<Map<String, dynamic>>? pendingDoc;

    for (final doc in sorted) {
      final status = _readStatus(doc.data());
      if (_isActiveStatus(status)) {
        activeDoc ??= doc;
      } else if (_isPendingStatus(status)) {
        pendingDoc ??= doc;
      }
    }

    if (activeDoc != null) {
      return _PlanSummary._fromActive(activeDoc.data());
    }

    if (pendingDoc != null) {
      return _PlanSummary._fromPending(pendingDoc.data());
    }

    return _PlanSummary.none();
  }

  factory _PlanSummary._fromActive(Map<String, dynamic> data) {
    final planName = _readText(data, ['planName', 'plan', 'subscriptionPlan'], fallback: 'Active Plan');
    final totalDays = _readInt(data, ['totalDays', 'durationDays'], fallback: _daysFromPlan(planName));
    final startDate = _readDate(data['startDate']) ?? _readDate(data['createdAt']) ?? DateTime.now();
    final endDate = _readDate(data['endDate']) ?? startDate.add(Duration(days: totalDays));
    final today = DateTime.now();

    final used = today.difference(startDate).inDays.clamp(0, totalDays);
    final left = endDate.difference(today).inDays.clamp(0, totalDays);

    return _PlanSummary(
      state: _PlanState.active,
      planName: planName,
      restaurantName: _readText(data, ['restaurantName'], fallback: 'TiffinHub'),
      status: _readStatus(data),
      startDate: startDate,
      endDate: endDate,
      requestedAt: _readDate(data['createdAt']),
      totalDays: totalDays,
      usedDays: used,
      leftDays: left,
    );
  }

  factory _PlanSummary._fromPending(Map<String, dynamic> data) {
    return _PlanSummary(
      state: _PlanState.pending,
      planName: _readText(data, ['planName', 'plan', 'subscriptionPlan'], fallback: 'Tiffin Plan'),
      restaurantName: _readText(data, ['restaurantName'], fallback: 'Restaurant'),
      status: _readStatus(data),
      startDate: _readDate(data['startDate']),
      endDate: null,
      requestedAt: _readDate(data['createdAt']),
      totalDays: 0,
      usedDays: 0,
      leftDays: 0,
    );
  }

  double get progress {
    if (totalDays <= 0) return 0;
    return (usedDays / totalDays).clamp(0.0, 1.0);
  }

  static bool _isActiveStatus(String status) {
    final s = status.toLowerCase().trim();
    return s == 'active' || s == 'accepted' || s == 'approved' || s == 'running';
  }

  static bool _isPendingStatus(String status) {
    final s = status.toLowerCase().trim();
    return s == 'pending' || s == 'requested' || s == 'request_sent' || s == 'awaiting_response';
  }

  static String _readStatus(Map<String, dynamic> data) {
    return _readText(data, ['status', 'subscriptionStatus'], fallback: 'pending');
  }

  static String _readText(Map<String, dynamic> data, List<String> keys, {required String fallback}) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }

  static int _readInt(Map<String, dynamic> data, List<String> keys, {required int fallback}) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  static int _daysFromPlan(String planName) {
    final lower = planName.toLowerCase();
    if (lower.contains('monthly')) return 30;
    if (lower.contains('weekly')) return 7;
    if (lower.contains('trial')) return 1;
    return 30;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class _PlanStateCard extends StatelessWidget {
  final _PlanSummary plan;
  final VoidCallback onFindPlan;
  final VoidCallback onRenew;

  const _PlanStateCard({
    required this.plan,
    required this.onFindPlan,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    if (plan.state == _PlanState.active) {
      return _ActivePlanCard(plan: plan, onRenew: onRenew);
    }

    if (plan.state == _PlanState.pending) {
      return _PendingPlanCard(plan: plan);
    }

    return _NoActivePlanCard(onFindPlan: onFindPlan);
  }
}

class _ActivePlanCard extends StatelessWidget {
  final _PlanSummary plan;
  final VoidCallback onRenew;

  const _ActivePlanCard({
    required this.plan,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PlanInfoColumn(
                  title: 'Plan Status',
                  value: plan.planName,
                  chipText: 'Active',
                  chipColor: const Color(0xFF1BAA3A),
                ),
              ),
              Container(width: 1, height: 66, color: const Color(0xFFFFD5B5)),
              SizedBox(
                width: 86,
                child: _ProgressRing(
                  progress: plan.progress,
                  usedDays: plan.usedDays,
                  totalDays: plan.totalDays,
                ),
              ),
              Container(width: 1, height: 66, color: const Color(0xFFFFD5B5)),
              Expanded(
                child: _PlanDateColumn(
                  title: 'Plan Ends On',
                  date: _formatDate(plan.endDate),
                  subtitle: '${plan.leftDays} Days Left',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRenew,
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: const Text('Renew Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomerProfilePage._orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPlanCard extends StatelessWidget {
  final _PlanSummary plan;

  const _PendingPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8FF).withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7D8FF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.room_service_rounded, color: Color(0xFF7B35D8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.planName} Request',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerProfilePage._text,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.restaurantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE3FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Request Sent',
                  style: TextStyle(
                    color: Color(0xFF7B35D8),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBDFFF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Color(0xFF7B35D8), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Awaiting restaurant response',
                    style: TextStyle(
                      color: Color(0xFF7B35D8),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  _formatDate(plan.requestedAt),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We will notify you once the restaurant responds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7B35D8),
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoActivePlanCard extends StatelessWidget {
  final VoidCallback onFindPlan;

  const _NoActivePlanCard({required this.onFindPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFE4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.event_busy_rounded, color: CustomerProfilePage._orange),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active Plan',
                  style: TextStyle(
                    color: CustomerProfilePage._text,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You do not have any active plan right now.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF7B6250),
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onFindPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomerProfilePage._orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              child: const Text('Find Plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanInfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final String chipText;
  final Color chipColor;

  const _PlanInfoColumn({
    required this.title,
    required this.value,
    required this.chipText,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.48),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CustomerProfilePage._orange,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: chipColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              chipText,
              style: TextStyle(
                color: chipColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDateColumn extends StatelessWidget {
  final String title;
  final String date;
  final String subtitle;

  const _PlanDateColumn({
    required this.title,
    required this.date,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.48),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 15, color: CustomerProfilePage._text),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomerProfilePage._text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(
              color: CustomerProfilePage._orange,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int usedDays;
  final int totalDays;

  const _ProgressRing({
    required this.progress,
    required this.usedDays,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      width: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 64,
            width: 64,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 7,
              backgroundColor: const Color(0xFFFFE5D0),
              valueColor: const AlwaysStoppedAnimation(CustomerProfilePage._orange),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                usedDays.toString(),
                style: const TextStyle(
                  color: CustomerProfilePage._text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Text(
                'of $totalDays',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.55),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _Avatar extends StatelessWidget {
  final String photoUrl;

  const _Avatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 34,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 31,
          backgroundImage: NetworkImage(photoUrl),
        ),
      );
    }

    return const CircleAvatar(
      radius: 34,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person_rounded,
        color: CustomerProfilePage._orange,
        size: 34,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: CustomerProfilePage._text,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PremiumTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PremiumTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0C6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: CustomerProfilePage._softOrange,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: CustomerProfilePage._orange, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: CustomerProfilePage._text,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withOpacity(0.48),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF9C7B66),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;

  const _ActionButtons({
    required this.onSwitchAccount,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onSwitchAccount,
            icon: const Icon(Icons.switch_account_rounded, size: 19),
            label: const Text('Switch Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CustomerProfilePage._orange,
              side: const BorderSide(color: Color(0xFFFFC79B)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 19),
            label: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF3B30),
              backgroundColor: const Color(0xFFFFEFED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
