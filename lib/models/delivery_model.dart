import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryStatus {
  pending,
  pickedUp,
  delivered,
  failed,
}

class DeliveryModel {
  final String id;
  final String subscriptionId;

  final String customerId;
  final String customerName;

  final String restaurantId;
  final String restaurantName;

  final String deliveryAgentId;
  final String deliveryAgentName;

  final DateTime deliveryDate;

  final DeliveryStatus status;

  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  final String? failureReason;

  final DateTime createdAt;

  const DeliveryModel({
    required this.id,
    required this.subscriptionId,
    required this.customerId,
    required this.customerName,
    required this.restaurantId,
    required this.restaurantName,
    required this.deliveryAgentId,
    required this.deliveryAgentName,
    required this.deliveryDate,
    required this.status,
    this.pickedUpAt,
    this.deliveredAt,
    this.failureReason,
    required this.createdAt,
  });

  factory DeliveryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return DeliveryModel(
      id: map['id'] ?? '',
      subscriptionId: map['subscriptionId'] ?? '',

      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',

      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',

      deliveryAgentId: map['deliveryAgentId'] ?? '',
      deliveryAgentName: map['deliveryAgentName'] ?? '',

      deliveryDate: map['deliveryDate'] is Timestamp
          ? (map['deliveryDate'] as Timestamp).toDate()
          : DateTime.now(),

      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DeliveryStatus.pending,
      ),

      pickedUpAt: map['pickedUpAt'] != null
          ? (map['pickedUpAt'] as Timestamp).toDate()
          : null,

      deliveredAt: map['deliveredAt'] != null
          ? (map['deliveredAt'] as Timestamp).toDate()
          : null,

      failureReason: map['failureReason'],

      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,

      'customerId': customerId,
      'customerName': customerName,

      'restaurantId': restaurantId,
      'restaurantName': restaurantName,

      'deliveryAgentId': deliveryAgentId,
      'deliveryAgentName': deliveryAgentName,

      'deliveryDate': Timestamp.fromDate(deliveryDate),

      'status': status.name,

      'pickedUpAt': pickedUpAt != null
          ? Timestamp.fromDate(pickedUpAt!)
          : null,

      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,

      'failureReason': failureReason,

      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}