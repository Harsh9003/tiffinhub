import 'package:flutter/material.dart';

import '../services/restaurant_service.dart';

class RestaurantRegistrationPage extends StatefulWidget {
  const RestaurantRegistrationPage({super.key});

  @override
  State<RestaurantRegistrationPage> createState() =>
      _RestaurantRegistrationPageState();
}

class _RestaurantRegistrationPageState
    extends State<RestaurantRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _restaurantNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _serviceAreaController = TextEditingController();

  final _monthlyLunchPriceController = TextEditingController();
  final _monthlyDinnerPriceController = TextEditingController();
  final _monthlyLunchDinnerPriceController = TextEditingController();

  final _weeklyLunchPriceController = TextEditingController();
  final _weeklyDinnerPriceController = TextEditingController();
  final _weeklyLunchDinnerPriceController = TextEditingController();

  final _trialLunchPriceController = TextEditingController();
  final _trialDinnerPriceController = TextEditingController();
  final _trialLunchDinnerPriceController = TextEditingController();

  bool _isVeg = true;
  bool _isNonVeg = false;
  bool _isLunch = true;
  bool _isDinner = true;
  bool _isLoading = false;

  double _price(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLunch && !_isDinner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one available meal.'),
        ),
      );
      return;
    }

    if (!_isVeg && !_isNonVeg) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one meal category.'),
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final monthlyLunchPrice = _price(_monthlyLunchPriceController);
      final monthlyDinnerPrice = _price(_monthlyDinnerPriceController);
      final monthlyLunchDinnerPrice =
          _price(_monthlyLunchDinnerPriceController);

      final weeklyLunchPrice = _price(_weeklyLunchPriceController);
      final weeklyDinnerPrice = _price(_weeklyDinnerPriceController);
      final weeklyLunchDinnerPrice = _price(_weeklyLunchDinnerPriceController);

      final trialLunchPrice = _price(_trialLunchPriceController);
      final trialDinnerPrice = _price(_trialDinnerPriceController);
      final trialLunchDinnerPrice = _price(_trialLunchDinnerPriceController);

      await RestaurantService.createRestaurantProfile(
        restaurantName: _restaurantNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        serviceArea: _serviceAreaController.text.trim(),
        isVegAvailable: _isVeg,
        isNonVegAvailable: _isNonVeg,
        isLunchAvailable: _isLunch,
        isDinnerAvailable: _isDinner,

        // Old/common price fields are still saved for backward compatibility.
        monthlyPrice: monthlyLunchDinnerPrice,
        weeklyPrice: weeklyLunchDinnerPrice,
        trialPrice: trialLunchPrice,

        // New proper meal-wise price fields.
        monthlyLunchPrice: monthlyLunchPrice,
        monthlyDinnerPrice: monthlyDinnerPrice,
        monthlyLunchDinnerPrice: monthlyLunchDinnerPrice,
        weeklyLunchPrice: weeklyLunchPrice,
        weeklyDinnerPrice: weeklyDinnerPrice,
        weeklyLunchDinnerPrice: weeklyLunchDinnerPrice,
        trialLunchPrice: trialLunchPrice,
        trialDinnerPrice: trialDinnerPrice,
        trialLunchDinnerPrice: trialLunchDinnerPrice,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant profile submitted successfully.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }

          if (keyboardType == TextInputType.number &&
              double.tryParse(value.trim()) == null) {
            return 'Enter a valid price';
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _serviceAreaController.dispose();

    _monthlyLunchPriceController.dispose();
    _monthlyDinnerPriceController.dispose();
    _monthlyLunchDinnerPriceController.dispose();

    _weeklyLunchPriceController.dispose();
    _weeklyDinnerPriceController.dispose();
    _weeklyLunchDinnerPriceController.dispose();

    _trialLunchPriceController.dispose();
    _trialDinnerPriceController.dispose();
    _trialLunchDinnerPriceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Restaurant Registration',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle('Restaurant Details'),
            _buildTextField(
              label: 'Restaurant Name',
              controller: _restaurantNameController,
            ),
            _buildTextField(
              label: 'Owner Name',
              controller: _ownerNameController,
            ),
            _buildTextField(
              label: 'Mobile Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              label: 'Address',
              controller: _addressController,
            ),
            _buildTextField(
              label: 'City',
              controller: _cityController,
            ),
            _buildTextField(
              label: 'Service Area (KM)',
              controller: _serviceAreaController,
            ),

            _sectionTitle(
              'Meal Category',
              subtitle: 'Select what this restaurant can provide.',
            ),
            CheckboxListTile(
              value: _isVeg,
              onChanged: (value) => setState(() => _isVeg = value ?? false),
              title: const Text('Veg'),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _isNonVeg,
              onChanged: (value) =>
                  setState(() => _isNonVeg = value ?? false),
              title: const Text('Non-Veg'),
              contentPadding: EdgeInsets.zero,
            ),

            _sectionTitle('Available Meals'),
            CheckboxListTile(
              value: _isLunch,
              onChanged: (value) => setState(() => _isLunch = value ?? false),
              title: const Text('Lunch'),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _isDinner,
              onChanged: (value) => setState(() => _isDinner = value ?? false),
              title: const Text('Dinner'),
              contentPadding: EdgeInsets.zero,
            ),

            _sectionTitle(
              'Monthly Plan Prices',
              subtitle: 'Lunch + Dinner can be different from single meal price.',
            ),
            _buildTextField(
              label: 'Monthly Lunch Price',
              controller: _monthlyLunchPriceController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              label: 'Monthly Dinner Price',
              controller: _monthlyDinnerPriceController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              label: 'Monthly Lunch + Dinner Price',
              controller: _monthlyLunchDinnerPriceController,
              keyboardType: TextInputType.number,
            ),

            _sectionTitle('Weekly Plan Prices'),
            _buildTextField(
              label: 'Weekly Lunch Price',
              controller: _weeklyLunchPriceController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              label: 'Weekly Dinner Price',
              controller: _weeklyDinnerPriceController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              label: 'Weekly Lunch + Dinner Price',
              controller: _weeklyLunchDinnerPriceController,
              keyboardType: TextInputType.number,
            ),

            _sectionTitle('Trial Tiffin Prices'),
            _buildTextField(
              label: 'Trial Lunch Price',
              controller: _trialLunchPriceController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              label: 'Trial Dinner Price',
              controller: _trialDinnerPriceController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              label: 'Trial Lunch + Dinner Price',
              controller: _trialLunchDinnerPriceController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 18),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isLoading ? 'Please wait...' : 'Submit Restaurant',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
