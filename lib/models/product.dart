class Product {
  int id;
  String name;
  String description;
  num price; // Changed to num to handle both int and double
  int stock;
  String imageUrl;
  String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse price ensuring it's handled correctly whether int or double
    num parsedPrice = 0;
    final priceValue = json['price'];
    if (priceValue != null) {
      if (priceValue is num) {
        parsedPrice = priceValue;
      } else if (priceValue is String) {
        parsedPrice = num.tryParse(priceValue) ?? 0;
      }
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsedPrice,
      stock: json['stock'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
