/// Enhanced Payment Models for CLASSY UG Payment Integration

class PaymentTransaction {
  final String id;
  final String orderId;
  final String customerId;
  final String providerId;
  final String providerType;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? externalReference;
  final double commission;
  final double processingFee;
  final double netAmount;
  final SettlementStatus settlementStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? processedAt;
  final DateTime? failedAt;
  final String? failureReason;

  PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.providerId,
    required this.providerType,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.externalReference,
    required this.commission,
    required this.processingFee,
    required this.netAmount,
    required this.settlementStatus,
    required this.createdAt,
    required this.updatedAt,
    this.processedAt,
    this.failedAt,
    this.failureReason,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      providerType: json['provider_type'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      method: PaymentMethod.fromString(json['payment_method'] ?? 'cash'),
      status: PaymentStatus.fromString(json['status'] ?? 'pending'),
      externalReference: json['external_reference'],
      commission: (json['commission'] ?? 0.0).toDouble(),
      processingFee: (json['processing_fee'] ?? 0.0).toDouble(),
      netAmount: (json['net_amount'] ?? 0.0).toDouble(),
      settlementStatus: SettlementStatus.fromString(json['settlement_status'] ?? 'pending'),
      createdAt: json['created_at']?.toDate() ?? DateTime.now(),
      updatedAt: json['updated_at']?.toDate() ?? DateTime.now(),
      processedAt: json['processed_at']?.toDate(),
      failedAt: json['failed_at']?.toDate(),
      failureReason: json['failure_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_id': customerId,
      'provider_id': providerId,
      'provider_type': providerType,
      'amount': amount,
      'currency': currency,
      'payment_method': method.value,
      'status': status.value,
      'external_reference': externalReference,
      'commission': commission,
      'processing_fee': processingFee,
      'net_amount': netAmount,
      'settlement_status': settlementStatus.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'processed_at': processedAt,
      'failed_at': failedAt,
      'failure_reason': failureReason,
    };
  }
}

enum PaymentMethod {
  cash('cash'),
  mobileMoney('mobile_money'),
  card('card'),
  eversend('eversend');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromString(String value) {
    switch (value) {
      case 'cash':
        return PaymentMethod.cash;
      case 'mobile_money':
        return PaymentMethod.mobileMoney;
      case 'card':
        return PaymentMethod.card;
      case 'eversend':
        return PaymentMethod.eversend;
      default:
        return PaymentMethod.cash;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash Payment';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.card:
        return 'Card Payment';
      case PaymentMethod.eversend:
        return 'Eversend';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.cash:
        return 'Pay with cash directly to the service provider';
      case PaymentMethod.mobileMoney:
        return 'Pay with Mobile Money (MTN, Airtel)';
      case PaymentMethod.card:
        return 'Pay with Visa or Mastercard';
      case PaymentMethod.eversend:
        return 'Send money globally with Eversend';
    }
  }
}

enum PaymentStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled'),
  refunded('refunded');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

enum SettlementStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed');

  const SettlementStatus(this.value);
  final String value;

  static SettlementStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return SettlementStatus.pending;
      case 'processing':
        return SettlementStatus.processing;
      case 'completed':
        return SettlementStatus.completed;
      case 'failed':
        return SettlementStatus.failed;
      default:
        return SettlementStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case SettlementStatus.pending:
        return 'Pending Settlement';
      case SettlementStatus.processing:
        return 'Processing Settlement';
      case SettlementStatus.completed:
        return 'Settled';
      case SettlementStatus.failed:
        return 'Settlement Failed';
    }
  }
}

