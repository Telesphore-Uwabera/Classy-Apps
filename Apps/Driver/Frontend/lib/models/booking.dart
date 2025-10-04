class BookingRequest {
  final String id;
  final String customerName;
  final String customerPhone;
  final double customerRating;
  final String serviceType;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final double distance;
  final int estimatedDuration;
  final double estimatedFare;
  final DateTime requestTime;

  BookingRequest({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerRating,
    required this.serviceType,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.distance,
    required this.estimatedDuration,
    required this.estimatedFare,
    required this.requestTime,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerRating: (json['customerRating'] ?? 0.0).toDouble(),
      serviceType: json['serviceType'] ?? '',
      pickupAddress: json['pickupAddress'] ?? '',
      pickupLatitude: (json['pickupLatitude'] ?? 0.0).toDouble(),
      pickupLongitude: (json['pickupLongitude'] ?? 0.0).toDouble(),
      destinationAddress: json['destinationAddress'] ?? '',
      destinationLatitude: (json['destinationLatitude'] ?? 0.0).toDouble(),
      destinationLongitude: (json['destinationLongitude'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      estimatedFare: (json['estimatedFare'] ?? 0.0).toDouble(),
      requestTime: DateTime.parse(json['requestTime'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerRating': customerRating,
      'serviceType': serviceType,
      'pickupAddress': pickupAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationAddress': destinationAddress,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'estimatedFare': estimatedFare,
      'requestTime': requestTime.toIso8601String(),
    };
  }
}

