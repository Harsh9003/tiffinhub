import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _text = Color(0xFF241A14);

  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _issueType = 'Subscription Issue';
  String _priority = 'Normal';
  bool _isSubmitting = false;

  final List<String> _issueTypes = const [
    'Subscription Issue',
    'Payment Issue',
    'Delivery Issue',
    'Address Issue',
    'Restaurant Complaint',
    'Technical Problem',
    'Other',
  ];

  final List<String> _priorities = const ['Low', 'Normal', 'High'];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Please login again to create a ticket.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final ticketRef = FirebaseFirestore.instance.collection('support_tickets').doc();
      final now = FieldValue.serverTimestamp();

      await ticketRef.set({
        'ticketId': ticketRef.id,
        'customerId': user.uid,
        'customerName': user.displayName ?? 'Customer',
        'customerEmail': user.email ?? '',
        'customerPhone': user.phoneNumber ?? '',
        'issueType': _issueType,
        'subject': _subjectController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'Open',
        'priority': _priority,
        'adminReply': '',
        'adminReplyAt': null,
        'createdAt': now,
        'updatedAt': now,
      });

      if (!mounted) return;
      _showMessage('Support ticket created successfully.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to create ticket. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _text,
        title: const Text('Create Ticket', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFFE0C6)),
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _issueType,
                      decoration: _inputDecoration('Issue Type', Icons.category_rounded),
                      items: _issueTypes.map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _issueType = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: _inputDecoration('Priority', Icons.priority_high_rounded),
                      items: _priorities.map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _priority = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _subjectController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Subject', Icons.subject_rounded),
                      validator: (value) {
                        if (value == null || value.trim().length < 5) {
                          return 'Please enter a clear subject.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: _inputDecoration('Describe your issue', Icons.description_rounded),
                      validator: (value) {
                        if (value == null || value.trim().length < 15) {
                          return 'Please describe the issue in at least 15 characters.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitTicket,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _orange),
      filled: true,
      fillColor: const Color(0xFFFFFBF7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFFE0C6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFFE0C6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _orange, width: 1.4),
      ),
    );
  }
}
