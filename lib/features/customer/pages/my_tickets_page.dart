import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ticket_details_page.dart';

class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({super.key});

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _text = Color(0xFF241A14);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _text,
        title: const Text('My Tickets', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: user == null
          ? const Center(child: Text('Please login first.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('support_tickets')
                  .where('customerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _orange));
                }

                final docs = [...(snapshot.data?.docs ?? [])];
                docs.sort((a, b) {
                  final aTime = a.data()['createdAt'];
                  final bTime = b.data()['createdAt'];
                  final aDate = aTime is Timestamp ? aTime.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                  final bDate = bTime is Timestamp ? bTime.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                  return bDate.compareTo(aDate);
                });

                if (docs.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final createdAt = data['createdAt'];
                    final createdDate = createdAt is Timestamp ? _formatDate(createdAt.toDate()) : 'Just now';

                    return _TicketCard(
                      subject: _read(data['subject'], 'Support Ticket'),
                      issueType: _read(data['issueType'], 'General'),
                      status: _read(data['status'], 'Open'),
                      priority: _read(data['priority'], 'Normal'),
                      createdAt: createdDate,
                      hasReply: _read(data['adminReply'], '').isNotEmpty,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TicketDetailsPage(ticketId: doc.id)),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  static String _read(dynamic value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _TicketCard extends StatelessWidget {
  final String subject;
  final String issueType;
  final String status;
  final String priority;
  final String createdAt;
  final bool hasReply;
  final VoidCallback onTap;

  const _TicketCard({
    required this.subject,
    required this.issueType,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.hasReply,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE0C6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MyTicketsPage._text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                issueType,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.58),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  _MetaChip(icon: Icons.flag_rounded, label: priority),
                  const SizedBox(width: 8),
                  _MetaChip(icon: Icons.calendar_month_rounded, label: createdAt),
                  if (hasReply) ...[
                    const SizedBox(width: 8),
                    const _MetaChip(icon: Icons.mark_email_unread_rounded, label: 'Reply'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF19A35B);
      case 'closed':
        return const Color(0xFF6D6D6D);
      case 'in progress':
        return const Color(0xFF1565C0);
      default:
        return MyTicketsPage._orange;
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0E4),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: MyTicketsPage._orange, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.confirmation_number_outlined, color: MyTicketsPage._orange, size: 38),
            ),
            const SizedBox(height: 16),
            const Text(
              'No support tickets yet',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: MyTicketsPage._text),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a ticket whenever you need help with your tiffin service.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
