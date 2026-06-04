import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionStatus {
  pending,
  active,
  paused,
  cancelled,
  completed,
}

class SubscriptionModel {
  final String id;

  final String customerId;
  final String restaurantId;
  final String planId;

  final String customerName;
  final String restaurantName;
  final String planName;

  final double amount;

  final DateTime startDate;
  final DateTime endDate;

  final SubscriptionStatus status;

  final DateTime createdAt;

  const SubscriptionModel({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.planId,
    required this.customerName,
    required this.restaurantName,
    required this.planName,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  factory SubscriptionModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return SubscriptionModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      planId: map['planId'] ?? '',
      customerName: map['customerName'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      planName: map['planName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubscriptionStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'restaurantId': restaurantId,
      'planId': planId,
      'customerName': customerName,
      'restaurantName': restaurantName,
      'planName': planName,
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}