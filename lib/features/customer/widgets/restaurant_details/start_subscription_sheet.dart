import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StartSubscriptionSheet extends StatefulWidget {
  final String restaurantName;
  final double planPrice;
  final double trialPrice;
  final double weeklyPrice;

  final double monthlyLunchPrice;
  final double monthlyDinnerPrice;
  final double monthlyLunchDinnerPrice;
  final double weeklyLunchPrice;
  final double weeklyDinnerPrice;
  final double weeklyLunchDinnerPrice;
  final double trialLunchPrice;
  final double trialDinnerPrice;
  final double trialLunchDinnerPrice;

  const StartSubscriptionSheet({
    super.key,
    required this.restaurantName,
    required this.planPrice,
    required this.trialPrice,
    required this.weeklyPrice,
    required this.monthlyLunchPrice,
    required this.monthlyDinnerPrice,
    required this.monthlyLunchDinnerPrice,
    required this.weeklyLunchPrice,
    required this.weeklyDinnerPrice,
    required this.weeklyLunchDinnerPrice,
    required this.trialLunchPrice,
    required this.trialDinnerPrice,
    required this.trialLunchDinnerPrice,
  });

  @override
  State<StartSubscriptionSheet> createState() => _StartSubscriptionSheetState();
}

class _StartSubscriptionSheetState extends State<StartSubscriptionSheet> {
  final _noteController = TextEditingController();

  String _selectedPlan = 'Monthly Veg Plan';
  String _mealType = 'Lunch';
  String _lunchDeliveryTime = '12:00 PM - 2:00 PM';
  String _dinnerDeliveryTime = '7:00 PM - 9:00 PM';
  String _paymentMode = 'Cash';

  int _quantity = 1;
  DateTime _startDate = DateTime.now();
  bool _isSaving = false;

  Map<String, dynamic>? _selectedAddress;
  String? _selectedAddressId;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  bool get _needsLunch => _mealType == 'Lunch' || _mealType == 'Lunch + Dinner';
  bool get _needsDinner => _mealType == 'Dinner' || _mealType == 'Lunch + Dinner';

  double get _selectedPlanPrice {
    if (_selectedPlan == 'Monthly Veg Plan') {
      if (_mealType == 'Lunch') return widget.monthlyLunchPrice;
      if (_mealType == 'Dinner') return widget.monthlyDinnerPrice;
      return widget.monthlyLunchDinnerPrice;
    }

    if (_selectedPlan == 'Weekly Veg Plan') {
      if (_mealType == 'Lunch') return widget.weeklyLunchPrice;
      if (_mealType == 'Dinner') return widget.weeklyDinnerPrice;
      return widget.weeklyLunchDinnerPrice;
    }

    if (_mealType == 'Lunch') return widget.trialLunchPrice;
    if (_mealType == 'Dinner') return widget.trialDinnerPrice;
    return widget.trialLunchDinnerPrice;
  }

  double get _totalAmount => _selectedPlanPrice * _quantity;

  String get _paymentStatus {
    if (_paymentMode == 'Cash') return 'pending_collection';
    return 'pending_confirmation';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (pickedDate != null) {
      setState(() => _startDate = pickedDate);
    }
  }

  Future<void> _saveSubscription() async {
    final user = _currentUser;

    if (user == null) {
      _showMessage('Please sign in before starting a subscription.', isError: true);
      return;
    }

    if (_selectedAddress == null || _selectedAddressId == null) {
      _showMessage('Please select or add a delivery address first.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('subscriptions').add({
        'userId': user.uid,
        'userEmail': user.email,
        'restaurantName': widget.restaurantName,
        'planName': _selectedPlan,
        'mealType': _mealType,
        'planPrice': _selectedPlanPrice,
        'quantity': _quantity,
        'totalAmount': _totalAmount,
        'lunchDeliveryTime': _needsLunch ? _lunchDeliveryTime : null,
        'dinnerDeliveryTime': _needsDinner ? _dinnerDeliveryTime : null,
        'startDate': Timestamp.fromDate(_startDate),
        'addressId': _selectedAddressId,
        'addressTitle': _selectedAddress!['title'] ?? '',
        'customerName': _selectedAddress!['name'] ?? '',
        'phone': _selectedAddress!['phone'] ?? '',
        'address': _selectedAddress!['fullAddress'] ?? '',
        'landmark': _selectedAddress!['landmark'] ?? '',
        'city': _selectedAddress!['city'] ?? '',
        'pincode': _selectedAddress!['pincode'] ?? '',
        'paymentMode': _paymentMode,
        'paymentStatus': _paymentStatus,
        'paymentCollectedAt': null,
        'paymentCollectedBy': null,
        'deliveryStatus': 'pending',
        'note': _noteController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      await _showSubscriptionSuccessDialog();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to submit request: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showSubscriptionSuccessDialog() async {
    bool closed = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 4), () {
          if (closed) return;
          if (Navigator.of(dialogContext).canPop()) {
            closed = true;
            Navigator.of(dialogContext).pop();
          }
        });

        return _SubscriptionSuccessDialog(
          onClose: () {
            if (closed) return;
            closed = true;
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFFF6A00),
      ),
    );
  }

