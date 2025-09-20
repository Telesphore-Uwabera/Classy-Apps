// Conditional export: use web implementation on web, mobile implementation otherwise
export 'mobile_location.service.dart' if (dart.library.html) 'web_location.service.dart';


