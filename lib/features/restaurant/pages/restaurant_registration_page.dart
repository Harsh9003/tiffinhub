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
  final _monthlyPriceController = TextEditingController();

  bool _isVeg = true;
  bool _isNonVeg = false;
  bool _isLunch = true;
  bool _isDinner = true;

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

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
        monthlyPrice: double.parse(
          _monthlyPriceController.text.trim(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Restaurant profile submitted successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
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
    _monthlyPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Registration'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
            _buildTextField(
              label: 'Monthly Tiffin Price',
              controller: _monthlyPriceController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            const Text(
              'Meal Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            CheckboxListTile(
              value: _isVeg,
              onChanged: (value) {
                setState(() {
                  _isVeg = value ?? false;
                });
              },
              title: const Text('Veg'),
            ),

            CheckboxListTile(
              value: _isNonVeg,
              onChanged: (value) {
                setState(() {
                  _isNonVeg = value ?? false;
                });
              },
              title: const Text('Non-Veg'),
            ),

            const SizedBox(height: 10),

            const Text(
              'Available Meals',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            CheckboxListTile(
              value: _isLunch,
              onChanged: (value) {
                setState(() {
                  _isLunch = value ?? false;
                });
              },
              title: const Text('Lunch'),
            ),

            CheckboxListTile(
              value: _isDinner,
              onChanged: (value) {
                setState(() {
                  _isDinner = value ?? false;
                });
              },
              title: const Text('Dinner'),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: Text(
                  _isLoading
                      ? 'Please wait...'
                      : 'Submit Restaurant',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}