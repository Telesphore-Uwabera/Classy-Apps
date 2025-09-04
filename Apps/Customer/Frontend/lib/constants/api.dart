// Firebase-only API configuration - No Laravel backend
import 'package:flutter/foundation.dart';

class Api {
  // ===== FIREBASE CONFIGURATION =====
  static const bool useMockData = false;
  
  // ===== FIREBASE BACKEND =====
  static String get baseUrl {
    return "firebase://classyapp-unified-backend";
  }
  
  static bool get isDevelopment => false;
  
  static String get apiStatus {
    return "Firebase Mode - Connected to Firebase Backend";
  }

  // ===== FIRESTORE COLLECTIONS =====
  static const String usersCollection = "users";
  static const String driversCollection = "drivers";
  static const String vendorsCollection = "vendors";
  static const String ordersCollection = "orders";
  static const String productsCollection = "products";
  static const String categoriesCollection = "categories";
  static const String servicesCollection = "services";
  static const String reviewsCollection = "reviews";
  static const String notificationsCollection = "notifications";
  static const String addressesCollection = "addresses";
  static const String paymentMethodsCollection = "payment_methods";
  static const String couponsCollection = "coupons";
  static const String bannersCollection = "banners";
  static const String settingsCollection = "settings";
  static const String faqsCollection = "faqs";
  
  // ===== FIREBASE COMPATIBLE ENDPOINTS =====
  // These are now handled by FirebaseRequest.handleRequest()
  static const String orders = "orders";
  static const String products = "products";
  static const String vendors = "vendors";
  static const String categories = "categories";
  static const String services = "services";
  static const String cart = "cart";
  static const String paymentMethods = "paymentMethods";
  static const String coupons = "coupons";
  static const String banners = "banners";
  static const String favourites = "favourites";
  static const String search = "search";
  static const String tags = "tags";
  static const String walletBalance = "walletBalance";
  static const String walletTransactions = "walletTransactions";
  static const String loyaltyPoints = "loyaltyPoints";
  static const String flashSales = "flashSales";
  static const String packageTypes = "packageTypes";
  static const String vendorTypes = "vendorTypes";
  static const String reviews = "reviews";
  static const String notifications = "notifications";
  static const String chat = "chat";
  static const String deliveryAddresses = "deliveryAddresses";
  static const String deliveryHistory = "deliveryHistory";
  static const String rideHistory = "rideHistory";
  static const String foodCategories = "foodCategories";
  static const String topPicks = "topPicks";
  static const String foodSearch = "foodSearch";
  static const String paymentAccounts = "paymentAccounts";
  static const String geocoderForward = "geocoderForward";
  static const String geocoderReserve = "geocoderReserve";
  static const String geocoderPlaceDetails = "geocoderPlaceDetails";
  static const String externalRedirect = "externalRedirect";
  static const String cancellationReasons = "cancellationReasons";
  static const String syncDriverLocation = "syncDriverLocation";
  static const String trackOrder = "trackOrder";
  static const String placeOrder = "placeOrder";
  static const String bestProducts = "bestProducts";
  static const String forYouProducts = "forYouProducts";
  static const String productReviews = "productReviews";
  static const String productReviewSummary = "productReviewSummary";
  static const String productBoughtFrequent = "productBoughtFrequent";
  static const String vendorReviews = "vendorReviews";
  static const String topVendors = "topVendors";
  static const String bestVendors = "bestVendors";
  static const String packageVendors = "packageVendors";
  static const String rating = "rating";
  static const String searchData = "searchData";
  static const String favouriteVendors = "favouriteVendors";
  static const String myWalletAddress = "myWalletAddress";
  static const String walletAddressesSearch = "walletAddressesSearch";
  static const String walletTopUp = "walletTopUp";
  static const String walletTransfer = "walletTransfer";
  static const String myLoyaltyPoints = "myLoyaltyPoints";
  static const String loyaltyPointsReport = "loyaltyPointsReport";
  static const String loyaltyPointsWithdraw = "loyaltyPointsWithdraw";
  static const String packageVendorPricings = "packageVendorPricings";
  static const String packageVendorAreaOfOperations = "packageVendorAreaOfOperations";
  static const String packageOrderSummary = "packageOrderSummary";
  static const String generalOrderDeliveryFeeSummary = "generalOrderDeliveryFeeSummary";
  static const String generalOrderSummary = "generalOrderSummary";
  static const String serviceOrderSummary = "serviceOrderSummary";
  
  // ===== FIREBASE AUTH METHODS =====
  static const String authMethod = "firebase_auth";
  static const String storageMethod = "firebase_storage";
  static const String databaseMethod = "firestore";
  
  // ===== FIREBASE CONFIGURATION =====
  static const String firebaseProjectId = "classyapp-unified-backend";
  static const String firebaseStorageBucket = "classyapp-unified-backend.appspot.com";
  static const String firebaseDatabaseUrl = "https://classyapp-unified-backend.firebaseio.com";
}