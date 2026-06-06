import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerAddressModel {
  final String id;
  final String title;
  final String receiverName;
  final String phone;
  final String addressLine;
  final String landmark;
  final String city;
  final String pincode;
  final bool isDefault;
  final bool isSelected;

  CustomerAddressModel({
    required this.id,
    required this.title,
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    required this.landmark,
    required this.city,
    required this.pincode,
    required this.isDefault,
    required this.isSelected,
  });

  factory CustomerAddressModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CustomerAddressModel(
      id: doc.id,
      title: data['title'] ?? 'Home',
      receiverName: data['receiverName'] ?? '',
      phone: data['phone'] ?? '',
      addressLine: data['addressLine'] ?? '',
      landmark: data['landmark'] ?? '',
      city: data['city'] ?? '',
      pincode: data['pincode'] ?? '',
      isDefault: data['isDefault'] == true,
      isSelected: data['isSelected'] == true || data['selected'] == true,
    );
  }
}

class CustomerAddressChangeRequestModel {
  final String id;
  final String addressId;
  final String title;
  final String receiverName;
  final String phone;
  final String addressLine;
  final String landmark;
  final String city;
  final String pincode;
  final String customerNote;
  final String status;
  final String rejectionReason;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? cancelledAt;

  CustomerAddressChangeRequestModel({
    required this.id,
    required this.addressId,
    required this.title,
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    required this.landmark,
    required this.city,
    required this.pincode,
    required this.customerNote,
    required this.status,
    required this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    required this.cancelledAt,
  });

  factory CustomerAddressChangeRequestModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CustomerAddressChangeRequestModel(
      id: doc.id,
      addressId: data['addressId'] ?? '',
      title: data['title'] ?? 'Address',
      receiverName: data['receiverName'] ?? '',
      phone: data['phone'] ?? '',
      addressLine: data['addressLine'] ?? '',
      landmark: data['landmark'] ?? '',
      city: data['city'] ?? '',
      pincode: data['pincode'] ?? '',
      customerNote: data['customerNote'] ?? '',
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'] ?? '',
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null,
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] as Timestamp : null,
      cancelledAt: data['cancelledAt'] is Timestamp ? data['cancelledAt'] as Timestamp : null,
    );
  }
}

class CustomerService {
  CustomerService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static CollectionReference<Map<String, dynamic>> _addressRef() {
    return _db.collection('users').doc(_uid).collection('addresses');
  }

  static Stream<List<CustomerAddressModel>> watchAddresses() {
    return _addressRef().snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => CustomerAddressModel.fromDoc(doc))
          .toList();

      list.sort((a, b) {
        if (a.isSelected && !b.isSelected) return -1;
        if (!a.isSelected && b.isSelected) return 1;
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return 0;
      });

      return list;
    });
  }

  static Future<void> addAddress({
    required String title,
    required String receiverName,
    required String phone,
    required String addressLine,
    required String landmark,
    required String city,
    required String pincode,
    required bool makeDefault,
  }) async {
    final ref = _addressRef();
    final oldAddresses = await ref.get();
    final shouldDefault = makeDefault || oldAddresses.docs.isEmpty;
    final shouldSelect = oldAddresses.docs.isEmpty;

    final batch = _db.batch();

    if (shouldDefault) {
      for (final doc in oldAddresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    if (shouldSelect) {
      for (final doc in oldAddresses.docs) {
        batch.update(doc.reference, {'isSelected': false, 'selected': false});
      }
    }

    final newDoc = ref.doc();
    batch.set(newDoc, {
      'title': title.trim(),
      'receiverName': receiverName.trim(),
      'phone': phone.trim(),
      'addressLine': addressLine.trim(),
      'landmark': landmark.trim(),
      'city': city.trim(),
      'pincode': pincode.trim(),
      'isDefault': shouldDefault,
      'isSelected': shouldSelect,
      'selected': shouldSelect,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (shouldSelect) {
      batch.set(
        _db.collection('users').doc(_uid),
        {
          'selectedAddressId': newDoc.id,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  static Future<void> updateAddress({
    required String addressId,
    required String title,
    required String receiverName,
    required String phone,
    required String addressLine,
    required String landmark,
    required String city,
    required String pincode,
    required bool makeDefault,
  }) async {
    final ref = _addressRef();
    final oldAddresses = await ref.get();

    final batch = _db.batch();

    if (makeDefault) {
      for (final doc in oldAddresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    batch.update(ref.doc(addressId), {
      'title': title.trim(),
      'receiverName': receiverName.trim(),
      'phone': phone.trim(),
      'addressLine': addressLine.trim(),
      'landmark': landmark.trim(),
      'city': city.trim(),
      'pincode': pincode.trim(),
      if (makeDefault) 'isDefault': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  static Future<void> deleteAddress(String addressId) async {
    final ref = _addressRef();
    final userRef = _db.collection('users').doc(_uid);

    final userDoc = await userRef.get();
    final selectedAddressId = userDoc.data()?['selectedAddressId']?.toString();

    await ref.doc(addressId).delete();

    if (selectedAddressId == addressId) {
      final remaining = await ref.limit(1).get();
      if (remaining.docs.isEmpty) {
        await userRef.set(
          {
            'selectedAddressId': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        await setSelectedAddress(remaining.docs.first.id);
      }
    }
  }

  static Future<void> setSelectedAddress(String addressId) async {
    final ref = _addressRef();
    final all = await ref.get();

    final batch = _db.batch();

    for (final doc in all.docs) {
      batch.update(doc.reference, {
        'isSelected': doc.id == addressId,
        'selected': doc.id == addressId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    batch.set(
      _db.collection('users').doc(_uid),
      {
        'selectedAddressId': addressId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  static Future<void> setDefaultAddress(String addressId) async {
    final ref = _addressRef();
    final all = await ref.get();

    final batch = _db.batch();

    for (final doc in all.docs) {
      batch.update(doc.reference, {
        'isDefault': doc.id == addressId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  static CollectionReference<Map<String, dynamic>> _addressChangeRequestRef() {
    return _db.collection('users').doc(_uid).collection('address_change_requests');
  }

  static Stream<List<CustomerAddressChangeRequestModel>> watchAddressChangeRequests() {
    return _addressChangeRequestRef().snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => CustomerAddressChangeRequestModel.fromDoc(doc))
          .toList();

      list.sort((a, b) {
        final aDate = a.createdAt?.toDate();
        final bDate = b.createdAt?.toDate();
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return list;
    });
  }

  static Future<void> sendAddressChangeRequest({
    required CustomerAddressModel address,
    String note = '',
  }) async {
    await _addressChangeRequestRef().add({
      'addressId': address.id,
      'title': address.title.trim(),
      'receiverName': address.receiverName.trim(),
      'phone': address.phone.trim(),
      'addressLine': address.addressLine.trim(),
      'landmark': address.landmark.trim(),
      'city': address.city.trim(),
      'pincode': address.pincode.trim(),
      'customerNote': note.trim(),
      'status': 'pending',
      'reviewStatus': 'request_submitted',
      'cancellationAllowedUntil': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 2)),
      ),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> cancelAddressChangeRequest(String requestId) async {
    await _addressChangeRequestRef().doc(requestId).update({
      'status': 'cancelled_by_customer',
      'reviewStatus': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
