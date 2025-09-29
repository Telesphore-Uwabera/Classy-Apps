class ApiResponse {
  int get totalDataCount => body["meta"]["total"];
  int get totalPageCount => body["pagination"]["total_pages"];
  List get data => body["data"] ?? [];
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
    //
    int code = response.statusCode;
    dynamic body = response.data ?? null; // Would mostly be a Map
    List errors = [];
    String message = "";

    // Debug logging
    print("API Response - Status: $code, Body: $body");

    switch (code) {
      case 200:
      case 201:
        try {
          message = body is Map ? (body["message"] ?? "Success") : "Success";
          // Check if body has user data for registration
          if (body is Map && body["user"] != null) {
            print("User data found in response: ${body["user"]}");
          }
          if (body is Map && body["token"] != null) {
            print("Token found in response");
          }
          if (body is Map && body["fb_token"] != null) {
            print("Firebase token found in response");
          }
        } catch (error) {
          print("Message reading error ==> $error");
        }
        break;
      default:
        message = body is Map ? (body["message"] ?? "Whoops! Something went wrong, please contact support.") : "Whoops! Something went wrong, please contact support.";
        errors.add(message);
        break;
    }

    return ApiResponse(
      code: code,
      message: message,
      body: body,
      errors: errors,
    );
  }
}
