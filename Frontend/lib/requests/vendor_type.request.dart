import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/services/location.service.dart';

class VendorTypeRequest extends HttpService {
  //
  Future<List<VendorType>> index() async {
    final params = {
      "latitude": await LocationService.getFetchByLocationLat(),
      "longitude": await LocationService.getFetchByLocationLng(),
    };
    print("params: $params");
    final apiResult = await get(
      Api.vendorTypes,
      queryParameters: params,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List)
          .map((e) => VendorType.fromJson(e))
          .toList();
    }

    throw apiResponse.message!;
  }
}
