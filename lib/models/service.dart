import 'package:image_picker/image_picker.dart';

class Service {
  final int id;
  final String name;
  final int price;
  final XFile? imageFile;      // imagen subida
  final String? assetImage;    // imagen fija desde assets
  final String description;
  final int duration; // en minutos

  Service({
    required this.id,
    required this.name,
    required this.price,
    this.imageFile,
    this.assetImage,
    this.description = '',
    this.duration = 30,
  });
}
