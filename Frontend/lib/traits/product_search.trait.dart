import 'package:Classy/enums/product_fetch_data_type.enum.dart';
import 'package:Classy/extensions/context.dart';
import 'package:Classy/models/category.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/views/pages/search/products.page.dart';

mixin ProductSearchTrait {
  Future<void> openProductsSeeAllPage({
    required String title,
    ProductFetchDataType type = ProductFetchDataType.RANDOM,
    VendorType? vendorType,
    Category? category,
    bool showGrid = true,
  }) async {
    final context = AppService().navigatorKey.currentContext;
    context!.push((context) {
      return ProducsPage(
        title: title,
        vendorType: vendorType,
        type: type,
        category: category,
        showGrid: showGrid,
      );
    });
  }
}
