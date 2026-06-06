import 'package:flutter/material.dart';

import 'create_ticket_page.dart';
import 'my_tickets_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _softOrange = Color(0xFFFFF0E4);
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
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
          children: [
            _HeroCard(),
            const SizedBox(height: 18),
            _SupportTile(
              icon: Icons.add_comment_rounded,
              title: 'Create New Ticket',
              subtitle: 'Report subscription, payment, delivery or app issues',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTicketPage()),
                );
              },
            ),
            _SupportTile(
              icon: Icons.confirmation_number_rounded,
              title: 'My Tickets',
              subtitle: 'Track ticket status and admin replies',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyTicketsPage()),
                );
              },
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Common Help Topics'),
            const SizedBox(height: 10),
            const _FaqCard(
              question: 'When should I create a support ticket?',
              answer:
                  'Create a ticket when you need help with subscription requests, payments, delivery, address changes, restaurant complaints or technical issues.',
            ),
            const _FaqCard(
              question: 'How will I receive a reply?',
              answer:
                  'Your ticket reply and latest status will be visible inside My Tickets. Admin support can mark tickets as open, in progress, resolved or closed.',
            ),
            const _FaqCard(
              question: 'Can I submit payment related issues?',
              answer:
                  'Yes. Add the payment reference number and a clear description so support can verify the issue faster.',
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Contact Information'),
            const SizedBox(height: 10),
            const _ContactCard(),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
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
            color: HelpSupportPage._orange.withOpacity(0.22),
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
            child: Icon(Icons.support_agent_rounded, color: HelpSupportPage._orange, size: 30),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We are here to help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Raise a ticket and track every support update in one place.',
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: HelpSupportPage._text,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportTile({
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
            color: HelpSupportPage._softOrange,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: HelpSupportPage._orange, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: HelpSupportPage._text,
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
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9C7B66)),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqCard({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE0C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: HelpSupportPage._text,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              color: Colors.black.withOpacity(0.58),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0C6)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContactRow(icon: Icons.mail_rounded, title: 'Email', value: 'support@tiffinhub.in'),
          SizedBox(height: 12),
          _ContactRow(icon: Icons.schedule_rounded, title: 'Support Hours', value: '10:00 AM - 7:00 PM'),
          SizedBox(height: 12),
          _ContactRow(icon: Icons.verified_user_rounded, title: 'Priority', value: 'Active subscription issues are handled first'),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: HelpSupportPage._orange, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.58),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
