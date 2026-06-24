import 'api_service.dart';

class ClienteService {
  final ApiService _apiService = ApiService();

  /// Obtener todos los clientes
  Future<List<Map<String, dynamic>>> getAllClientes() async {
    try {
      final data = await _apiService.getClientes();
      return (data as List)
          .map((clienteJson) => _mapBackendToFrontend(clienteJson))
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  /// Obtener cliente por ID
  Future<Map<String, dynamic>?> getClienteById(int id) async {
    try {
      final data = await _apiService.getClienteById(id);
      return _mapBackendToFrontend(data);
    } catch (e) {
      return null;
    }
  }

  /// Crear cliente
  Future<Map<String, dynamic>?> createCliente(Map<String, dynamic> cliente) async {
    try {
      final response = await _apiService.createCliente({
        'nombre': cliente['nombre'] ?? '',
        'apellido': cliente['apellido'] ?? '',
        'telefono': cliente['telefono'] ?? '',
        'correo': cliente['correo'] ?? '',
        'tipo_documento': cliente['tipo_documento'] ?? 'CC',
        'numero_documento': cliente['numero_documento'] ?? '',
        'genero': cliente['genero'] ?? '',
        'fecha_nacimiento': cliente['fecha_nacimiento'] ?? '',
      });

      final data = response['data'] ?? response;
      return _mapBackendToFrontend(data);
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  /// Actualizar cliente
  Future<bool> updateCliente(int id, Map<String, dynamic> cliente) async {
    try {
      await _apiService.updateCliente(id, {
        'nombre': cliente['nombre'] ?? '',
        'apellido': cliente['apellido'] ?? '',
        'telefono': cliente['telefono'] ?? '',
        'correo': cliente['correo'] ?? '',
        'genero': cliente['genero'] ?? '',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar cliente
  Future<bool> deleteCliente(int id) async {
    try {
      await _apiService.deleteCliente(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mapear estructura del backend
  Map<String, dynamic> _mapBackendToFrontend(dynamic backendData) {
    if (backendData is Map<String, dynamic>) {
      return {
        'id': backendData['id_cliente'] ?? backendData['id'] ?? 0,
        'nombre': backendData['nombre'] ?? '',
        'apellido': backendData['apellido'] ?? '',
        'telefono': backendData['telefono'] ?? '',
        'correo': backendData['correo'] ?? '',
        'tipo_documento': backendData['tipo_documento'] ?? 'CC',
        'numero_documento': backendData['numero_documento'] ?? '',
        'genero': backendData['genero'] ?? '',
        'fecha_nacimiento': backendData['fecha_nacimiento'] ?? '',
      };
    }
    return {};
  }
}
