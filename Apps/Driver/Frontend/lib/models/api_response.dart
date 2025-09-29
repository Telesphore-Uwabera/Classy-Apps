class ApiResponse {
  final int code;
  final String message;
  final dynamic body;
  final List<String>? errors;

  ApiResponse({
    required this.code,
    required this.message,
    this.body,
    this.errors,
  });

  // Factory constructor for creating from HTTP response
  factory ApiResponse.fromResponse(dynamic response) {
    return ApiResponse(
      code: response.statusCode ?? 200,
      message: response.data?['message'] ?? 'Success',
      body: response.data,
      errors: response.data?['errors'] != null 
          ? List<String>.from(response.data['errors']) 
          : null,
    );
  }

  bool hasError() {
    return code != 200;
  }

  bool isSuccess() {
    return code == 200;
  }

  bool get allGood => isSuccess();

  @override
  String toString() {
    return 'ApiResponse(code: $code, message: $message, body: $body, errors: $errors)';
  }
}