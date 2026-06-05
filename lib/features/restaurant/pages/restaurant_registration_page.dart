import 'package:flutter/material.dart';
import 'restaurant_registration_status_page.dart';
import '../services/restaurant_service.dart';

class RestaurantRegistrationPage extends StatefulWidget {
  const RestaurantRegistrationPage({super.key});

  @override
  State<RestaurantRegistrationPage> createState() => _RestaurantRegistrationPageState();
}

class _RestaurantRegistrationPageState extends State<RestaurantRegistrationPage> {
  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF7B6250);

  final _formKey = GlobalKey<FormState>();

  final _restaurantName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController(text: 'Jaipur');
  final _address = TextEditingController();
  final _mapLink = TextEditingController();
  final _serviceArea = TextEditingController(text: '5 KM');
  final _deliveryRadius = TextEditingController(text: '5');
  final _lunchSlots = TextEditingController(text: '12:00 PM - 2:00 PM');
  final _dinnerSlots = TextEditingController(text: '7:00 PM - 9:00 PM');
  final _weeklyOffDays = TextEditingController();
  final _cutoffTime = TextEditingController(text: '10:00 AM');
  final _upiId = TextEditingController();
  final _qrCodeUrl = TextEditingController();
  final _accountHolder = TextEditingController();
  final _fssaiNumber = TextEditingController();
  final _logoUrl = TextEditingController();
  final _coverImageUrl = TextEditingController();

  final _trialLunch = TextEditingController(text: '180');
  final _trialDinner = TextEditingController(text: '180');
  final _trialBoth = TextEditingController(text: '320');
  final _weeklyLunch = TextEditingController();
  final _weeklyDinner = TextEditingController();
  final _weeklyBoth = TextEditingController();
  final _monthlyLunch = TextEditingController(text: '2500');
  final _monthlyDinner = TextEditingController(text: '2500');
  final _monthlyBoth = TextEditingController(text: '4500');

  String _foodType = 'Pure Veg';
  bool _delivery = true;
  bool _pickup = true;
  bool _dineIn = false;
  bool _trialEnabled = true;
  bool _weeklyEnabled = false;
  bool _monthlyEnabled = true;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in [
      _restaurantName,_ownerName,_phone,_email,_city,_address,_mapLink,_serviceArea,_deliveryRadius,
      _lunchSlots,_dinnerSlots,_weeklyOffDays,_cutoffTime,_upiId,_qrCodeUrl,_accountHolder,_fssaiNumber,
      _logoUrl,_coverImageUrl,_trialLunch,_trialDinner,_trialBoth,_weeklyLunch,_weeklyDinner,_weeklyBoth,
      _monthlyLunch,_monthlyDinner,_monthlyBoth,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_trialEnabled) {
      _message('Trial plan is required for new restaurant onboarding.');
      return;
    }
    if (!_weeklyEnabled && !_monthlyEnabled) {
      _message('Enable at least one plan: Weekly or Monthly.');
      return;
    }
    if (!_delivery && !_pickup && !_dineIn) {
      _message('Enable at least one service mode.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await RestaurantService.registerOrUpdateRestaurant(data: {
        'restaurantName': _restaurantName.text.trim(),
        'ownerName': _ownerName.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'city': _city.text.trim(),
        'address': _address.text.trim(),
        'googleMapLink': _mapLink.text.trim(),
        'serviceArea': _serviceArea.text.trim(),
        'serviceAreaLabel': _serviceArea.text.trim(),
        'deliveryRadiusKm': _num(_deliveryRadius.text),
        'foodType': _foodType,
        'vegType': _foodType,
        'estimatedDeliveryTime': '30-45 min',
        'isDeliveryAvailable': _delivery,
        'isPickupAvailable': _pickup,
        'isDineInAvailable': _dineIn,
        'trialPlanEnabled': _trialEnabled,
        'weeklyPlanEnabled': _weeklyEnabled,
        'monthlyPlanEnabled': _monthlyEnabled,
        'trialLunchPrice': _num(_trialLunch.text),
        'trialDinnerPrice': _num(_trialDinner.text),
        'trialLunchDinnerPrice': _num(_trialBoth.text),
        'weeklyLunchPrice': _weeklyEnabled ? _num(_weeklyLunch.text) : 0,
        'weeklyDinnerPrice': _weeklyEnabled ? _num(_weeklyDinner.text) : 0,
        'weeklyLunchDinnerPrice': _weeklyEnabled ? _num(_weeklyBoth.text) : 0,
        'monthlyLunchPrice': _monthlyEnabled ? _num(_monthlyLunch.text) : 0,
        'monthlyDinnerPrice': _monthlyEnabled ? _num(_monthlyDinner.text) : 0,
        'monthlyLunchDinnerPrice': _monthlyEnabled ? _num(_monthlyBoth.text) : 0,
        'lunchSlots': _list(_lunchSlots.text),
        'dinnerSlots': _list(_dinnerSlots.text),
        'weeklyOffDays': _list(_weeklyOffDays.text),
        'orderCutoffTime': _cutoffTime.text.trim(),
        'upiId': _upiId.text.trim(),
        'qrCodeUrl': _qrCodeUrl.text.trim(),
        'accountHolderName': _accountHolder.text.trim(),
        'fssaiNumber': _fssaiNumber.text.trim(),
        'logoUrl': _logoUrl.text.trim(),
        'coverImageUrl': _coverImageUrl.text.trim(),
      });
      if (!mounted) return;
      _message('Restaurant registration submitted for admin review.');
      Navigator.pop(context);
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const RestaurantRegistrationStatusPage(),
      ),
);
    } catch (e) {
      _message('Unable to submit restaurant details. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _message(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  double _num(String v) => double.tryParse(v.trim()) ?? 0;
  List<String> _list(String v) => v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _text,
        title: const Text('Restaurant Registration', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: _orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(_isSaving ? 'Submitting...' : 'Submit for Admin Approval', style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            _HeaderCard(),
            _Section(title: 'Basic Details', number: 1, children: [
              _two(_field(_restaurantName, 'Restaurant Name', required: true), _field(_ownerName, 'Owner Name', required: true)),
              _two(_field(_phone, 'Owner Phone', required: true, keyboard: TextInputType.phone), _field(_email, 'Business Email', keyboard: TextInputType.emailAddress)),
              _field(_city, 'City', required: true),
              _field(_address, 'Full Restaurant Address', required: true, maxLines: 2),
              _field(_mapLink, 'Google Map Link'),
            ]),
            _Section(title: 'Food & Service Coverage', number: 2, children: [
              _dropdown('Food Type', _foodType, ['Pure Veg', 'Veg & Non-Veg'], (v) => setState(() => _foodType = v!)),
              _two(_field(_serviceArea, 'Service Area Label', required: true), _field(_deliveryRadius, 'Delivery Radius (KM)', required: true, keyboard: TextInputType.number)),
              _SwitchTile(title: 'Delivery', value: _delivery, onChanged: (v) => setState(() => _delivery = v)),
              _SwitchTile(title: 'Self Pickup', value: _pickup, onChanged: (v) => setState(() => _pickup = v)),
              _SwitchTile(title: 'Dine-In', value: _dineIn, onChanged: (v) => setState(() => _dineIn = v)),
            ]),
            _Section(title: 'Plans & Pricing', number: 3, children: [
              _SwitchTile(title: 'Trial Plan', subtitle: 'Required for onboarding', value: _trialEnabled, onChanged: null),
              _priceRow('Trial', _trialLunch, _trialDinner, _trialBoth, enabled: _trialEnabled),
              _SwitchTile(title: 'Weekly Plan', subtitle: 'Optional', value: _weeklyEnabled, onChanged: (v) => setState(() => _weeklyEnabled = v)),
              if (_weeklyEnabled) _priceRow('Weekly', _weeklyLunch, _weeklyDinner, _weeklyBoth, enabled: true),
              _SwitchTile(title: 'Monthly Plan', subtitle: 'Recommended', value: _monthlyEnabled, onChanged: (v) => setState(() => _monthlyEnabled = v)),
              if (_monthlyEnabled) _priceRow('Monthly', _monthlyLunch, _monthlyDinner, _monthlyBoth, enabled: true),
            ]),
            _Section(title: 'Timings', number: 4, children: [
              _field(_lunchSlots, 'Lunch Slots', required: true, helper: 'Comma separated'),
              _field(_dinnerSlots, 'Dinner Slots', required: true, helper: 'Comma separated'),
              _two(_field(_weeklyOffDays, 'Weekly Off Days'), _field(_cutoffTime, 'Order Cut-off Time', required: true)),
            ]),
            _Section(title: 'Payment Setup', number: 5, children: [
              _field(_accountHolder, 'Account / Business Name', required: true),
              _field(_upiId, 'Restaurant UPI ID', required: true),
              _field(_qrCodeUrl, 'QR Code Image URL'),
            ]),
            _Section(title: 'Verification & Media', number: 6, children: [
              _field(_fssaiNumber, 'FSSAI Number'),
              _field(_logoUrl, 'Logo Image URL'),
              _field(_coverImageUrl, 'Cover Image URL'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, TextEditingController lunch, TextEditingController dinner, TextEditingController both, {required bool enabled}) {
    return Row(children: [
      Expanded(child: _field(lunch, '$label Lunch', required: enabled, keyboard: TextInputType.number)),
      const SizedBox(width: 8),
      Expanded(child: _field(dinner, '$label Dinner', required: enabled, keyboard: TextInputType.number)),
      const SizedBox(width: 8),
      Expanded(child: _field(both, '$label Both', required: enabled, keyboard: TextInputType.number)),
    ]);
  }

  Widget _two(Widget a, Widget b) => Row(children: [Expanded(child: a), const SizedBox(width: 10), Expanded(child: b)]);

  Widget _field(TextEditingController controller, String label, {bool required = false, int maxLines = 1, TextInputType? keyboard, String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _orange.withOpacity(.18))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _orange.withOpacity(.18))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _orange, width: 1.2)),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF9A1F)]), borderRadius: BorderRadius.circular(22)),
      child: const Row(children: [
        CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.storefront_rounded, color: Color(0xFFFF6A00))),
        SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Complete Restaurant Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          SizedBox(height: 4),
          Text('Submitted details will be reviewed by admin before your dashboard becomes active.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, height: 1.35)),
        ])),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final int number;
  final List<Widget> children;
  const _Section({required this.title, required this.number, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.78), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFD7B8))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(radius: 15, backgroundColor: const Color(0xFFFF6A00), child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const SizedBox(width: 9), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 12),
      ...children,
    ]),
  );
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _SwitchTile({required this.title, this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFFFF7EF), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), if (subtitle != null) Text(subtitle!, style: const TextStyle(color: Color(0xFF7B6250), fontSize: 12, fontWeight: FontWeight.w700))])),
      Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFFF6A00)),
    ]),
  );
}
