class OrderProduct {
  final String? id;
  final String? productId;
  final String? productName;
  final int? quantity;
  final double? price;
  final double? total;
  final Product? product;

  OrderProduct({
    this.id,
    this.productId,
    this.productName,
    this.quantity,
    this.price,
    this.total,
    this.product,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id']?.toString(),
      productId: json['product_id']?.toString(),
      productName: json['product_name'],
      quantity: json['quantity'],
      price: json['price']?.toDouble(),
      total: json['total']?.toDouble(),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
      'product': product?.toJson(),
    };
  }
}

class Product {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final String? image;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }
}