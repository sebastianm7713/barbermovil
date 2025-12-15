import 'package:image_picker/image_picker.dart';

class Service {
  final int id;
  final String name;
  final int price;
  final XFile? imageFile; // imagen desde dispositivo
  final String? assetImage; // imagen por defecto

  Service({
    required this.id,
    required this.name,
    required this.price,
    this.imageFile,
    this.assetImage,
  });
}
