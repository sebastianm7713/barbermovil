# 📚 Documentación de Conexión Flutter ↔ Backend

## Resumen de la Integración

Se ha creado una capa de servicios completa para conectar tu app Flutter con el backend:

### Archivos Creados:

1. **`lib/services/api_service.dart`** - Servicio HTTP central con Dio
2. **`lib/services/auth_service.dart`** - Autenticación (login, registro, etc)
3. **`lib/services/service_service.dart`** - Servicios de barbería
4. **`lib/services/cita_service.dart`** - Gestión de citas
5. **`lib/services/cliente_service.dart`** - Gestión de clientes

---

## ⚙️ Configuración Inicial

### 1. Actualizar BaseURL (si es necesario)

En `lib/services/api_service.dart`:

```dart
static const String baseUrl = "http://localhost:4000/api";
```

**Para producción**, cambiar a:
```dart
static const String baseUrl = "http://tu-servidor.com/api";
```

### 2. Verificar pubspec.yaml

Asegúrate de tener estas dependencias:

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0  # Cliente HTTP
  shared_preferences: ^2.2.0  # Almacenamiento local
  provider: ^6.1.0  # State Management
```

---

## 🔐 Autenticación

### Login

```dart
import 'package:barber_app/services/auth_service.dart';

final authService = AuthService();

try {
  final response = await authService.login('email@example.com', 'password123');
  print('Token: ${response['token']}');
  print('Usuario ID: ${response['id']}');
} catch (e) {
  print('Error: $e');
}
```

### Registro

```dart
final response = await authService.register({
  'nombre': 'Juan',
  'apellido': 'Pérez',
  'correo': 'juan@example.com',
  'password': 'password123',
  'telefono': '3005551234',
  'numero_documento': '1234567890',
  'tipo_documento': 'CC',
});
```

### Obtener Token Guardado

```dart
final token = await authService.getToken();
if (token != null) {
  print('Usuario autenticado');
} else {
  print('Usuario no autenticado');
}
```

### Logout

```dart
await authService.logout();
```

---

## 💇 Servicios (Barbería)

### Obtener Todos los Servicios

```dart
import 'package:barber_app/services/service_service.dart';
import 'package:barber_app/models/service.dart';

final serviceService = ServiceService();

