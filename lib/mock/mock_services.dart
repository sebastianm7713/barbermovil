import '../models/service.dart';

final List<Service> mockServices = [
  Service(
    id: 1,
    name: "Corte",
    price: 28000,
    assetImage: "assets/images/services/corte.jpg",
    description: "Corte de cabello clásico o moderno con tijera y máquina.",
    duration: 30,
  ),
  Service(
    id: 2,
    name: "Corte + Barba",
    price: 38000,
    assetImage: "assets/images/services/corte_barba.jpg",
    description: "Servicio completo de corte de cabello y perfilado de barba con toalla caliente.",
    duration: 50,
  ),
  Service(
    id: 3,
    name: "Perfilado",
    price: 12000,
    assetImage: "assets/images/services/perfilada.jpg",
    description: "Perfilado de barba y cejas para un acabado perfecto.",
    duration: 15,
  ),
];
