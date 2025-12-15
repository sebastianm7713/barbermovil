class BarberClient {
  final int id;
  final String name;

  BarberClient({required this.id, required this.name});
}

final List<BarberClient> mockBarberClients = [
  BarberClient(id: 1, name: "Sebastián"),
  BarberClient(id: 2, name: "Miguel"),
  BarberClient(id: 3, name: "Joseph"),
  BarberClient(id: 4, name: "Valentina"),
];
