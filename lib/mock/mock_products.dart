import '../models/product.dart';

final List<Product> mockProducts = [
  Product(
    id: 1,
    name: "Cera para cabello",
    description: "Fijación media con acabado natural",
    price: 18000,
    stock: 10,
    imageUrl: "assets/images/products/cera.png",
    category: "Cabello",
  ),
  Product(
    id: 2,
    name: "shampoo",
    description: "Nutre y suaviza el cabello",
    price: 22000,
    stock: 8,
    imageUrl: "assets/images/products/shampoo.jpg",
    category: "Barba",
  ),
];