class ProviderCommission {
  final String id;
  final String providerId;
  final String providerType;
  final double amount;
  final CommissionStatus status;
  final String? settlementId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderCommission({
    required this.id,
    required this.providerId,
    required this.providerType,
    required this.amount,
    required this.status,
    this.settlementId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderCommission.fromJson(Map<String, dynamic> json) {
    return ProviderCommission(
      id: json['id'] ?? '',
      providerId: json['provider_id'] ?? '',
      providerType: json['provider_type'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: CommissionStatus.fromString(json['status'] ?? 'pending'),
      settlementId: json['settlement_id'],
      createdAt: json['created_at']?.toDate() ?? DateTime.now(),
      updatedAt: json['updated_at']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'provider_type': providerType,
      'amount': amount,
      'status': status.value,
      'settlement_id': settlementId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

enum CommissionStatus {
  pending('pending'),
  settled('settled'),
  failed('failed');

  const CommissionStatus(this.value);
  final String value;

  static CommissionStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return CommissionStatus.pending;
      case 'settled':
        return CommissionStatus.settled;
      case 'failed':
        return CommissionStatus.failed;
      default:
        return CommissionStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case CommissionStatus.pending:
        return 'Pending';
      case CommissionStatus.settled:
        return 'Settled';
      case CommissionStatus.failed:
        return 'Failed';
    }
  }
}

class Settlement {
  final String id;
  final String providerId;
  final String providerType;
  final double amount;
  final SettlementMethod method;
  final String accountDetails;
  final SettlementStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Settlement({
    required this.id,
    required this.providerId,
    required this.providerType,
    required this.amount,
    required this.method,
    required this.accountDetails,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'] ?? '',
      providerId: json['provider_id'] ?? '',
      providerType: json['provider_type'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      method: SettlementMethod.fromString(json['settlement_method'] ?? 'mobile_money'),
      accountDetails: json['account_details'] ?? '',
      status: SettlementStatus.fromString(json['status'] ?? 'pending'),
      createdAt: json['created_at']?.toDate() ?? DateTime.now(),
      updatedAt: json['updated_at']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'provider_type': providerType,
      'amount': amount,
      'settlement_method': method.value,
      'account_details': accountDetails,
      'status': status.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

enum SettlementMethod {
  mobileMoney('mobile_money'),
  bankTransfer('bank_transfer');

  const SettlementMethod(this.value);
  final String value;

  static SettlementMethod fromString(String value) {
    switch (value) {
      case 'mobile_money':
        return SettlementMethod.mobileMoney;
      case 'bank_transfer':
        return SettlementMethod.bankTransfer;
      default:
        return SettlementMethod.mobileMoney;
    }
  }

  String get displayName {
    switch (this) {
      case SettlementMethod.mobileMoney:
        return 'Mobile Money';
      case SettlementMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }
}

class PaymentStatistics {
  final double totalPayments;
  final double totalAmount;
  final double totalCommission;
  final double totalProcessingFees;
  final double netRevenue;
  final Map<String, double> paymentsByMethod;
  final Map<String, int> paymentsByStatus;
  final double averageTransactionValue;
  final double successRate;
  final double refundRate;

  PaymentStatistics({
    required this.totalPayments,
    required this.totalAmount,
    required this.totalCommission,
    required this.totalProcessingFees,
    required this.netRevenue,
    required this.paymentsByMethod,
    required this.paymentsByStatus,
    required this.averageTransactionValue,
    required this.successRate,
    required this.refundRate,
  });

  factory PaymentStatistics.fromJson(Map<String, dynamic> json) {
    return PaymentStatistics(
      totalPayments: (json['total_payments'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      totalCommission: (json['total_commission'] ?? 0.0).toDouble(),
      totalProcessingFees: (json['total_processing_fees'] ?? 0.0).toDouble(),
      netRevenue: (json['net_revenue'] ?? 0.0).toDouble(),
      paymentsByMethod: Map<String, double>.from(json['payments_by_method'] ?? {}),
      paymentsByStatus: Map<String, int>.from(json['payments_by_status'] ?? {}),
      averageTransactionValue: (json['average_transaction_value'] ?? 0.0).toDouble(),
      successRate: (json['success_rate'] ?? 0.0).toDouble(),
      refundRate: (json['refund_rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_payments': totalPayments,
      'total_amount': totalAmount,
      'total_commission': totalCommission,
      'total_processing_fees': totalProcessingFees,
      'net_revenue': netRevenue,
      'payments_by_method': paymentsByMethod,
      'payments_by_status': paymentsByStatus,
      'average_transaction_value': averageTransactionValue,
      'success_rate': successRate,
      'refund_rate': refundRate,
    };
  }
}
