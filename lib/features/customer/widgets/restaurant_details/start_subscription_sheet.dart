import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StartSubscriptionSheet extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final double planPrice;
  final double trialPrice;
  final double weeklyPrice;
  final String ownerName;
  final List<String> lunchSlots;
  final List<String> dinnerSlots;

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
    required this.restaurantId,
    required this.restaurantName,
    required this.planPrice,
    required this.trialPrice,
    required this.weeklyPrice,
    this.ownerName = '',
    this.lunchSlots = const [],
    this.dinnerSlots = const [],
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
  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _softOrange = Color(0xFFFFF0E4);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF7B6250);

  final TextEditingController _noteController = TextEditingController();

  String _selectedPlan = 'Monthly Veg Plan';
  String _mealType = 'Lunch + Dinner';
  String _lunchTime = '12:00 PM - 2:00 PM';
  String _dinnerTime = '7:00 PM - 9:00 PM';
  String _lunchServiceMode = 'Delivery';
  String _dinnerServiceMode = 'Delivery';

  int _quantity = 1;
  DateTime _startDate = DateTime.now();
  bool _isSaving = false;
  bool _showPriceDetails = false;

  Map<String, dynamic>? _selectedAddress;
  String? _selectedAddressId;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  bool get _needsLunch => _mealType == 'Lunch' || _mealType == 'Lunch + Dinner';
  bool get _needsDinner => _mealType == 'Dinner' || _mealType == 'Lunch + Dinner';

  bool get _requiresDeliveryAddress {
    if (_needsLunch && _lunchServiceMode == 'Delivery') return true;
    if (_needsDinner && _dinnerServiceMode == 'Delivery') return true;
    return false;
  }

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

  double get _planSubtotal => _selectedPlanPrice * _quantity;

  @override
  void initState() {
    super.initState();

    final availableLunchSlots = _effectiveLunchSlots;
    final availableDinnerSlots = _effectiveDinnerSlots;

    if (availableLunchSlots.isNotEmpty) {
      _lunchTime = availableLunchSlots.first;
    }

    if (availableDinnerSlots.isNotEmpty) {
      _dinnerTime = availableDinnerSlots.first;
    }
  }

  List<String> get _effectiveLunchSlots {
    final cleaned = widget.lunchSlots
        .map((slot) => slot.trim())
        .where((slot) => slot.isNotEmpty)
        .toSet()
        .toList();

    if (cleaned.isNotEmpty) return cleaned;

    return const ['11:00 AM - 1:00 PM', '12:00 PM - 2:00 PM', '1:00 PM - 3:00 PM'];
  }

  List<String> get _effectiveDinnerSlots {
    final cleaned = widget.dinnerSlots
        .map((slot) => slot.trim())
        .where((slot) => slot.isNotEmpty)
        .toSet()
        .toList();

    if (cleaned.isNotEmpty) return cleaned;

    return const ['6:00 PM - 8:00 PM', '7:00 PM - 9:00 PM', '8:00 PM - 10:00 PM'];
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

    if (pickedDate != null && mounted) {
      setState(() => _startDate = pickedDate);
    }
  }

  Future<void> _sendSubscriptionRequest(double platformFee) async {
    final user = _currentUser;

    if (user == null) {
      _showMessage('Please sign in before sending a subscription request.', isError: true);
      return;
    }

    if (_requiresDeliveryAddress && (_selectedAddress == null || _selectedAddressId == null)) {
      _showMessage('Please select a delivery address to continue.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = FieldValue.serverTimestamp();
      final cancelAllowedUntil = Timestamp.fromDate(DateTime.now().add(const Duration(hours: 2)));
      final addressSnapshot = _selectedAddress == null
          ? null
          : {
              'addressId': _selectedAddressId,
              'title': _readAddressValue(_selectedAddress!, ['title'], fallback: 'Address'),
              'receiverName': _readAddressValue(_selectedAddress!, ['receiverName', 'name'], fallback: ''),
              'phone': _readAddressValue(_selectedAddress!, ['phone'], fallback: ''),
              'addressLine': _readAddressValue(
                _selectedAddress!,
                ['addressLine', 'fullAddress', 'address'],
                fallback: '',
              ),
              'landmark': _readAddressValue(_selectedAddress!, ['landmark'], fallback: ''),
              'city': _readAddressValue(_selectedAddress!, ['city'], fallback: ''),
              'pincode': _readAddressValue(_selectedAddress!, ['pincode'], fallback: ''),
            };

      await FirebaseFirestore.instance.collection('subscription_requests').add({
        'customerId': user.uid,
        'customerName': user.displayName ?? '',
        'customerEmail': user.email ?? '',
        'customerPhone': user.phoneNumber ?? '',
        'restaurantId': widget.restaurantId,
        'restaurantName': widget.restaurantName,
        'planName': _selectedPlan,
        'mealType': _mealType,
        'planPrice': _selectedPlanPrice,
        'quantity': _quantity,
        'planSubtotal': _planSubtotal,
        'platformFee': platformFee,
        'totalPayableAfterApproval': _planSubtotal + platformFee,
        'lunchTime': _needsLunch ? _lunchTime : null,
        'dinnerTime': _needsDinner ? _dinnerTime : null,
        'lunchServiceMode': _needsLunch ? _lunchServiceMode : null,
        'dinnerServiceMode': _needsDinner ? _dinnerServiceMode : null,
        'requiresDeliveryAddress': _requiresDeliveryAddress,
        'addressId': _requiresDeliveryAddress ? _selectedAddressId : null,
        'addressSnapshot': _requiresDeliveryAddress ? addressSnapshot : null,
        'startDate': Timestamp.fromDate(_startDate),
        'specialInstructions': _noteController.text.trim(),
        'status': 'request_pending',
        'requestStage': 'customer_submitted',
        'paymentStatus': 'payment_not_requested',
        'paymentFlow': 'approval_first_direct_restaurant_payment',
        'cancelAllowedUntil': cancelAllowedUntil,
        'isCustomerCancellable': true,
        'createdAt': now,
        'updatedAt': now,
      });

      if (!mounted) return;
      await _showSubscriptionSuccessDialog();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to submit the subscription request. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showSubscriptionSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Request Submitted',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Your subscription request has been sent to the restaurant. Payment details will be shared only after the restaurant confirms availability.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.35, fontWeight: FontWeight.w600),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  CollectionReference<Map<String, dynamic>>? _addressCollection() {
    final user = _currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _platformFeeStream() {
    return FirebaseFirestore.instance.collection('app_settings').doc('subscription_pricing').snapshots();
  }

  double _platformFeeFromData(Map<String, dynamic>? data) {
    if (data == null) return 0;
    final enabled = data['platformFeeEnabled'];
    if (enabled == false) return 0;

    final raw = data['platformFee'] ?? data['subscriptionPlatformFee'] ?? data['customerPlatformFee'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
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

  void _syncInvalidServiceModes() {
    if (!_needsLunch) _lunchServiceMode = 'Delivery';
    if (!_needsDinner) _dinnerServiceMode = 'Delivery';
  }

  @override
  Widget build(BuildContext context) {
    _syncInvalidServiceModes();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _platformFeeStream(),
      builder: (context, feeSnapshot) {
        final platformFee = _platformFeeFromData(feeSnapshot.data?.data());
        final totalAmount = _planSubtotal + platformFee;

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _bg,
            elevation: 0,
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
            foregroundColor: _text,
            title: const Text(
              'Start Subscription',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _BottomActionBar(
              isSaving: _isSaving,
              totalAmount: totalAmount,
              showPriceDetails: _showPriceDetails,
              onTogglePrice: () => setState(() => _showPriceDetails = !_showPriceDetails),
              onSubmit: () => _sendSubscriptionRequest(platformFee),
            ),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 92),
              children: [
                _RestaurantSummaryCard(
                  restaurantName: widget.restaurantName,
                  ownerName: widget.ownerName,
                ),
                const SizedBox(height: 8),
                _SectionCard(
                  number: '1',
                  title: 'Plan & Meal Details',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildProfessionalDropdown(
                              label: 'Plan',
                              value: _selectedPlan,
                              icon: Icons.calendar_month_rounded,
                              items: const ['Monthly Veg Plan', 'Weekly Veg Plan', 'Trial Tiffin'],
                              onChanged: (value) => setState(() => _selectedPlan = value!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildProfessionalDropdown(
                              label: 'Meal Type',
                              value: _mealType,
                              icon: Icons.restaurant_rounded,
                              items: const ['Lunch', 'Dinner', 'Lunch + Dinner'],
                              onChanged: (value) => setState(() => _mealType = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTimeSelectors(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _SectionCard(
                  number: '2',
                  title: 'Subscription Details',
                  child: Row(
                    children: [
                      Expanded(child: _buildDateBlock()),
                      const SizedBox(width: 8),
                      Expanded(child: _buildQuantitySelector()),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _SectionCard(
                  number: '3',
                  title: 'Service Mode',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_needsLunch) ...[
                        _MealServiceModeSelector(
                          title: _needsDinner ? 'Lunch Service Mode' : 'Service Mode',
                          value: _lunchServiceMode,
                          onChanged: (value) => setState(() => _lunchServiceMode = value),
                        ),
                      ],
                      if (_needsLunch && _needsDinner) const SizedBox(height: 8),
                      if (_needsDinner) ...[
                        _MealServiceModeSelector(
                          title: _needsLunch ? 'Dinner Service Mode' : 'Service Mode',
                          value: _dinnerServiceMode,
                          onChanged: (value) => setState(() => _dinnerServiceMode = value),
                        ),
                      ],
                      if (_requiresDeliveryAddress) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Delivery Address',
                          style: TextStyle(color: _muted, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        _buildAddressBlock(),
                      ],
                      const SizedBox(height: 8),
                      _InfoNote(
                        icon: Icons.info_outline_rounded,
                        text:
                            'The restaurant will review service availability before payment details are shared.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _SectionCard(
                  number: '4',
                  title: 'Payment After Approval',
                  child: const _InfoNote(
                    icon: Icons.account_balance_wallet_rounded,
                    text:
                        'No payment is collected while sending this request. Once the restaurant approves availability, payment details will be shown for direct payment to the restaurant.',
                  ),
                ),
                const SizedBox(height: 8),
                _SectionCard(
                  number: '5',
                  title: 'Special Instructions',
                  optional: true,
                  child: _buildNoteField(),
                ),
                const SizedBox(height: 8),
                if (_showPriceDetails)
                  _PriceDetailsCard(
                    planSubtotal: _planSubtotal,
                    platformFee: platformFee,
                    totalAmount: totalAmount,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSelectors() {
    final lunch = _buildProfessionalDropdown(
      label: 'Lunch Time',
      value: _lunchTime,
      icon: Icons.access_time_rounded,
      items: _effectiveLunchSlots,
      onChanged: (value) => setState(() => _lunchTime = value!),
    );

    final dinner = _buildProfessionalDropdown(
      label: 'Dinner Time',
      value: _dinnerTime,
      icon: Icons.access_time_rounded,
      items: _effectiveDinnerSlots,
      onChanged: (value) => setState(() => _dinnerTime = value!),
    );

    if (_needsLunch && _needsDinner) {
      return Row(
        children: [
          Expanded(child: lunch),
          const SizedBox(width: 8),
          Expanded(child: dinner),
        ],
      );
    }

    return _needsLunch ? lunch : dinner;
  }

  Widget _buildAddressBlock() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _addressCollection()?.snapshots(),
      builder: (context, snapshot) {
        final docs = _sortedAddressDocs(snapshot.data?.docs ?? []);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _addressCard(
            title: 'Loading Address',
            subtitle: 'Please wait while we fetch your saved addresses.',
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
              title: 'Add Delivery Address',
              subtitle: 'A delivery address is required for delivery service.',
              icon: Icons.add_location_alt_rounded,
              showArrow: false,
            ),
          );
        }

        final address = _selectedAddress ?? docs.first.data();
        final title = _readAddressValue(address, ['title'], fallback: 'Address');
        final fullAddress = _addressDisplayLine(address);

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
      padding: const EdgeInsets.all(8),
      decoration: _fieldDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _softOrange, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: _orange, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, color: _text, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.32,
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: _fieldDecoration(),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tiffins', style: TextStyle(color: _muted, fontWeight: FontWeight.w700, fontSize: 11)),
                SizedBox(height: 4),
                Text('Per Day', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          InkWell(
            onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
            borderRadius: BorderRadius.circular(16),
            child: Icon(
              Icons.remove_circle_outline_rounded,
              color: _quantity > 1 ? Colors.black45 : Colors.black26,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => setState(() => _quantity++),
            borderRadius: BorderRadius.circular(16),
            child: const Icon(Icons.add_circle_rounded, color: _orange, size: 21),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBlock() {
    final dateText = _formatDate(_startDate);

    return InkWell(
      onTap: _pickStartDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: _fieldDecoration(),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: _orange, size: 22),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Date', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(dateText, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: _fieldDecoration(),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _muted),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _orange, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 28),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.only(top: 9),
        ),
        selectedItemBuilder: (_) {
          return items.map((item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            );
          }).toList();
        },
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      maxLength: 120,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 38),
          child: Icon(Icons.chat_bubble_outline_rounded, color: _orange),
        ),
        hintText: 'Add preferences or delivery instructions.',
        hintStyle: const TextStyle(color: Color(0xFFB59B8A), fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD7B5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _orange, width: 1.4),
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFD7B5)),
    );
  }

  static String _readAddressValue(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  static String _addressDisplayLine(Map<String, dynamic> data) {
    final parts = [
      _readAddressValue(data, ['addressLine', 'fullAddress', 'address'], fallback: ''),
      _readAddressValue(data, ['landmark'], fallback: ''),
      _readAddressValue(data, ['city'], fallback: ''),
      _readAddressValue(data, ['pincode'], fallback: ''),
    ].where((item) => item.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  static String _formatDate(DateTime date) {
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
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _RestaurantSummaryCard extends StatelessWidget {
  final String restaurantName;
  final String ownerName;

  const _RestaurantSummaryCard({
    required this.restaurantName,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE1C8)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFFF6A00), size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF241A14), fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  ownerName.trim().isEmpty ? 'Owner details will be verified by restaurant' : 'Owner: ${ownerName.trim()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7B6250),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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

class _SectionCard extends StatelessWidget {
  final String number;
  final String title;
  final bool optional;
  final Widget child;

  const _SectionCard({
    required this.number,
    required this.title,
    required this.child,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE1C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFFF6A00),
                child: Text(
                  number,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: title,
                    style: const TextStyle(color: Color(0xFF241A14), fontSize: 13.5, fontWeight: FontWeight.w900),
                    children: optional
                        ? const [
                            TextSpan(
                              text: '  (Optional)',
                              style: TextStyle(color: Color(0xFF7B6250), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _MealServiceModeSelector extends StatelessWidget {
  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  const _MealServiceModeSelector({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7B6250),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _ModeTile(
                title: 'Delivery',
                subtitle: 'Doorstep',
                icon: Icons.delivery_dining_rounded,
                selected: value == 'Delivery',
                onTap: () => onChanged('Delivery'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ModeTile(
                title: 'Pickup',
                subtitle: 'Collect',
                icon: Icons.storefront_rounded,
                selected: value == 'Self Pickup',
                onTap: () => onChanged('Self Pickup'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ModeTile(
                title: 'Dine-In',
                subtitle: 'At restaurant',
                icon: Icons.restaurant_rounded,
                selected: value == 'Dine-In',
                onTap: () => onChanged('Dine-In'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class _ModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool fullWidth;
  final VoidCallback onTap;

  const _ModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF3EA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFFF6A00) : const Color(0xFFFFD7B5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFE0C8) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? const Color(0xFFFF6A00) : Colors.black45),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF7B6250), fontSize: 9.5, height: 1.0, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFFFF6A00), size: 15),
          ],
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF6A00), size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF7B6250),
                fontSize: 12.8,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceDetailsCard extends StatelessWidget {
  final double planSubtotal;
  final double platformFee;
  final double totalAmount;

  const _PriceDetailsCard({
    required this.planSubtotal,
    required this.platformFee,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD7B5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _PriceRow(label: 'Plan Subtotal', amount: planSubtotal),
          const SizedBox(height: 8),
          _PriceRow(label: 'Platform Fee', amount: platformFee),
          const Divider(height: 22),
          _PriceRow(label: 'Total Payable After Approval', amount: totalAmount, strong: true),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool strong;

  const _PriceRow({required this.label, required this.amount, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong ? const Color(0xFF241A14) : const Color(0xFF7B6250),
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: strong ? const Color(0xFFFF6A00) : const Color(0xFF241A14),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final bool isSaving;
  final double totalAmount;
  final bool showPriceDetails;
  final VoidCallback onTogglePrice;
  final VoidCallback onSubmit;

  const _BottomActionBar({
    required this.isSaving,
    required this.totalAmount,
    required this.showPriceDetails,
    required this.onTogglePrice,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF7),
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, -6)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6A00),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6A00).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isSaving ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Send Request • ₹${totalAmount.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : onTogglePrice,
                icon: Icon(showPriceDetails ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                label: const Text('Details'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6A00),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
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
    return FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses');
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
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(100)),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text('Select Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
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
                        'No saved address found. Add a delivery address to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black.withOpacity(0.58), fontWeight: FontWeight.w600),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final isSelected = doc.id == selectedAddressId;
                      final title = _StartSubscriptionSheetState._readAddressValue(data, ['title'], fallback: 'Address');
                      final fullAddress = _StartSubscriptionSheetState._addressDisplayLine(data);

                      return InkWell(
                        onTap: () => Navigator.pop(context, _AddressResult(id: doc.id, data: data)),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF6A00) : const Color(0xFFFFD7B5),
                              width: isSelected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: const Color(0xFFFF6A00),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 4),
                                    Text(
                                      fullAddress,
                                      style: TextStyle(height: 1.35, color: Colors.black.withOpacity(0.62), fontWeight: FontWeight.w600),
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
                label: const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.w900)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6A00),
                  side: const BorderSide(color: Color(0xFFFF6A00)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      final addressRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses');

      if (_setAsDefault) {
        final oldDefault = await addressRef.where('isDefault', isEqualTo: true).get();
        for (final doc in oldDefault.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }

      final data = {
        'receiverName': _nameController.text.trim(),
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'title': _titleController.text.trim(),
        'addressLine': _addressController.text.trim(),
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
        SnackBar(content: Text('Failed to save address: $e'), backgroundColor: Colors.red),
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
                  const Expanded(child: Text('Add Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 8),
              _dialogTextField(_titleController, 'Address Title', Icons.bookmark_rounded),
              const SizedBox(height: 8),
              _dialogTextField(_nameController, 'Receiver Name', Icons.person_rounded),
              const SizedBox(height: 8),
              _dialogTextField(
                _phoneController,
                'Mobile Number',
                Icons.call_rounded,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Mobile number is required';
                  if (value.trim().length < 10) return 'Enter a valid mobile number';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _dialogTextField(_addressController, 'Full Delivery Address', Icons.home_rounded, maxLines: 3),
              const SizedBox(height: 8),
              _dialogTextField(_landmarkController, 'Landmark', Icons.location_on_rounded),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _dialogTextField(_cityController, 'City', Icons.location_city_rounded)),
                  const SizedBox(width: 8),
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
                title: const Text('Set as primary address', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
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
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Save Address', style: TextStyle(fontWeight: FontWeight.w900)),
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
            if (value == null || value.trim().isEmpty) return '$label is required';
            return null;
          },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFF6A00)),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFFBF7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
