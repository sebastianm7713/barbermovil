import 'package:image_picker/image_picker.dart';

class Product {
  int id;
  String name;
  String description;
  int price;
  int stock;
  String provider;
  XFile? imageFile;      // 📷 imagen desde dispositivo
  String? assetImage;   // 🖼️ imagen desde assets

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.provider,
    this.imageFile,
    this.assetImage,
  });
}

final List<Product> mockProducts = [
  Product(
    id: 1,
    name: "Gomina",
    description: "Gomina fijación fuerte",
    price: 12000,
    stock: 20,
    provider: "BarberPro",
    assetImage: "assets/images/products/gomina.png",
  ),
  Product(
    id: 2,
    name: "Cera",
    description: "Cera efecto mate",
    price: 15000,
    stock: 15,
    provider: "BarberPro",
    assetImage: "images/products/cera.png",
  ),
  Product(
    id: 3,
    name: "Shampoo",
    description: "Shampoo para barba",
    price: 18000,
    stock: 10,
    provider: "HairCare",
    assetImage: "images/products/shampoo.jpg",
  ),
  Product(
    id: 4,
    name: "Gaseosa",
    description: "Bebida fría",
    price: 5000,
    stock: 30,
    provider: "Coca-Cola",
    assetImage: "images/products/gaseosa.png",
  ),
];
