import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TicketDetailsPage extends StatelessWidget {
  final String ticketId;

  const TicketDetailsPage({super.key, required this.ticketId});

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _text = Color(0xFF241A14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _text,
        title: const Text('Ticket Details', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('support_tickets').doc(ticketId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _orange));
          }

          final data = snapshot.data?.data();
          if (data == null) {
            return const Center(child: Text('Ticket not found.'));
          }

          final createdAt = data['createdAt'];
          final updatedAt = data['updatedAt'];

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            children: [
              _HeaderCard(
                subject: _read(data['subject'], 'Support Ticket'),
                status: _read(data['status'], 'Open'),
                priority: _read(data['priority'], 'Normal'),
                issueType: _read(data['issueType'], 'General'),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Issue Description',
                icon: Icons.description_rounded,
                child: Text(
                  _read(data['description'], 'No description available.'),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.66),
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Admin Reply',
                icon: Icons.admin_panel_settings_rounded,
                child: Text(
                  _read(data['adminReply'], 'No reply yet. Support team will update this ticket soon.'),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.66),
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Ticket Timeline',
                icon: Icons.history_rounded,
                child: Column(
                  children: [
                    _TimelineRow(title: 'Created', value: createdAt is Timestamp ? _formatDateTime(createdAt.toDate()) : 'Just now'),
                    const SizedBox(height: 10),
                    _TimelineRow(title: 'Last Updated', value: updatedAt is Timestamp ? _formatDateTime(updatedAt.toDate()) : 'Just now'),
                    const SizedBox(height: 10),
                    _TimelineRow(title: 'Ticket ID', value: ticketId),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _read(dynamic value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  static String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year}, $hour:$minute';
  }
}

class _HeaderCard extends StatelessWidget {
  final String subject;
  final String status;
  final String priority;
  final String issueType;

  const _HeaderCard({
    required this.subject,
    required this.status,
    required this.priority,
    required this.issueType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A1A), Color(0xFFFFA24A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TicketDetailsPage._orange.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            issueType,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _WhiteChip(label: status, icon: Icons.info_rounded),
              const SizedBox(width: 8),
              _WhiteChip(label: priority, icon: Icons.flag_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhiteChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _WhiteChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: TicketDetailsPage._orange, size: 20),
              const SizedBox(width: 9),
              Text(title, style: const TextStyle(color: TicketDetailsPage._text, fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String title;
  final String value;

  const _TimelineRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: TextStyle(color: Colors.black.withOpacity(0.52), fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: TicketDetailsPage._text, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