try {
  List<Service> servicios = await serviceService.getAllServices();
  for (var servicio in servicios) {
    print('${servicio.name}: \$${servicio.price}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Obtener Servicio por ID

```dart
final servicio = await serviceService.getServiceById(1);
if (servicio != null) {
  print('Nombre: ${servicio.name}');
  print('Precio: ${servicio.price}');
}
```

### Crear Servicio (Admin)

```dart
final newService = Service(
  id: 0,
  name: 'Corte Moderno',
  description: 'Corte con diseño moderno',
  price: 25000,
  duration: 30,
  imageUrl: 'https://example.com/image.jpg',
);

final creado = await serviceService.createService(newService);
if (creado != null) {
  print('Servicio creado: ${creado.id}');
}
```

### Actualizar Servicio (Admin)

```dart
final servicio = Service(
  id: 1,
  name: 'Corte Clásico',
  description: 'Actualizado',
  price: 30000,
  duration: 45,
  imageUrl: 'https://example.com/new.jpg',
);

final actualizado = await serviceService.updateService(1, servicio);
if (actualizado) {
  print('Servicio actualizado');
}
```

### Eliminar Servicio (Admin)

```dart
final eliminado = await serviceService.deleteServicio(1);
if (eliminado) {
  print('Servicio eliminado');
}
```

---

## 📅 Citas

### Obtener Todas las Citas

```dart
import 'package:barber_app/services/cita_service.dart';
import 'package:barber_app/models/barber_appointment.dart';

final citaService = CitaService();

try {
  List<BarberAppointment> citas = await citaService.getAllCitas();
  for (var cita in citas) {
    print('Cita ${cita.id}: ${cita.date} - ${cita.hour}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Obtener Cita por ID

```dart
final cita = await citaService.getCitaById(1);
if (cita != null) {
  print('Estado: ${cita.status}');
}
```

### Crear Cita (Autenticado)

```dart
final newCita = BarberAppointment(
  id: 0,
  clientId: 5,
  barberId: 2,
  serviceId: 1,
  date: DateTime.now().add(Duration(days: 3)),
  hour: '14:30',
  service: 'Corte Moderno',
  status: 'pending',
);

final creada = await citaService.createCita(newCita);
if (creada != null) {
  print('Cita creada: ${creada.id}');
}
```

### Crear Cita desde Landing (Sin Login)

```dart
final creada = await citaService.createCitaFromLanding(newCita);
```

### Obtener Horas Disponibles

```dart
final horas = await citaService.getHorasDisponibles(
  barberoId: 2,
  fecha: '2024-04-25',
);
print('Horas disponibles: $horas');
```

### Actualizar Cita

```dart
final cita = BarberAppointment(
  id: 1,
  clientId: 5,
  barberId: 2,
  serviceId: 1,
  date: DateTime.now(),
  hour: '15:00',
  service: 'Corte Moderno',
  status: 'completed',
);

final actualizada = await citaService.updateCita(1, cita);
if (actualizada) {
  print('Cita actualizada');
}
```

### Eliminar Cita

```dart
final eliminada = await citaService.deleteCita(1);
if (eliminada) {
  print('Cita eliminada');
}
```

---

## 👥 Clientes

### Obtener Todos los Clientes (Admin/Barbero)

```dart
import 'package:barber_app/services/cliente_service.dart';

final clienteService = ClienteService();

try {
  List<Map<String, dynamic>> clientes = await clienteService.getAllClientes();
  for (var cliente in clientes) {
    print('${cliente['nombre']} ${cliente['apellido']}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Obtener Cliente por ID

```dart
final cliente = await clienteService.getClienteById(1);
if (cliente != null) {
  print('Email: ${cliente['correo']}');
}
```

### Crear Cliente (Admin)

```dart
final nuevoCliente = {
  'nombre': 'Carlos',
  'apellido': 'García',
  'telefono': '3105551234',
  'correo': 'carlos@example.com',
  'tipo_documento': 'CC',
  'numero_documento': '1234567890',
  'genero': 'Masculino',
  'fecha_nacimiento': '1990-01-15',
};

final creado = await clienteService.createCliente(nuevoCliente);
if (creado != null) {
  print('Cliente creado: ${creado['id']}');
}
```

### Actualizar Cliente

```dart
final actualizado = await clienteService.updateCliente(1, {
  'nombre': 'Carlos Andrés',
  'telefono': '3105559999',
});

if (actualizado) {
  print('Cliente actualizado');
}
```

### Eliminar Cliente (Admin)

```dart
final eliminado = await clienteService.deleteCliente(1);
if (eliminado) {
  print('Cliente eliminado');
}
```

---

## 🔄 Manejo de Errores

Todos los servicios lanzan excepciones. Usa try-catch:

```dart
try {
  final resultado = await serviceService.getAllServices();
  // Procesar resultado
} on Exception catch (e) {
  print('Error: $e');
  // Mostrar snackbar al usuario
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

---

## 📍 Estructura de URLs de la API

```
POST   /api/auth/login                    → Login
POST   /api/auth/register                 → Registro
POST   /api/auth/forgot-password          → Olvidé contraseña
POST   /api/auth/reset-password           → Resetear contraseña
GET    /api/auth/profile                  → Obtener perfil
GET    /api/auth/permisos                 → Obtener permisos

GET    /api/servicios                     → Todos los servicios
GET    /api/servicios/:id                 → Servicio por ID
POST   /api/servicios                     → Crear servicio (Admin)
PUT    /api/servicios/:id                 → Actualizar servicio (Admin)
DELETE /api/servicios/:id                 → Eliminar servicio (Admin)

GET    /api/citas                         → Todas las citas
GET    /api/citas/:id                     → Cita por ID
POST   /api/citas                         → Crear cita (Autenticado)
POST   /api/citas/landing                 → Crear cita (Landing)
PUT    /api/citas/:id                     → Actualizar cita
DELETE /api/citas/:id                     → Eliminar cita
GET    /api/citas/disponibilidad/horario  → Horas disponibles

GET    /api/clientes                      → Todos los clientes (Admin/Barbero)
GET    /api/clientes/:id                  → Cliente por ID
POST   /api/clientes                      → Crear cliente (Admin)
PUT    /api/clientes/:id                  → Actualizar cliente (Admin)
DELETE /api/clientes/:id                  → Eliminar cliente (Admin)
```

---

## 🔑 Roles y Permisos

- **Role 1**: Admin (acceso completo)
- **Role 2**: Barbero/Empleado (lectura de servicios, gestión de citas)
- **Role 3**: Cliente (solo lectura de servicios, crear citas)

---

## 💾 Persistencia de Datos

El token se guarda automáticamente en SharedPreferences:

```dart
// Obtener datos guardados
final email = await authService.getUserEmail();
final userId = await authService.getUserId();
final role = await authService.getUserRole();
```

---

## 🚀 Próximos Pasos

1. ✅ Conectar formularios de login/registro
2. ✅ Actualizar providers para usar estos servicios
3. ✅ Implementar interceptores para manejar errores 401
4. ✅ Probar con dispositivo real/emulador

---

¿Necesitas ayuda con algún endpoint específico?
