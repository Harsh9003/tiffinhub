
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerPaymentPage extends StatefulWidget {
  const CustomerPaymentPage({
    super.key,
    required this.requestId,
    required this.requestData,
  });

  final String requestId;
  final Map<String, dynamic> requestData;

  @override
  State<CustomerPaymentPage> createState() => _CustomerPaymentPageState();
}

class _CustomerPaymentPageState extends State<CustomerPaymentPage> {
  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF7B6250);

  final TextEditingController _txnController = TextEditingController();
  bool _saving = false;
  String _mode = 'online_upi';

  DocumentReference<Map<String, dynamic>> get _requestRef =>
      FirebaseFirestore.instance.collection('subscription_requests').doc(widget.requestId);

  @override
  void dispose() {
    _txnController.dispose();
    super.dispose();
  }

  String _read(List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = widget.requestData[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  int _amount() {
    for (final key in ['totalAmount', 'amount', 'price', 'planPrice']) {
      final value = widget.requestData[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  Future<void> _submitCash() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await _requestRef.update({
        'paymentMode': 'cash_on_delivery',
        'paymentStatus': 'cash_to_be_collected',
        'status': 'payment_verified_plan_active',
        'requestStatus': 'payment_verified_plan_active',
        'planActive': true,
        'activatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash on delivery selected. Your plan is active.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to select cash payment: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitOnline() async {
    final txn = _txnController.text.trim();

    if (txn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter UPI transaction ID / reference number.')),
      );
      return;
    }

    if (_saving) return;
    setState(() => _saving = true);

    try {
      await _requestRef.update({
        'paymentMode': 'online_upi',
        'paymentStatus': 'customer_payment_submitted',
        'status': 'customer_payment_submitted',
        'requestStatus': 'customer_payment_submitted',
        'customerTransactionId': txn,
        'customerPaymentSubmittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment proof submitted. Restaurant will verify it.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment submission failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  Future<void> _cancelRequest() async {
    if (_saving) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
          'Are you sure you want to cancel this subscription request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _saving = true);

    try {
      await _requestRef.update({
        'status': 'cancelled_by_customer',
        'requestStatus': 'cancelled_by_customer',
        'paymentStatus': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledReason': 'Cancelled by customer before payment',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to cancel request: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantName = _read(['restaurantName'], fallback: 'Restaurant');
    final planName = _read(['planName', 'planTitle'], fallback: 'Selected Plan');
    final mealType = _read(['mealType'], fallback: 'Meal');
    final amount = _amount();

    final upiId = _read(['restaurantUpiId', 'upiId', 'upiID'], fallback: 'UPI details will be shown if added by restaurant');
    final accountName = _read(['restaurantAccountName', 'accountHolderName', 'businessName'], fallback: restaurantName);

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
        title: const Text('Complete Payment', style: TextStyle(color: _text, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 48,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _cancelRequest,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancel Request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : _mode == 'cash_on_delivery'
                          ? _submitCash
                          : _submitOnline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _saving
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_mode == 'cash_on_delivery' ? 'Confirm Cash on Delivery' : 'Submit Payment Proof',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurantName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: _text)),
                const SizedBox(height: 8),
                _RowText(label: 'Plan', value: planName),
                _RowText(label: 'Meal Type', value: mealType),
                _RowText(label: 'Amount', value: amount <= 0 ? 'Not available' : '₹$amount'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Select Payment Mode', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _text)),
          const SizedBox(height: 10),
          _ModeTile(
            selected: _mode == 'online_upi',
            icon: Icons.account_balance_wallet_rounded,
            title: 'Online UPI Payment',
            subtitle: 'Pay directly to restaurant using UPI and submit transaction ID.',
            onTap: () => setState(() => _mode = 'online_upi'),
          ),
          const SizedBox(height: 10),
          _ModeTile(
            selected: _mode == 'cash_on_delivery',
            icon: Icons.payments_rounded,
            title: 'Cash on Delivery',
            subtitle: 'Cash will be collected during delivery as per restaurant policy.',
            onTap: () => setState(() => _mode = 'cash_on_delivery'),
          ),
          const SizedBox(height: 14),
          if (_mode == 'online_upi')
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Restaurant UPI Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _text)),
                  const SizedBox(height: 10),
                  _RowText(label: 'Account Name', value: accountName),
                  _RowText(label: 'UPI ID', value: upiId),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _txnController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'UPI transaction ID / reference number',
                      hintText: 'Enter payment reference number',
                      prefixIcon: const Icon(Icons.receipt_long_rounded, color: _orange),
                      filled: true,
                      fillColor: const Color(0xFFFFF7F0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFFFD9BD))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFFFD9BD))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: _orange, width: 1.4)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your transaction ID will be hidden from the restaurant screen. Restaurant will enter the received reference from its bank/UPI app for verification.',
                    style: TextStyle(color: _muted, fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ],
              ),
            )
          else
            const _InfoBox(
              text:
                  'No online payment is required now. After confirming cash on delivery, the plan will become active and cash will be collected during delivery.',
            ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD9BD)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF0E4) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? const Color(0xFFFF6A00) : const Color(0xFFFFD9BD), width: selected ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFF6A00)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF241A14))),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7B6250), height: 1.25)),
                  ],
                ),
              ),
              Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? const Color(0xFFFF6A00) : const Color(0xFFBCA89A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowText extends StatelessWidget {
  const _RowText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Color(0xFF7B6250), fontWeight: FontWeight.w800))),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF241A14), fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD9BD)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF7B6250), fontWeight: FontWeight.w800, height: 1.35)),
    );
  }
}
