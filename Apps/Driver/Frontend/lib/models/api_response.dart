class ApiResponse {
  int get totalDataCount => (body is Map && body["meta"] is Map) ? (body["meta"]["total"] ?? 0) : 0;
  int get totalPageCount => (body is Map && body["pagination"] is Map) ? (body["pagination"]["total_pages"] ?? 0) : 0;
  List get data => (body is Map && body["data"] is List) ? body["data"] : [];
  // Just a way of saying there was no error with the request and response return
  bool get allGood => errors == null || errors?.length == 0;
  bool hasError() => errors != null && ((errors?.length ?? 0) > 0);
  bool hasData() => data.isNotEmpty;
  int? code;
  String? message;
  dynamic body;
  List? errors;

  ApiResponse({
    this.code,
    this.message,
    this.body,
    this.errors,
  });

  factory ApiResponse.fromResponse(dynamic response) {
    print("ApiResponse.fromResponse called with response: $response");
    print("Response type: ${response.runtimeType}");
    print("Response statusCode: ${response.statusCode}");
    print("Response data: ${response.data}");
    
    //
    int code = response.statusCode;
    dynamic body = response.data ?? null; // Would mostly be a Map
    List errors = [];
    String message = "";

    print("Processing response - code: $code, body type: ${body.runtimeType}");

    switch (code) {
      case 200:
        try {
          if (body is Map && body.containsKey("message")) {
            message = body["message"] ?? "";
          } else if (body is String) {
            message = body;
          } else if (body is Map) {
            message = body["message"] ?? "";
          } else {
            message = "Success";
          }
        } catch (error) {
          print("Message reading error ==> $error");
          message = "Success";
        }

        break;
      default:
        try {
          if (body is Map && body.containsKey("message")) {
            message = body["message"] ?? "Whoops! Something went wrong, please contact support.";
          } else {
            message = "Whoops! Something went wrong, please contact support.";
          }
          errors.add(message);
        } catch (error) {
          print("Error processing error response ==> $error");
          message = "Whoops! Something went wrong, please contact support.";
          errors.add(message);
        }
        break;
    }

    print("Final ApiResponse - code: $code, message: $message, errors: $errors");
    
    return ApiResponse(
      code: code,
      message: message,
      body: body,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{code: $code, message: $message, body: $body, errors: $errors}';
  }
}
