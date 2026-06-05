import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'restaurant_auth_wrapper.dart';
import 'restaurant_dashboard_page.dart';
import 'restaurant_registration_page.dart';

class RestaurantRegistrationStatusPage extends StatelessWidget {
  final String? restaurantId;

  const RestaurantRegistrationStatusPage({
    super.key,
    this.restaurantId,
  });

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF7B6250);
  static const Color _success = Color(0xFF16A34A);
  static const Color _danger = Color(0xFFEF4444);

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _watchRestaurant() {
    if (restaurantId == null || restaurantId!.trim().isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final stream = _watchRestaurant();

    if (stream == null) {
      return const RestaurantAuthWrapper();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final status = (data['registrationStatus'] ?? 'pending_review').toString();
        final isApproved = data['isApproved'] == true;
        final isActive = data['isActive'] == true;

        final statusData = _statusData(status, isApproved, isActive);

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: 'Registration Status',
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    children: [
                      _StatusHero(statusData: statusData),
                      const SizedBox(height: 14),
                      _InfoCard(
                        title: 'Restaurant Profile',
                        children: [
                          _DetailRow(label: 'Restaurant Name', value: _read(data, 'restaurantName', fallback: 'Not available')),
                          _DetailRow(label: 'Owner Name', value: _read(data, 'ownerName', fallback: 'Not available')),
                          _DetailRow(label: 'City', value: _read(data, 'city', fallback: 'Not available')),
                          _DetailRow(label: 'Service Area', value: _read(data, 'serviceArea', fallback: 'Not available')),
                          _DetailRow(label: 'Phone', value: _read(data, 'phone', fallback: 'Not available')),
                          _DetailRow(label: 'Business Email', value: _read(data, 'ownerEmail', fallback: 'Not available')),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ReviewTimeline(status: status, isApproved: isApproved),
                      const SizedBox(height: 14),
                      _GuidanceCard(
                        status: status,
                        rejectionReason: _read(data, 'rejectionReason'),
                      ),
                      const SizedBox(height: 18),
                      if (status == 'approved' && isApproved && isActive)
                        _PrimaryButton(
                          text: 'Open Restaurant Dashboard',
                          icon: Icons.dashboard_rounded,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RestaurantDashboardPage()),
                            );
                          },
                        )
                      else if (status == 'rejected')
                        _PrimaryButton(
                          text: 'Update Registration Details',
                          icon: Icons.edit_rounded,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RestaurantRegistrationPage()),
                            );
                          },
                        )
                      else
                        _PrimaryButton(
                          text: 'Refresh Status',
                          icon: Icons.refresh_rounded,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RestaurantAuthWrapper()),
                            );
                          },
                        ),
                      const SizedBox(height: 10),
                      _SecondaryButton(
                        text: 'Contact Support',
                        icon: Icons.support_agent_rounded,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Support contact will be available soon.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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

  static String _read(Map<String, dynamic> data, String key, {String fallback = ''}) {
    final value = data[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static _StatusViewData _statusData(String status, bool isApproved, bool isActive) {
    if (status == 'approved' && isApproved && isActive) {
      return const _StatusViewData(
        title: 'Restaurant Approved',
        subtitle: 'Your restaurant profile is active. You can now receive subscription requests and manage your dashboard.',
        label: 'Approved',
        color: _success,
        icon: Icons.verified_rounded,
      );
    }

    if (status == 'rejected') {
      return const _StatusViewData(
        title: 'Registration Requires Updates',
        subtitle: 'Your registration was reviewed by admin and requires changes before approval.',
        label: 'Action Required',
        color: _danger,
        icon: Icons.error_rounded,
      );
    }

    return const _StatusViewData(
      title: 'Pending Admin Review',
      subtitle: 'Your restaurant details have been submitted successfully and are currently under admin verification.',
      label: 'Pending Review',
      color: _orange,
      icon: Icons.schedule_rounded,
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.onBack,
  });

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
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: RestaurantRegistrationStatusPage._text,
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

class _StatusHero extends StatelessWidget {
  final _StatusViewData statusData;

  const _StatusHero({required this.statusData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusData.color,
            statusData.color.withOpacity(0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: statusData.color.withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(statusData.icon, color: statusData.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusData.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  statusData.subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
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

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: RestaurantRegistrationStatusPage._text,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 122,
            child: Text(
              label,
              style: const TextStyle(
                color: RestaurantRegistrationStatusPage._muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: RestaurantRegistrationStatusPage._text,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTimeline extends StatelessWidget {
  final String status;
  final bool isApproved;

  const _ReviewTimeline({
    required this.status,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    final rejected = status == 'rejected';
    final approved = status == 'approved' && isApproved;

    return _InfoCard(
      title: 'Approval Timeline',
      children: [
        _TimelineItem(
          title: 'Registration Submitted',
          subtitle: 'Your restaurant profile has been received.',
          completed: true,
        ),
        _TimelineItem(
          title: 'Document & Profile Review',
          subtitle: 'Admin verifies business details, pricing, timings, and contact information.',
          completed: approved,
          active: !approved && !rejected,
        ),
        _TimelineItem(
          title: 'Service Area Verification',
          subtitle: 'Delivery coverage and service modes are reviewed before approval.',
          completed: approved,
          active: false,
        ),
        _TimelineItem(
          title: rejected ? 'Updates Required' : 'Final Approval',
          subtitle: rejected
              ? 'Please update the requested details and submit again.'
              : 'Once approved, your restaurant dashboard will become active.',
          completed: approved,
          active: rejected,
          danger: rejected,
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool completed;
  final bool active;
  final bool danger;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    this.completed = false,
    this.active = false,
    this.danger = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? RestaurantRegistrationStatusPage._danger
        : completed
            ? RestaurantRegistrationStatusPage._success
            : active
                ? RestaurantRegistrationStatusPage._orange
                : const Color(0xFFD4C7BC);

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: color.withOpacity(0.14),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : danger
                          ? Icons.error_rounded
                          : Icons.schedule_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: color.withOpacity(0.22),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: RestaurantRegistrationStatusPage._text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: RestaurantRegistrationStatusPage._muted,
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  final String status;
  final String rejectionReason;

  const _GuidanceCard({
    required this.status,
    required this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final rejected = status == 'rejected';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rejected ? const Color(0xFFFFEEEE) : const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: rejected ? const Color(0xFFFFC4C4) : const Color(0xFFFFD7B8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            rejected ? Icons.info_rounded : Icons.admin_panel_settings_rounded,
            color: rejected
                ? RestaurantRegistrationStatusPage._danger
                : RestaurantRegistrationStatusPage._orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rejected && rejectionReason.isNotEmpty
                  ? 'Admin response: $rejectionReason'
                  : 'The verification process usually takes 24–48 hours, depending on profile completeness and service area validation. You can receive subscription requests and manage deliveries only after admin approval.',
              style: TextStyle(
                color: rejected ? RestaurantRegistrationStatusPage._danger : RestaurantRegistrationStatusPage._muted,
                fontSize: 12.2,
                height: 1.42,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: RestaurantRegistrationStatusPage._orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: RestaurantRegistrationStatusPage._orange,
          side: const BorderSide(color: Color(0xFFFFC9A5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xFFFFD7B8)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.035),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class _StatusViewData {
  final String title;
  final String subtitle;
  final String label;
  final Color color;
  final IconData icon;

  const _StatusViewData({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.color,
    required this.icon,
  });
}
