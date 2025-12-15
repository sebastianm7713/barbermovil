class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
  });

  // Convertir JSON a modelo
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: (json["price"] as num).toDouble(),
        stock: json["stock"],
        imageUrl: json["imageUrl"] ?? "",
        category: json["category"],
      );

  // Convertir modelo a JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "stock": stock,
        "imageUrl": imageUrl,
        "category": category,
      };
}