  CollectionReference<Map<String, dynamic>>? _addressCollection() {
    final user = _currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortedAddressDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sortedDocs = [...docs];
    sortedDocs.sort((a, b) {
      final aData = a.data();
      final bData = b.data();
      final aDefault = aData['isDefault'] == true;
      final bDefault = bData['isDefault'] == true;

      if (aDefault != bDefault) return aDefault ? -1 : 1;

      final aCreatedAt = aData['createdAt'];
      final bCreatedAt = bData['createdAt'];
      final aMillis = aCreatedAt is Timestamp ? aCreatedAt.millisecondsSinceEpoch : 0;
      final bMillis = bCreatedAt is Timestamp ? bCreatedAt.millisecondsSinceEpoch : 0;

      return bMillis.compareTo(aMillis);
    });
    return sortedDocs;
  }

  Future<void> _openAddressSelector() async {
    final user = _currentUser;
    if (user == null) {
      _showMessage('Please sign in to manage delivery addresses.', isError: true);
      return;
    }

    final selected = await showModalBottomSheet<_AddressResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SavedAddressSheet(selectedAddressId: _selectedAddressId),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedAddressId = selected.id;
        _selectedAddress = selected.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF2D241F),
        title: Text(
          widget.restaurantName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF7),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A00),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFFFB37A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirm Subscription • ₹${_totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
          children: [
            const Text(
              'Configure Your Subscription',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    title: 'Plan',
                    value: _selectedPlan,
                    items: const ['Monthly Veg Plan', 'Weekly Veg Plan', 'Trial Tiffin'],
                    onChanged: (value) => setState(() => _selectedPlan = value!),
                    compact: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    title: 'Meal Type',
                    value: _mealType,
                    items: const ['Lunch', 'Dinner', 'Lunch + Dinner'],
                    onChanged: (value) => setState(() => _mealType = value!),
                    compact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSelectedPlanPriceCard(),
            const SizedBox(height: 10),
            _buildTimeSelectors(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildDateBlock()),
                const SizedBox(width: 10),
                Expanded(child: _buildQuantitySelector()),
              ],
            ),
            const SizedBox(height: 10),
            _buildAddressBlock(),
            const SizedBox(height: 10),
            _buildDropdown(
              title: 'Payment Mode',
              value: _paymentMode,
              items: const ['Cash', 'UPI'],
              onChanged: (value) => setState(() => _paymentMode = value!),
            ),
            const SizedBox(height: 8),
            _buildPaymentInfoText(),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _noteController,
              label: 'Note Optional',
              icon: Icons.notes_rounded,
              required: false,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectors() {
    if (_needsLunch && _needsDinner) {
      return Row(
        children: [
          Expanded(
            child: _buildDropdown(
              title: 'Lunch Time',
              value: _lunchDeliveryTime,
              items: const ['11:00 AM - 1:00 PM', '12:00 PM - 2:00 PM', '1:00 PM - 3:00 PM'],
              onChanged: (value) => setState(() => _lunchDeliveryTime = value!),
              compact: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdown(
              title: 'Dinner Time',
              value: _dinnerDeliveryTime,
              items: const ['6:00 PM - 8:00 PM', '7:00 PM - 9:00 PM', '8:00 PM - 10:00 PM'],
              onChanged: (value) => setState(() => _dinnerDeliveryTime = value!),
              compact: true,
            ),
          ),
        ],
      );
    }

    if (_needsLunch) {
      return _buildDropdown(
        title: 'Lunch Time',
        value: _lunchDeliveryTime,
        items: const ['11:00 AM - 1:00 PM', '12:00 PM - 2:00 PM', '1:00 PM - 3:00 PM'],
        onChanged: (value) => setState(() => _lunchDeliveryTime = value!),
      );
    }

    return _buildDropdown(
      title: 'Dinner Time',
      value: _dinnerDeliveryTime,
      items: const ['6:00 PM - 8:00 PM', '7:00 PM - 9:00 PM', '8:00 PM - 10:00 PM'],
      onChanged: (value) => setState(() => _dinnerDeliveryTime = value!),
    );
  }

  Widget _buildAddressBlock() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _addressCollection()?.snapshots(),
      builder: (context, snapshot) {
        final docs = _sortedAddressDocs(snapshot.data?.docs ?? []);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _addressCard(
            title: 'Loading address...',
            subtitle: 'Please wait',
            icon: Icons.location_on_rounded,
          );
        }

        if (_selectedAddress == null && docs.isNotEmpty) {
          final defaultDoc = docs.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _selectedAddress != null) return;
            setState(() {
              _selectedAddressId = defaultDoc.id;
              _selectedAddress = defaultDoc.data();
            });
          });
        }

        if (docs.isEmpty) {
          return InkWell(
            onTap: _openAddressSelector,
            borderRadius: BorderRadius.circular(16),
            child: _addressCard(
              title: 'Please enter address first',
              subtitle: 'Tap here to add your delivery address',
              icon: Icons.add_location_alt_rounded,
              showArrow: false,
            ),
          );
        }

        final address = _selectedAddress ?? docs.first.data();
        final title = (address['title'] ?? 'Address').toString();
        final fullAddress = (address['fullAddress'] ?? '').toString();

        return InkWell(
          onTap: _openAddressSelector,
          borderRadius: BorderRadius.circular(16),
          child: _addressCard(
            title: title,
            subtitle: fullAddress.isEmpty ? 'Tap to select delivery address' : fullAddress,
            icon: Icons.location_on_rounded,
          ),
        );
      },
    );
  }

  Widget _addressCard({
    required String title,
    required String subtitle,
    required IconData icon,
    bool showArrow = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: _boxDecoration(radius: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF6A00), size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.28,
                    color: Colors.black.withOpacity(0.56),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black45),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedPlanPriceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _boxDecoration(radius: 16),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: Color(0xFFFF6A00), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Selected Plan Price',
              style: TextStyle(
                color: Colors.black.withOpacity(0.62),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '₹${_selectedPlanPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Color(0xFFFF6A00),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _boxDecoration(radius: 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Tiffins',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
          InkWell(
            onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
            borderRadius: BorderRadius.circular(20),
            child: Icon(
              Icons.remove_circle_outline_rounded,
              color: _quantity > 1 ? Colors.black45 : Colors.black26,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$_quantity',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => setState(() => _quantity++),
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.add_circle_rounded, color: Color(0xFFFF6A00), size: 23),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBlock() {
    final dateText = '${_startDate.day}/${_startDate.month}/${_startDate.year}';

    return InkWell(
      onTap: _pickStartDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _boxDecoration(radius: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Color(0xFFFF6A00), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.48),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateText,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoText() {
    final text = _paymentMode == 'Cash'
        ? 'Cash payment will be collected during delivery.'
        : 'UPI payment will be confirmed by the restaurant.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(
            _paymentMode == 'Cash' ? Icons.payments_rounded : Icons.account_balance_wallet_rounded,
            color: const Color(0xFFFF6A00),
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black.withOpacity(0.58),
                fontSize: 12.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool compact = false,
  }) {
    return Container(
      height: compact ? 62 : 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _boxDecoration(radius: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
        decoration: InputDecoration(
          labelText: title,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(
            color: Color(0xFFFF6A00),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.only(top: 10),
        ),
        selectedItemBuilder: (_) {
          return items.map((item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
            );
          }).toList();
        },
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFF6A00), size: 21),
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration({double radius = 18}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFFFD7B5)),
    );
  }
}

class _SubscriptionSuccessDialog extends StatefulWidget {
  final VoidCallback onClose;

  const _SubscriptionSuccessDialog({required this.onClose});

  @override
  State<_SubscriptionSuccessDialog> createState() => _SubscriptionSuccessDialogState();
}

class _SubscriptionSuccessDialogState extends State<_SubscriptionSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _floatAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 92,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 18,
                        top: 20 + _floatAnimation.value,
                        child: const Text('🎈', style: TextStyle(fontSize: 30)),
                      ),
                      Positioned(
                        right: 22,
                        top: 12 - _floatAnimation.value,
                        child: const Text('🎉', style: TextStyle(fontSize: 30)),
                      ),
                      Positioned(
                        right: 48,
                        bottom: 14 + _floatAnimation.value,
                        child: const Text('✨', style: TextStyle(fontSize: 24)),
                      ),
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6A00).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFFFF6A00),
                            size: 52,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thank You!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D241F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your subscription request has been submitted successfully. The restaurant will review it shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.35,
                color: Colors.black.withOpacity(0.60),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'OK, Got It',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressResult {
  final String id;
  final Map<String, dynamic> data;

  const _AddressResult({required this.id, required this.data});
}

