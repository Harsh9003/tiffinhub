import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/customer_addresses_page.dart';
import '../pages/customer_profile_page.dart';

class CustomerHeader extends StatefulWidget {
  const CustomerHeader({super.key});

  @override
  State<CustomerHeader> createState() => _CustomerHeaderState();
}

class _CustomerHeaderState extends State<CustomerHeader> {
  bool _vegOnly = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = _getDisplayName(user?.displayName, user?.email);
    final photoUrl = user?.photoURL;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerProfilePage(),
                ),
              );
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFFFE0B2),
              backgroundImage:
                  _hasValidPhoto(photoUrl) ? NetworkImage(photoUrl!) : null,
              child: _hasValidPhoto(photoUrl)
                  ? null
                  : const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFFF7A00),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CustomerLocationBlock(
              userId: user?.uid,
              displayName: displayName,
            ),
          ),
          const SizedBox(width: 10),
          _NotificationButton(onTap: () {}),
          const SizedBox(width: 10),
          _FoodModeToggle(
            vegOnly: _vegOnly,
            onChanged: (value) {
              setState(() => _vegOnly = value);
            },
          ),
        ],
      ),
    );
  }

  bool _hasValidPhoto(String? photoUrl) {
    return photoUrl != null && photoUrl.trim().isNotEmpty;
  }

  String _getDisplayName(String? name, String? email) {
    final cleanName = name?.trim();
    if (cleanName != null && cleanName.isNotEmpty) return cleanName;

    final cleanEmail = email?.trim();
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return cleanEmail.split('@').first;
    }

    return 'Customer';
  }
}

class _CustomerLocationBlock extends StatelessWidget {
  final String? userId;
  final String displayName;

  const _CustomerLocationBlock({
    required this.userId,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null || userId!.isEmpty) {
      return _LocationContent(
        displayName: displayName,
        addressText: 'Add delivery address',
        onTap: () => _openAddresses(context),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, userSnapshot) {
        final selectedAddressId =
            userSnapshot.data?.data()?['selectedAddressId']?.toString();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('addresses')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final selectedAddress = _pickSelectedAddress(
              docs,
              selectedAddressId: selectedAddressId,
            );
            final addressText = selectedAddress == null
                ? 'Add delivery address'
                : _formatAddress(selectedAddress.data());

            return _LocationContent(
              displayName: displayName,
              addressText: addressText,
              onTap: () => _openAddresses(context),
            );
          },
        );
      },
    );
  }

  QueryDocumentSnapshot<Map<String, dynamic>>? _pickSelectedAddress(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    String? selectedAddressId,
  }) {
    if (docs.isEmpty) return null;

    final selectedId = selectedAddressId?.trim();
    if (selectedId != null && selectedId.isNotEmpty) {
      for (final doc in docs) {
        if (doc.id == selectedId) return doc;
      }
    }

    for (final doc in docs) {
      final data = doc.data();
      if (data['selected'] == true || data['isSelected'] == true) {
        return doc;
      }
    }

    if (docs.length == 1) return docs.first;

    for (final doc in docs) {
      final data = doc.data();
      if (data['isDefault'] == true || data['default'] == true) {
        return doc;
      }
    }

    return docs.first;
  }

  String _formatAddress(Map<String, dynamic> data) {
    final label = _readString(data, [
      'label',
      'addressType',
      'type',
      'title',
    ]);

    final addressLine = _readString(data, [
      'addressLine',
      'fullAddress',
      'address',
      'line1',
      'houseAddress',
    ]);

    final area = _readString(data, [
      'area',
      'locality',
      'landmark',
      'street',
    ]);

    final city = _readString(data, ['city']);
    final state = _readString(data, ['state']);
    final pinCode = _readString(data, [
      'pinCode',
      'pincode',
      'postalCode',
      'zipCode',
    ]);

    final parts = <String>[
      if (label.isNotEmpty) label,
      if (addressLine.isNotEmpty) addressLine,
      if (area.isNotEmpty) area,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (pinCode.isNotEmpty) pinCode,
    ];

    if (parts.isEmpty) return 'Add delivery address';
    return parts.join(', ');
  }

  String _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  void _openAddresses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerAddressesPage(
          returnToPreviousOnSelect: true,
        ),
      ),
    );
  }
}

class _LocationContent extends StatelessWidget {
  final String displayName;
  final String addressText;
  final VoidCallback onTap;

  const _LocationContent({
    required this.displayName,
    required this.addressText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAddressMissing = addressText == 'Add delivery address';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivering To',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF241A14),
          ),
        ),
        const SizedBox(height: 3),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Row(
              children: [
                
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: Colors.black54,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    addressText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isAddressMissing
                          ? const Color(0xFFFF7A00)
                          : Colors.black54,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.2,
                      decorationColor: isAddressMissing
                          ? const Color(0xFFFF7A00)
                          : Colors.black45,
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: Color(0xFF241A14),
          size: 23,
        ),
      ),
    );
  }
}

class _FoodModeToggle extends StatelessWidget {
  final bool vegOnly;
  final ValueChanged<bool> onChanged;

  const _FoodModeToggle({
    required this.vegOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              vegOnly ? 'Veg Only' : 'Non-Veg',
              key: ValueKey(vegOnly),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF241A14),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Transform.scale(
            scale: 0.82,
            alignment: Alignment.centerRight,
            child: Switch(
              value: vegOnly,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF55C46B),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFFF7A00),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
