import 'package:image_picker/image_picker.dart';

class Service {
  final int id;
  final String name;
  final int price;
  final String description;
  final int duration;
  final String imageUrl;
  final XFile? imageFile;      // imagen subida
  final String? assetImage;    // imagen fija desde assets

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.duration,
    required this.imageUrl,
    this.imageFile,
    this.assetImage,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'] ?? '',
      duration: json['duration'] ?? 30,
      imageUrl: json['imageUrl'] ?? '',
      imageFile: json['imageFile'],
      assetImage: json['assetImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'duration': duration,
      'imageUrl': imageUrl,
      'imageFile': imageFile,
      'assetImage': assetImage,
    };
  }
}
