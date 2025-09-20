class OrderAttachment {
  final String? id;
  final String? name;
  final String? url;
  final String? type;

  OrderAttachment({
    this.id,
    this.name,
    this.url,
    this.type,
  });

  factory OrderAttachment.fromJson(Map<String, dynamic> json) {
    return OrderAttachment(
      id: json['id']?.toString(),
      name: json['name'],
      url: json['url'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
    };
  }
}