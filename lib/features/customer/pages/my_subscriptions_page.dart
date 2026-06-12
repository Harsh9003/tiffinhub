
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySubscriptionsPage extends StatelessWidget {
  const MySubscriptionsPage({super.key});

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF7B6250);
  static const Color _border = Color(0xFFFFE1C8);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Please login first.')),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Subscriptions',
          style: TextStyle(color: _text, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('subscription_requests')
            .where('customerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _orange),
            );
          }

          final docs = [...(snapshot.data?.docs ?? [])]
              .where((d) => !_isCancelled(_status(d.data())))
              .toList();

          docs.sort((a, b) {
            final ad = _readDate(a.data()['createdAt']) ?? DateTime(2000);
            final bd = _readDate(b.data()['createdAt']) ?? DateTime(2000);
            return bd.compareTo(ad);
          });

          if (docs.isEmpty) {
            return const _EmptyState(
              title: 'No subscription requests yet',
              subtitle: 'Your active, payment pending and request pending tiffin plans will appear here.',
            );
          }

          final active = docs.where((d) => _isActive(d.data())).toList();
          final pending = docs.where((d) => _isPending(d.data())).toList();
          final history = docs.where((d) {
            final data = d.data();
            return !_isActive(data) && !_isPending(data);
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              _SummaryStrip(
                activeCount: active.length,
                pendingCount: pending.length,
                totalCount: docs.length,
              ),
              const SizedBox(height: 18),
              if (active.isNotEmpty) ...[
                const _SectionTitle('Active Plans'),
                ...active.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SubscriptionRequestCard(
                      docId: d.id,
                      data: d.data(),
                    ),
                  ),
                ),
              ],
              if (pending.isNotEmpty) ...[
                const _SectionTitle('Pending Requests'),
                ...pending.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SubscriptionRequestCard(
                      docId: d.id,
                      data: d.data(),
                    ),
                  ),
                ),
              ],
              if (history.isNotEmpty) ...[
                const _SectionTitle('History'),
                ...history.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SubscriptionRequestCard(
                      docId: d.id,
                      data: d.data(),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  static String _status(Map<String, dynamic> data) {
    return (data['status'] ?? data['subscriptionStatus'] ?? data['requestStatus'] ?? 'request_pending')
        .toString()
        .toLowerCase()
        .trim();
  }

  static bool _isCancelled(String status) {
    return status == 'cancelled_by_customer' || status == 'cancelled';
  }

  static bool _isActive(Map<String, dynamic> data) {
    final status = _status(data);
    final paymentMode = _readStaticText(
      data,
      ['paymentMode', 'selectedPaymentMode'],
    ).toLowerCase();

    final cashStatus = _readStaticText(
      data,
      ['cashCollectionStatus', 'cashStatus'],
    ).toLowerCase();

    final isCash = paymentMode.contains('cash') || paymentMode.contains('cod');

    // Cash/COD plan should not be treated as fully active until cash is collected/OTP verified.
    if (isCash && (cashStatus.isEmpty || cashStatus == 'pending' || cashStatus == 'cash_collection_pending')) {
      return false;
    }

    return status == 'payment_verified_plan_active' ||
        status == 'plan_active' ||
        status == 'active';
  }

  static bool _isPending(Map<String, dynamic> data) {
    if (_isActive(data)) return false;

    final status = _status(data);

    return status == 'request_pending' ||
        status == 'pending' ||
        status == 'waiting_for_restaurant' ||
        status == 'restaurant_approved_payment_pending' ||
        status == 'customer_payment_submitted' ||
        status == 'restaurant_payment_verification_required' ||
        status == 'payment_mismatch_manual_review' ||
        status == 'cash_collection_pending' ||
        status == 'payment_verified_plan_active';
  }

  static String _readStaticText(Map<String, dynamic> data, List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class _SubscriptionRequestCard extends StatelessWidget {
  const _SubscriptionRequestCard({
    required this.docId,
    required this.data,
  });

  final String docId;
  final Map<String, dynamic> data;

  static const Color _orange = MySubscriptionsPage._orange;
  static const Color _text = MySubscriptionsPage._text;
  static const Color _muted = MySubscriptionsPage._muted;
  static const Color _border = MySubscriptionsPage._border;

  @override
  Widget build(BuildContext context) {
    final restaurantName = _readText(['restaurantName'], fallback: 'Restaurant');
    final ownerName = _readText(['ownerName'], fallback: '');
    final planName = _readText(['planName', 'plan', 'subscriptionPlan'], fallback: 'Tiffin Plan');
    final mealType = _readText(['mealType'], fallback: 'Meal Plan');
    final rawStatus = _readText(['status', 'subscriptionStatus', 'requestStatus'], fallback: 'request_pending');
    final status = rawStatus.toLowerCase().trim();

    final paymentMode = _readText(
      ['paymentMode', 'selectedPaymentMode'],
      fallback: 'After approval',
    );

    final total = _readAmount(
      data['totalPayableAfterApproval'] ??
          data['totalAmount'] ??
          data['amount'] ??
          data['planPrice'],
    );

    final createdAt = _readDate(data['createdAt']);
    final startDate = _readDate(data['startDate']);
    final statusInfo = _statusInfo(status, paymentMode);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E4),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.restaurant_rounded, color: _orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (ownerName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Owner: $ownerName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusBadge(label: statusInfo.label, color: statusInfo.color),
            ],
          ),
          const SizedBox(height: 16),
          _DetailLine(icon: Icons.room_service_rounded, title: 'Plan', value: planName),
          _DetailLine(icon: Icons.restaurant_menu_rounded, title: 'Meal Type', value: mealType),
          if (total.isNotEmpty) _DetailLine(icon: Icons.currency_rupee_rounded, title: 'Amount', value: total),
          _DetailLine(icon: Icons.payments_rounded, title: 'Payment', value: paymentMode),
          if (createdAt != null) _DetailLine(icon: Icons.calendar_month_rounded, title: 'Requested', value: _formatDate(createdAt)),
          if (startDate != null) _DetailLine(icon: Icons.play_circle_fill_rounded, title: 'Start', value: _formatDate(startDate)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              statusInfo.message,
              style: TextStyle(
                color: statusInfo.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Timeline(status: status, paymentMode: paymentMode),
          if (_canCancel(status)) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFFB4A2)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text(
                  'Cancel Request',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canCancel(String status) {
    return status == 'request_pending' ||
        status == 'pending' ||
        status == 'waiting_for_restaurant' ||
        status == 'restaurant_approved_payment_pending';
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Request'),
          content: const Text(
            'Are you sure you want to cancel this subscription request?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('subscription_requests')
        .doc(docId)
        .update({
      'status': 'cancelled_by_customer',
      'paymentStatus': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledReason': 'Cancelled by customer before restaurant/payment completion',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request cancelled successfully.')),
    );
  }

  String _readText(List<String> keys, {required String fallback}) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }

  String _readAmount(dynamic value) {
    if (value is num && value > 0) {
      return '₹${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';
    }
    if (value is String && value.trim().isNotEmpty) {
      final clean = value.trim();
      return clean.startsWith('₹') ? clean : '₹$clean';
    }
    return '';
  }

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  _StatusInfo _statusInfo(String status, String paymentMode) {
    final normalizedPayment = paymentMode.toLowerCase();

    if (status == 'payment_verified_plan_active' &&
        (normalizedPayment.contains('cash') || normalizedPayment.contains('cod'))) {
      final cashStatus = _readText(
        ['cashCollectionStatus', 'cashStatus'],
        fallback: 'pending',
      ).toLowerCase();

      if (cashStatus == 'pending' || cashStatus == 'cash_collection_pending') {
        return const _StatusInfo(
          label: 'Cash Pending',
          message:
              'Your request is approved for cash payment. The plan will become active after first delivery cash collection is verified by OTP.',
          color: Color(0xFFF97316),
        );
      }
    }

    if (status == 'payment_verified_plan_active' || status == 'plan_active' || status == 'active') {
      return const _StatusInfo(
        label: 'Active',
        message: 'Your tiffin plan is active. Delivery and meal updates will appear here.',
        color: Color(0xFF16A34A),
      );
    }

    if (status == 'restaurant_approved_payment_pending') {
      return const _StatusInfo(
        label: 'Payment Pending',
        message:
            'Restaurant approved your request. Complete online payment or choose cash payment before the plan can start.',
        color: Color(0xFF2563EB),
      );
    }

    if (status == 'customer_payment_submitted' ||
        status == 'restaurant_payment_verification_required') {
      return const _StatusInfo(
        label: 'Verification Pending',
        message: 'Your payment proof has been submitted. Restaurant verification is pending.',
        color: Color(0xFF7C3AED),
      );
    }

    if (status == 'payment_mismatch_manual_review') {
      return const _StatusInfo(
        label: 'Manual Review',
        message: 'Payment details did not match automatically. Admin review is required.',
        color: Color(0xFFB45309),
      );
    }

    if (status == 'rejected_by_restaurant' ||
        status == 'rejected' ||
        status == 'payment_rejected') {
      return const _StatusInfo(
        label: 'Rejected',
        message: 'This request was rejected. Check the reason or contact support.',
        color: Color(0xFFDC2626),
      );
    }

    return const _StatusInfo(
      label: 'Request Sent',
      message: 'Awaiting restaurant response. You can cancel this request before restaurant approval.',
      color: Color(0xFF7B35D8),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.activeCount,
    required this.pendingCount,
    required this.totalCount,
  });

  final int activeCount;
  final int pendingCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return Row(
          children: [
            Expanded(
              child: _SummaryBox(
                icon: Icons.verified_rounded,
                label: 'Active',
                value: activeCount,
                compact: compact,
              ),
            ),
            SizedBox(width: compact ? 8 : 10),
            Expanded(
              child: _SummaryBox(
                icon: Icons.schedule_rounded,
                label: 'Pending',
                value: pendingCount,
                compact: compact,
              ),
            ),
            SizedBox(width: compact ? 8 : 10),
            Expanded(
              child: _SummaryBox(
                icon: Icons.receipt_long_rounded,
                label: 'Total',
                value: totalCount,
                compact: compact,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final int value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: compact ? 82 : 88,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MySubscriptionsPage._border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: MySubscriptionsPage._orange, size: compact ? 16 : 18),
            SizedBox(height: compact ? 4 : 6),
            Text(
              '$value',
              style: TextStyle(
                color: MySubscriptionsPage._text,
                fontSize: compact ? 16 : 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: MySubscriptionsPage._muted,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: MySubscriptionsPage._text,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: MySubscriptionsPage._orange, size: 16),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 74,
            child: Text(
              title,
              style: const TextStyle(
                color: MySubscriptionsPage._muted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: MySubscriptionsPage._text,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.status,
    required this.paymentMode,
  });

  final String status;
  final String paymentMode;

  @override
  Widget build(BuildContext context) {
    final isCash = paymentMode.toLowerCase().contains('cash') ||
        paymentMode.toLowerCase().contains('cod');

    final requestDone = true;
    final restaurantReviewed = status != 'request_pending' &&
        status != 'pending' &&
        status != 'waiting_for_restaurant';
    final paymentDone = status == 'customer_payment_submitted' ||
        status == 'restaurant_payment_verification_required' ||
        status == 'payment_verified_plan_active' ||
        status == 'plan_active' ||
        status == 'active';
    final planActive = (status == 'payment_verified_plan_active' ||
            status == 'plan_active' ||
            status == 'active') &&
        !isCash;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Request Timeline',
          style: TextStyle(
            color: MySubscriptionsPage._text,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        _TimelineItem(done: requestDone, text: 'Request Submitted'),
        _TimelineItem(done: restaurantReviewed, text: 'Restaurant Review'),
        _TimelineItem(
          done: paymentDone,
          text: isCash ? 'Cash Payment Selected' : 'Payment Verification',
        ),
        _TimelineItem(
          done: planActive,
          text: isCash ? 'Cash OTP Verified / Plan Active' : 'Plan Active',
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.done,
    required this.text,
  });

  final bool done;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = done ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB);

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: done ? MySubscriptionsPage._text : MySubscriptionsPage._muted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  final String label;
  final String message;
  final Color color;

  const _StatusInfo({
    required this.label,
    required this.message,
    required this.color,
  });
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              color: MySubscriptionsPage._orange,
              size: 54,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: MySubscriptionsPage._text,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MySubscriptionsPage._muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
