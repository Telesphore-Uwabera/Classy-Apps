import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:Classy/constants/api.dart';
import 'package:Classy/constants/app_dynamic_link.dart';
import 'package:Classy/constants/app_map_settings.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/cart.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/models/product.dart';
import 'package:Classy/models/search.dart';
import 'package:Classy/models/service.dart';
import 'package:Classy/models/vendor.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/cart.service.dart';
import 'package:Classy/services/cart_ui.service.dart';
import 'package:Classy/services/geocoder.service.dart';
import 'package:Classy/services/location.service.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/services/toast.service.dart';
import 'package:Classy/services/update.service.dart';
import 'package:Classy/traits/product_search.trait.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/view_models/payment.view_model.dart';
import 'package:Classy/views/pages/auth/login.page.dart';
import 'package:Classy/views/pages/cart/cart.page.dart';
import 'package:Classy/views/pages/service/service_details.page.dart';
import 'package:Classy/views/pages/vendor/vendor_reviews.page.dart';
import 'package:Classy/views/shared/ops_map.page.dart';
import 'package:Classy/widgets/bottomsheets/delivery_address_picker.bottomsheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/extensions/context.dart';

class MyBaseViewModel extends BaseViewModel
    with UpdateService, ProductSearchTrait {
  //
  late BuildContext viewContext;
  GlobalKey pageKey = GlobalKey<State>();
  final formKey = GlobalKey<FormState>();
  final formBuilderKey = GlobalKey<FormBuilderState>();
  GlobalKey genKey = GlobalKey();
  final currencySymbol = AppStrings.currencySymbol;
  DeliveryAddress? deliveryaddress = DeliveryAddress();
  String? firebaseVerificationId;
  VendorType? vendorType;
  Vendor? vendor;
  RefreshController refreshController = RefreshController();

  void initialise() {}

  void reloadPage() {
    pageKey = new GlobalKey<State>();
    refreshController = new RefreshController();
    notifyListeners();
    initialise();
  }

  openWebpageLink(String url) async {
    PaymentViewModel paymentViewModel = PaymentViewModel();
    paymentViewModel.viewContext = viewContext;
    await paymentViewModel.openWebpageLink(url);
  }

  //
  //open delivery address picker
  void pickDeliveryAddress({
    bool vendorCheckRequired = true,
    Function? onselected,
  }) {
    //
    showModalBottomSheet(
      context: viewContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DeliveryAddressPicker(
          vendorCheckRequired: vendorCheckRequired,
          allowOnMap: true,
          onSelectDeliveryAddress: (mDeliveryaddress) async {
            print("called here");
            viewContext.pop();
            deliveryaddress = mDeliveryaddress;
            await LocationService.saveSelectedAddressLocally(mDeliveryaddress);
            notifyListeners();

            //
            final address = Address(
              coordinates: Coordinates(
                deliveryaddress?.latitude ?? 0.00,
                deliveryaddress?.longitude ?? 0.00,
              ),
              addressLine: deliveryaddress?.address,
            );
            //
            LocationService.currenctAddress = address;
            //
            LocationService.currenctAddressSubject.sink.add(address);

            //
            if (onselected != null) onselected();
          },
        );
      },
    );
  }

  //
  bool isAuthenticated() {
    return AuthServices.authenticated();
  }

  //
  void openLogin() async {
    viewContext.nextPage(LoginPage());
    notifyListeners();
  }

  openTerms() {
    final url = "https://classy.app/terms";
    openWebpageLink(url);
  }

  openPaymentTerms() {
    final url = "https://classy.app/payment-terms";
    openWebpageLink(url);
  }

  //
  //
  Future<DeliveryAddress?> showDeliveryAddressPicker() async {
    //
    DeliveryAddress? selectedDeliveryAddress;

    // Use Google Maps PlacePicker instead of list
    try {
      final result = await newPlacePicker();
      if (result != null) {
        // Convert PlacePicker result to DeliveryAddress
        selectedDeliveryAddress = DeliveryAddress(
          name: result.formattedAddress ?? "Selected Location",
          address: result.formattedAddress ?? "Selected Location",
          latitude: result.geometry?.location.lat ?? 0.0,
          longitude: result.geometry?.location.lng ?? 0.0,
        );
      }
    } catch (error) {
      print("Error with Google Maps picker: $error");
      // Fallback to list if Google Maps fails
      await showModalBottomSheet(
        context: viewContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DeliveryAddressPicker(
            allowOnMap: true, // Enable map option in fallback
            onSelectDeliveryAddress: (deliveryAddress) {
              viewContext.pop();
              selectedDeliveryAddress = deliveryAddress;
            },
          );
        },
      );
    }

    return selectedDeliveryAddress;
  }

  //
  Future<DeliveryAddress> getLocationCityName(
    DeliveryAddress deliveryAddress,
  ) async {
    final coordinates = new Coordinates(
      deliveryAddress.latitude ?? 0.00,
      deliveryAddress.longitude ?? 0.00,
    );
    final addresses = await GeocoderService().findAddressesFromCoordinates(
      coordinates,
    );
    //loop through the addresses and get data
    for (var address in addresses) {
      //address
      deliveryAddress.address ??= address.addressLine;
      //name
      if (deliveryAddress.name.isEmptyOrNull) {
        deliveryAddress.name = address.featureName;
      }
      if (deliveryAddress.name.isEmptyOrNull) {
        deliveryAddress.name = address.addressLine;
      }
      //city
      if (deliveryAddress.city.isEmptyOrNull) {
        deliveryAddress.city = address.subLocality;
      }
      //state
      if (deliveryAddress.state.isEmptyOrNull) {
        deliveryAddress.state = address.subAdminArea;
      }
      //country
      if (deliveryAddress.country.isEmptyOrNull) {
        deliveryAddress.country = address.countryName;
      }

      //break if all data is set
      if (deliveryAddress.address != null &&
          deliveryAddress.city != null &&
          deliveryAddress.state != null &&
          deliveryAddress.country != null) {
        break;
      }
    }
    //
    // deliveryAddress.city = addresses.first.locality;
    // deliveryAddress.state = addresses.first.adminArea;
    // deliveryAddress.country = addresses.first.countryName;
    return deliveryAddress;
  }

  addToCartDirectly(Product product, int qty, {bool force = false}) async {
    //
    if (qty <= 0) {
      //
      final mProductsInCart = CartServices.productsInCart;
      final previousProductIndex = mProductsInCart.indexWhere(
        (e) => e.product?.id == product.id,
      );
      //
      if (previousProductIndex >= 0) {
        mProductsInCart.removeAt(previousProductIndex);
        await CartServices.saveCartItems(mProductsInCart);
      }
      return;
    }
    //
    final cart = Cart();
    cart.price = (product.showDiscount ? product.discountPrice : product.price);
    product.selectedQty = qty;
    cart.product = product;
    cart.selectedQty = product.selectedQty;
    cart.options = product.selectedOptions ?? [];
    cart.optionsIds = product.selectedOptions!.map((e) => e.id).toList();

    //

    try {
      //
      bool canAddToCart = await CartUIServices.handleCartEntry(
        viewContext,
        cart,
        product,
      );

      if (canAddToCart || force) {
        //
        final mProductsInCart = CartServices.productsInCart;
        final previousProductIndex = mProductsInCart.indexWhere(
          (e) => e.product?.id == product.id,
        );
        //
        if (previousProductIndex >= 0) {
          mProductsInCart.removeAt(previousProductIndex);
          mProductsInCart.insert(previousProductIndex, cart);
          await CartServices.saveCartItems(mProductsInCart);
        } else {
          await CartServices.addToCart(cart);
        }
      } else if (product.isDigital) {
        //
        AlertService.confirm(
          title: "Digital Product".tr(),
          text:
              "You can only buy/purchase digital products together with other digital products. Do you want to clear cart and add this product?"
                  .tr(),
          onConfirm: () async {
            await CartServices.clearCart();
            addToCartDirectly(product, qty, force: true);
          },
        );
      } else {
        //
        AlertService.confirm(
          title: "Different Vendor".tr(),
          text:
              "Are you sure you'd like to change vendors? Your current items in cart will be lost."
                  .tr(),
          onConfirm: () async {
            await CartServices.clearCart();
            addToCartDirectly(product, qty, force: true);
          },
        );
      }
    } catch (error) {
      print("Cart Error => $error");
      setError(error);
    }
  }

  //switch to use current location instead of selected delivery address
  void useUserLocation() {
    LocationService.geocodeCurrentLocation();
  }

  //
  openSearch({int showType = 4}) async {
    final search = Search(
      vendorType: vendorType,
      showProductsTag: Search.showProductByShowType(showType),
      showServicesTag: Search.showServiceByShowType(showType),
      showProvidesTag: Search.showProvidersByShowType(showType),
      showVendorsTag: Search.showVendorByShowType(showType),

      // showType:showType,
    );
    final page = NavigationService().searchPageWidget(search);
    viewContext.nextPage(page);
  }

  openCart() async {
    viewContext.nextPage(CartPage());
  }

  //
  //
  productSelected(Product product) async {
    Navigator.pushNamed(viewContext, AppRoutes.product, arguments: product);
  }

  servicePressed(Service service) async {
    viewContext.push((context) => ServiceDetailsPage(service));
  }

  openVendorReviews() {
    viewContext.push((context) => VendorReviewsPage(vendor!));
  }

  //show toast
  toastSuccessful(String msg, {String? title}) {
    ToastService.toastSuccessful(msg, title: title);
  }

  toastError(String msg, {String? title}) {
    ToastService.toastError(msg, title: title);
  }

  Future<void> fetchCurrentLocation() async {
    //
    Position currentLocation = await Geolocator.getCurrentPosition();
    //
    final address = await LocationService.addressFromCoordinates(
      lat: currentLocation.latitude,
      lng: currentLocation.longitude,
    );
    //
    LocationService.currenctAddress = address;
    if (address != null) {
      LocationService.currenctAddressSubject.sink.add(address);
    }
    deliveryaddress ??= DeliveryAddress();
    deliveryaddress!.address = address?.addressLine;
    deliveryaddress!.latitude = address?.coordinates?.latitude;
    deliveryaddress!.longitude = address?.coordinates?.longitude;
    deliveryaddress!.name = "Current Location".tr();
    LocationService.deliveryaddress = deliveryaddress;
    LocationService.currenctDeliveryAddressSubject.add(deliveryaddress!);
  }

  //handle fetch delivery address
  preloadDeliveryLocation() async {
    try {
      //fetch saved location from local storage
      deliveryaddress = LocationService.deliveryaddress;
      if (deliveryaddress == null) {
        deliveryaddress = await LocationService.getLocallySaveAddress();
      }
      notifyListeners();
    } catch (error) {
      print("Error getting delivery address => $error");
    }
  }

  // NEW LOCATION PICKER
  Future<dynamic> newPlacePicker() async {
    //
    LatLng initialPosition = LatLng(0.00, 0.00);
    double initialZoom = 0;
    if (LocationService.currenctAddress != null) {
      initialPosition = LatLng(
        LocationService.currenctAddress?.coordinates?.latitude ?? 0.00,
        LocationService.currenctAddress?.coordinates?.longitude ?? 0.00,
      );
      initialZoom = 15;
    }
    String? mapRegion;
    try {
      mapRegion = await Utils.getCurrentCountryCode();
    } catch (error) {
      print("Error getting sim country code => $error");
    }
    mapRegion ??= AppStrings.countryCode ?? "US";

    //
    if (!AppMapSettings.useGoogleOnApp) {
      return await viewContext.push(
        (context) => OPSMapPage(
          region: mapRegion,
          initialPosition: initialPosition,
          useCurrentLocation: true,
          initialZoom: initialZoom,
        ),
      );
    }
    //google maps
    return await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder:
            (context) => PlacePicker(
              apiKey: AppStrings.googleMapApiKey,
              autocompleteLanguage: translator.activeLocale?.languageCode ?? "en",
              region: mapRegion,
              onPlacePicked: (result) {
                Navigator.of(context).pop(result);
              },
              initialPosition: initialPosition,
            ),
      ),
    );
  }

  //share
  shareProduct(Product product) async {
    //
    setBusyForObject(shareProduct, true);
    String link = "https://classy.app/product/${product.id}";
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(link),
      uriPrefix: AppDynamicLink.dynamicLinkPrefix,
      androidParameters: AndroidParameters(
        packageName: await AppDynamicLink.androidDynamicLinkId,
      ),
      iosParameters: IOSParameters(
        bundleId: await AppDynamicLink.iOSDynamicLinkId,
      ),
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildLink(
      dynamicLinkParams,
    );

    String shareLink = Uri.decodeFull(
      Uri.decodeComponent(dynamicLink.toString()),
    );
    await Share.share(shareLink);
    setBusyForObject(shareProduct, false);
  }

  shareVendor(Vendor vendor) async {
    //
    setBusyForObject(shareVendor, true);
    String link = "https://classy.app/vendor/${vendor.id}";
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(link),
      uriPrefix: AppDynamicLink.dynamicLinkPrefix,
      androidParameters: AndroidParameters(
        packageName: await AppDynamicLink.androidDynamicLinkId,
      ),
      iosParameters: IOSParameters(
        bundleId: await AppDynamicLink.iOSDynamicLinkId,
      ),
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildLink(
      dynamicLinkParams,
    );

    String shareLink = Uri.decodeFull(
      Uri.decodeComponent(dynamicLink.toString()),
    );
    await Share.share(shareLink);
    setBusyForObject(shareVendor, false);
  }

  shareService(Service service) async {
    //
    setBusyForObject(shareService, true);
    String link = "https://classy.app/service/${service.id}";
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(link),
      uriPrefix: AppDynamicLink.dynamicLinkPrefix,
      androidParameters: AndroidParameters(
        packageName: await AppDynamicLink.androidDynamicLinkId,
      ),
      iosParameters: IOSParameters(
        bundleId: await AppDynamicLink.iOSDynamicLinkId,
      ),
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildLink(
      dynamicLinkParams,
    );

    String shareLink = Uri.decodeFull(
      Uri.decodeComponent(dynamicLink.toString()),
    );
    await Share.share(shareLink);
    setBusyForObject(shareService, false);
  }
}
