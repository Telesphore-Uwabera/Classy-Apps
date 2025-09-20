import 'dart:convert';
import 'package:random_string/random_string.dart';
import 'vendor.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.capacity,
    required this.unit,
    required this.packageCount,
    required this.featured,
    required this.isFavourite,
    required this.deliverable,
    required this.isActive,
    required this.vendorId,
    required this.categoryId,
    required this.formattedDate,
    required this.photo,
    required this.vendor,
    this.availableQty,
    this.selectedQty = 0,
    this.tags = const [],
    this.categories = const [],
    this.photos = const [],
  }) {
    this.heroTag = randomAlphaNumeric(15) + "$id";
  }

  int id;
  String? heroTag;
  String name;
  String? description;
  double price;
  double discountPrice;
  String? capacity;
  String? unit;
  String? packageCount;
  int featured;
  bool isFavourite;
  int deliverable;
  int isActive;
  int vendorId;
  int? categoryId;
  String formattedDate;
  String photo;
  Vendor? vendor;
  List<String> photos = [];
  List<String> categories = [];
  List<String> tags = [];
  int? stock;
  String? status;
  String? categoryName;

  //
  int? availableQty;
  int selectedQty;
  
  // Additional properties for compatibility
  int get stockValue => availableQty ?? 0;
  String get statusValue => isActive == 1 ? 'active' : 'inactive';
  String get categoryNameValue => categories.isNotEmpty ? categories.first : 'Uncategorized';
  List<String> get images => photos;

  factory Product.fromJson(Map<String, dynamic> json) {
    // log("Products ==> ${jsonEncode(json)}");
    return Product(
      id: json["id"] == null ? null : json["id"],
      name: json["name"] == null ? null : json["name"],
      description: json["description"] == null ? "" : json["description"],
      price: double.parse(json["price"].toString()),
      discountPrice: json["discount_price"] == null
          ? 0
          : double.parse(json["discount_price"].toString()),
      capacity: json["capacity"] == null ? null : json["capacity"].toString(),
      unit: json["unit"] == null ? null : json["unit"],
      packageCount: json["package_count"] == null
          ? null
          : json["package_count"].toString(),
      featured:
          json["featured"] == null ? 0 : int.parse(json["featured"].toString()),
      isFavourite: json["is_favourite"] == null ? null : json["is_favourite"],
      deliverable: json["deliverable"] == null
          ? 0
          : int.parse(json["deliverable"].toString()),
      isActive: json["is_active"] == null
          ? 0
          : int.parse(json["is_active"].toString()),
      vendorId: int.parse(json["vendor_id"].toString()),
      categoryId: json["category_id"] == null ? null : json["category_id"],

      formattedDate:
          json["formatted_date"] == null ? null : json["formatted_date"],
      photo: json["photo"] == null ? null : json["photo"],
      vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
      categories: json["categories"] == null
          ? []
          : List<String>.from(json["categories"].map((x) => x.toString())),
      tags: json["tags"] == null
          ? []
          : List<String>.from(json["tags"].map((x) => x.toString())),
      photos: json["photos"] == null
          ? []
          : List<String>.from(json["photos"].map((x) => x.toString())),
      //
      availableQty: json["available_qty"] == null
          ? null
          : int.parse(json["available_qty"].toString()),
      selectedQty: json["selected_qty"] == null
          ? 0
          : int.tryParse(json["selected_qty"].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "discount_price": discountPrice,
        "capacity": capacity,
        "unit": unit,
        "package_count": packageCount,
        "featured": featured,
        "is_favourite": isFavourite,
        "deliverable": deliverable,
        "is_active": isActive,
        "vendor_id": vendorId,
        "category_id": categoryId,
        "formatted_date": formattedDate,
        "photo": photo,
        "vendor": vendor == null ? null : vendor?.toJson(),
        "categories": categories,
        "tags": tags,
        "photos": images,
        "available_qty": availableQty == null ? null : availableQty,
        "selected_qty": selectedQty,
      };

  //getters
  get showDiscount => discountPrice > 0.00;
  get canBeDelivered => deliverable == 1;
  double get sellPrice {
    if (showDiscount) {
      return discountPrice;
    }
    return price;
  }

  // Additional methods for compatibility
  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product.fromJson(map);
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? capacity,
    String? unit,
    String? packageCount,
    int? featured,
    bool? isFavourite,
    int? deliverable,
    int? isActive,
    int? vendorId,
    int? categoryId,
    String? formattedDate,
    String? photo,
    Vendor? vendor,
    List<String>? categories,
    List<String>? tags,
    List<String>? images,
    int? availableQty,
    int? selectedQty,
    String? status,
    String? categoryName,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      capacity: capacity ?? this.capacity,
      unit: unit ?? this.unit,
      packageCount: packageCount ?? this.packageCount,
      featured: featured ?? this.featured,
      isFavourite: isFavourite ?? this.isFavourite,
      deliverable: deliverable ?? this.deliverable,
      isActive: isActive ?? this.isActive,
      vendorId: vendorId ?? this.vendorId,
      categoryId: categoryId ?? this.categoryId,
      formattedDate: formattedDate ?? this.formattedDate,
      photo: photo ?? this.photo,
      vendor: vendor ?? this.vendor,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      photos: photos ?? this.photos,
      availableQty: availableQty ?? this.availableQty,
      selectedQty: selectedQty ?? this.selectedQty,
      // status: status ?? this.status,
      // categoryName: categoryName ?? this.categoryName,
    );
  }
}
