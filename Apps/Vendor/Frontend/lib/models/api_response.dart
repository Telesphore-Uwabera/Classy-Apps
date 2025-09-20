/// API Response model for consistent response handling
class ApiResponse {
  final int code;
  final String message;
  final Map<String, dynamic>? body;

  ApiResponse({
    required this.code,
    required this.message,
    this.body,
  });

  bool get isSuccess => code >= 200 && code < 300;

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] ?? json['status'] ?? 500,
      message: json['message'] ?? json['error'] ?? 'Unknown error',
      body: json['data'] ?? json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'body': body,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(code: $code, message: $message, body: $body)';
  }
}