class _SavedAddressSheet extends StatelessWidget {
  final String? selectedAddressId;

  const _SavedAddressSheet({required this.selectedAddressId});

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>>? _addressCollection() {
    final user = _currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses');
  }

  Future<void> _openAddAddressDialog(BuildContext context) async {
    final saved = await showDialog<_AddressResult>(
      context: context,
      builder: (_) => const _AddAddressDialog(),
    );

    if (saved != null && context.mounted) {
      Navigator.pop(context, saved);
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortAddressDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sortedDocs = [...docs];
    sortedDocs.sort((a, b) {
      final aData = a.data();
      final bData = b.data();
      final aDefault = aData['isDefault'] == true;
      final bDefault = bData['isDefault'] == true;

      if (aDefault != bDefault) return aDefault ? -1 : 1;

      final aCreatedAt = aData['createdAt'];
      final bCreatedAt = bData['createdAt'];
      final aMillis = aCreatedAt is Timestamp ? aCreatedAt.millisecondsSinceEpoch : 0;
      final bMillis = bCreatedAt is Timestamp ? bCreatedAt.millisecondsSinceEpoch : 0;

      return bMillis.compareTo(aMillis);
    });
    return sortedDocs;
  }

  @override
  Widget build(BuildContext context) {
    final addressRef = _addressCollection();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Delivery Address',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: addressRef?.snapshots(),
                builder: (context, snapshot) {
                  final docs = _sortAddressDocs(snapshot.data?.docs ?? []);

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: Color(0xFFFF6A00)),
                    );
                  }

                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No saved address found. Add your delivery address to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.58),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final isSelected = doc.id == selectedAddressId;
                      final title = (data['title'] ?? 'Address').toString();
                      final fullAddress = (data['fullAddress'] ?? '').toString();
                      final landmark = (data['landmark'] ?? '').toString();

                      return InkWell(
                        onTap: () => Navigator.pop(
                          context,
                          _AddressResult(id: doc.id, data: data),
                        ),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF6A00)
                                  : const Color(0xFFFFD7B5),
                              width: isSelected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: const Color(0xFFFF6A00),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fullAddress,
                                      style: TextStyle(
                                        height: 1.35,
                                        color: Colors.black.withOpacity(0.62),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (landmark.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Landmark: $landmark',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.52),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _openAddAddressDialog(context),
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text(
                  'Add New Address',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6A00),
                  side: const BorderSide(color: Color(0xFFFF6A00)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog();

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _titleController = TextEditingController(text: 'Home');
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _isSaving = false;
  bool _setAsDefault = true;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final addressRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      if (_setAsDefault) {
        final oldDefault = await addressRef.where('isDefault', isEqualTo: true).get();
        for (final doc in oldDefault.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }

      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'title': _titleController.text.trim(),
        'fullAddress': _addressController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'isDefault': _setAsDefault,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final doc = await addressRef.add(data);

      if (!mounted) return;
      Navigator.pop(context, _AddressResult(id: doc.id, data: data));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Delivery Address',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _dialogTextField(_titleController, 'Address Title', Icons.bookmark_rounded),
              const SizedBox(height: 10),
              _dialogTextField(_nameController, 'Receiver Name', Icons.person_rounded),
              const SizedBox(height: 10),
              _dialogTextField(
                _phoneController,
                'Mobile Number',
                Icons.call_rounded,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mobile number is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Enter a valid mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _dialogTextField(
                _addressController,
                'Full Delivery Address',
                Icons.home_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              _dialogTextField(_landmarkController, 'Landmark', Icons.location_on_rounded),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _dialogTextField(_cityController, 'City', Icons.location_city_rounded)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dialogTextField(
                      _pincodeController,
                      'Pincode',
                      Icons.pin_drop_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _setAsDefault,
                onChanged: (value) => setState(() => _setAsDefault = value ?? true),
                activeColor: const Color(0xFFFF6A00),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Set as default address',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Address',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFF6A00)),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFFBF7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
