import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/models/loyalty_point.dart';
import 'package:Classy/models/loyalty_point_report.dart';
import 'package:Classy/services/http.service.dart';

class LoyaltyPointRequest extends HttpService {
  //
  Future<LoyaltyPoint> getLoyaltyPoint() async {
    final apiResult = await get(Api.myLoyaltyPoints);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return LoyaltyPoint.fromJson(apiResponse.body);
    }

    throw apiResponse.message!;
  }

  Future<List<LoyaltyPointReport>> loyaltyPointReports({int page = 1}) async {
    final apiResult = await get(
      Api.loyaltyPointsReport,
      queryParameters: {
        "page": page,
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body["data"] as List)
          .map((e) => LoyaltyPointReport.fromJson(e))
          .toList();
    }

    throw apiResponse.message!;
  }

  Future<ApiResponse> withdrawPoints(
    String points,
  ) async {
    final apiResult = await post(
      Api.loyaltyPointsWithdraw,
      {
        "points": points,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }
}
