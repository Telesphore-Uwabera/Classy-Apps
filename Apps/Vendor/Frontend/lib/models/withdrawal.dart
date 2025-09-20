import 'dart:convert';

class Withdrawal {
  final String id;
  final String vendorId;
  final String paymentAccountId;
  final double amount;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? transactionId;
  final DateTime? requestedAt;

  Withdrawal({
    required this.id,
    required this.vendorId,
    required this.paymentAccountId,
    required this.amount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.processedAt,
    this.transactionId,
    this.requestedAt,
  });

  factory Withdrawal.fromMap(Map<String, dynamic> map) {
    return Withdrawal(
      id: map['id'] ?? '',
      vendorId: map['vendorId'] ?? '',
      paymentAccountId: map['paymentAccountId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      processedAt: map['processedAt'] != null ? DateTime.parse(map['processedAt']) : null,
      transactionId: map['transactionId'],
      requestedAt: map['requestedAt'] != null ? DateTime.parse(map['requestedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'paymentAccountId': paymentAccountId,
      'amount': amount,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'transactionId': transactionId,
      'requestedAt': requestedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  Withdrawal copyWith({
    String? id,
    String? vendorId,
    String? paymentAccountId,
    double? amount,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? processedAt,
    String? transactionId,
  }) {
    return Withdrawal(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      transactionId: transactionId ?? this.transactionId,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  // Additional getters for compatibility
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FF9800';
      case 'processing':
        return '#2196F3';
      case 'completed':
        return '#4CAF50';
      case 'cancelled':
        return '#F44336';
      default:
        return '#FF9800';
    }
  }

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  String get methodDisplayName {
    return 'Bank Transfer'; // Default method
  }

  bool get canBeCancelled {
    return status.toLowerCase() == 'pending';
  }
}