import 'package:flutter/material.dart';

import '../services/customer_service.dart';

class CustomerAddressesPage extends StatelessWidget {
  final bool returnToPreviousOnSelect;

  const CustomerAddressesPage({
    super.key,
    this.returnToPreviousOnSelect = false,
  });

  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _softOrange = Color(0xFFFFF0E4);
  static const Color _text = Color(0xFF241A14);
  static const Color _muted = Color(0xFF7B6B60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: StreamBuilder<List<CustomerAddressModel>>(
                stream: CustomerService.watchAddresses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Unable to load address information. Please try again later.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  }

                  final addresses = snapshot.data ?? [];

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
                    children: [
                      _InfoBanner(),
                      const SizedBox(height: 14),
                      if (addresses.isEmpty) const _EmptyAddressCard(),
                      ...addresses.map(
                        (address) => _AddressCard(
                          address: address,
                          onSelect: () => _selectAddress(context, address),
                          onEdit: () => _openAddressSheet(context, address: address),
                          onDelete: () => _deleteAddress(context, address),
                          onDefault: () => _setDefault(context, address),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _orange,
        foregroundColor: Colors.white,
        elevation: 10,
        onPressed: () => _openAddressSheet(context),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Add Address',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Future<void> _openAddressSheet(
    BuildContext context, {
    CustomerAddressModel? address,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressFormSheet(address: address),
    );
  }


  Future<void> _selectAddress(
    BuildContext context,
    CustomerAddressModel address,
  ) async {
    try {
      await CustomerService.setSelectedAddress(address.id);
      if (!context.mounted) return;

      _toast(context, 'Delivery address selected');

      if (returnToPreviousOnSelect) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!context.mounted) return;
      _toast(context, 'Unable to select address. Please try again later.');
    }
  }

  static Future<void> _deleteAddress(
    BuildContext context,
    CustomerAddressModel address,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('${address.title} address deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CustomerService.deleteAddress(address.id);
      if (!context.mounted) return;
      _toast(context, 'Address deleted');
    } catch (e) {
      if (!context.mounted) return;
      _toast(context, 'Delete failed: $e');
    }
  }

  static Future<void> _setDefault(
    BuildContext context,
    CustomerAddressModel address,
  ) async {
    if (address.isDefault) return;
    try {
      await CustomerService.setDefaultAddress(address.id);
      if (!context.mounted) return;
      _toast(context, '${address.title} default address set');
    } catch (e) {
      if (!context.mounted) return;
      _toast(context, 'Default address not set: $e');
    }
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(
            child: Text(
              'Saved Addresses',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomerAddressesPage._text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6A00), Color(0xFFFF9A2E)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomerAddressesPage._orange.withOpacity(.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.location_on_rounded, color: CustomerAddressesPage._orange),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primary Delivery Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This address will be used for active subscriptions and future delivery requests.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

class _EmptyAddressCard extends StatelessWidget {
  const _EmptyAddressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD8BD)),
      ),
      child: const Column(
        children: [
          Icon(Icons.add_location_alt_rounded, size: 44, color: CustomerAddressesPage._orange),
          SizedBox(height: 10),
          Text(
            'No saved address',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 5),
          Text(
            'Add Home or office delivery address.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CustomerAddressesPage._muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final CustomerAddressModel address;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDefault;

  const _AddressCard({
    required this.address,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onDefault,
  });

  IconData get _icon {
    final title = address.title.toLowerCase();
    if (title.contains('office')) return Icons.business_rounded;
    if (title.contains('other')) return Icons.bookmark_rounded;
    return Icons.home_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: address.isDefault ? CustomerAddressesPage._orange : const Color(0xFFFFD8BD),
          width: address.isDefault ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: CustomerAddressesPage._softOrange,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_icon, color: CustomerAddressesPage._orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerAddressesPage._text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (address.isDefault) const _DefaultBadge(),
                    if (!address.isDefault && address.isSelected)
                      const _SelectedBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                if (address.receiverName.isNotEmpty || address.phone.isNotEmpty)
                  Text(
                    [address.receiverName, address.phone].where((e) => e.trim().isNotEmpty).join(' • '),
                    style: const TextStyle(
                      color: CustomerAddressesPage._text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  [
                    address.addressLine,
                    address.landmark,
                    address.city,
                    address.pincode,
                  ].where((e) => e.trim().isNotEmpty).join(', '),
                  style: const TextStyle(
                    color: CustomerAddressesPage._muted,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniAction(icon: Icons.edit_rounded, label: 'Edit', onTap: onEdit),
                    _MiniAction(icon: Icons.delete_outline_rounded, label: 'Delete', onTap: onDelete),
                    if (!address.isDefault)
                      _MiniAction(icon: Icons.star_rounded, label: 'Set Default', onTap: onDefault),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: CustomerAddressesPage._softOrange,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'Selected',
        style: TextStyle(
          color: CustomerAddressesPage._orange,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: CustomerAddressesPage._softOrange,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'Default',
        style: TextStyle(
          color: CustomerAddressesPage._orange,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F0),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: CustomerAddressesPage._orange),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: CustomerAddressesPage._text,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final CustomerAddressModel? address;

  const _AddressFormSheet({this.address});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _receiverName;
  late final TextEditingController _phone;
  late final TextEditingController _addressLine;
  late final TextEditingController _landmark;
  late final TextEditingController _city;
  late final TextEditingController _pincode;
  bool _makeDefault = false;
  bool _saving = false;

  bool get _isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _title = TextEditingController(text: a?.title ?? 'Home');
    _receiverName = TextEditingController(text: a?.receiverName ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _addressLine = TextEditingController(text: a?.addressLine ?? '');
    _landmark = TextEditingController(text: a?.landmark ?? '');
    _city = TextEditingController(text: a?.city ?? 'Jaipur');
    _pincode = TextEditingController(text: a?.pincode ?? '');
    _makeDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _receiverName.dispose();
    _phone.dispose();
    _addressLine.dispose();
    _landmark.dispose();
    _city.dispose();
    _pincode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: const BoxDecoration(
          color: CustomerAddressesPage._bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7D3C2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEdit ? 'Edit Address' : 'Add Address',
                  style: const TextStyle(
                    color: CustomerAddressesPage._text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _field(_title, 'Address type', Icons.bookmark_rounded)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _title.text.trim().isEmpty ? 'Home' : _title.text.trim(),
                        decoration: _decoration('Quick select', Icons.tune_rounded),
                        items: const [
                          DropdownMenuItem(value: 'Home', child: Text('Home')),
                          DropdownMenuItem(value: 'Office', child: Text('Office')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          _title.text = value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _field(_receiverName, 'Receiver name', Icons.person_rounded),
                const SizedBox(height: 10),
                _field(
                  _phone,
                  'Phone number',
                  Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null;
                    if (v.length < 10) return 'Valid phone number dalo';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _field(
                  _addressLine,
                  'Complete address',
                  Icons.location_on_rounded,
                  maxLines: 3,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Address required hai';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _field(_landmark, 'Landmark', Icons.near_me_rounded),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _field(_city, 'City', Icons.location_city_rounded)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _field(
                        _pincode,
                        'Pincode',
                        Icons.pin_drop_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Pincode required';
                          if (v.length != 6) return '6 digit pincode';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  value: _makeDefault,
                  activeColor: CustomerAddressesPage._orange,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Set as default address',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text('This address will be auto selected for delivery requests.'),
                  onChanged: (value) => setState(() => _makeDefault = value),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomerAddressesPage._orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isEdit ? 'Update Address' : 'Save Address',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: CustomerAddressesPage._orange),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFFD8BD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFFD8BD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: CustomerAddressesPage._orange, width: 1.4),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      if (_isEdit) {
        await CustomerService.updateAddress(
          addressId: widget.address!.id,
          title: _title.text,
          receiverName: _receiverName.text,
          phone: _phone.text,
          addressLine: _addressLine.text,
          landmark: _landmark.text,
          city: _city.text,
          pincode: _pincode.text,
          makeDefault: _makeDefault,
        );
      } else {
        await CustomerService.addAddress(
          title: _title.text,
          receiverName: _receiverName.text,
          phone: _phone.text,
          addressLine: _addressLine.text,
          landmark: _landmark.text,
          city: _city.text,
          pincode: _pincode.text,
          makeDefault: _makeDefault,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Address updated' : 'Address saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
