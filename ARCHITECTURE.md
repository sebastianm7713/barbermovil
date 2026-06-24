# 🏗️ Arquitectura de Conexión Backend-Frontend

## Diagrama de Flujo

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP                             │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (Screens, Widgets)                                │
│  ↓                                                            │
│  Providers (with ChangeNotifier)                            │
│  ├─ ServiceProvider                                         │
│  ├─ BarberAppointmentProvider                              │
│  ├─ AuthProvider                                            │
│  └─ ClientProvider                                          │
│  ↓                                                            │
│  Services (Business Logic)                                  │
│  ├─ AuthService         → API calls + SharedPreferences    │
│  ├─ ServiceService      → API calls + data mapping         │
│  ├─ CitaService         → API calls + data mapping         │
│  └─ ClienteService      → API calls + data mapping         │
│  ↓                                                            │
│  ApiService (HTTP Layer)                                    │
│  └─ Dio client with interceptors & error handling          │
└─────────────────────────────────────────────────────────────┘
         ↑                                    ↓
         │         HTTP Requests/Responses   │
         └────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              BACKEND (Express + TypeScript)                  │
├─────────────────────────────────────────────────────────────┤
│  Routes Layer                                               │
│  ├─ /api/auth           → authRoutes                       │
│  ├─ /api/servicios      → serviciosRoutes                  │
│  ├─ /api/citas          → citasRoutes                      │
│  └─ /api/clientes       → clientesRoutes                   │
│  ↓                                                            │
│  Controllers Layer (Request handling)                       │
│  ├─ auth.controller                                         │
│  ├─ servicios.controller                                    │
│  ├─ citas.controller                                        │
│  └─ clientes.controller                                     │
│  ↓                                                            │
│  Services Layer (Business logic)                            │
│  ├─ auth.service                                            │
│  ├─ servicios.service                                       │
│  ├─ citas.service                                           │
│  └─ clientes.service                                        │
│  ↓                                                            │
│  Repository Layer (Database)                                │
│  ├─ auth.repository                                         │
│  ├─ servicios.repository                                    │
│  ├─ citas.repository                                        │
│  └─ clientes.repository                                     │
│  ↓                                                            │
│  Database: SQL Server (MSSQL)                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Estructura de Archivos Flutter

```
lib/
├── main.dart
├── core/
│   ├── app_theme.dart
│   └── api.dart
├── models/
│   ├── service.dart
│   ├── barber_appointment.dart
│   ├── user.dart
│   └── cliente.dart
├── services/                          ← NUEVOS SERVICIOS
│   ├── api_service.dart              ← HTTP Client centralizado
│   ├── auth_service.dart             ← Autenticación
│   ├── service_service.dart          ← Servicios (barbería)
│   ├── cita_service.dart             ← Citas
│   ├── cliente_service.dart          ← Clientes
│   └── user_service.dart
├── providers/
│   ├── service_provider.dart
│   ├── barber_appointment_provider.dart
│   ├── auth_provider.dart
│   └── client_provider.dart
├── screens/
│   ├── login/
│   ├── admin/
│   ├── employee/
│   ├── client/
│   └── ...
└── widgets/
    └── ...
```

---

## 🔄 Flujo de Datos Ejemplo: Obtener Servicios

```
1. UI (ManageServicesScreen)
   └─ serviceProvider.loadServices()

2. Provider (ServiceProvider)
   └─ serviceService.getAllServices()

3. Service (ServiceService)
   ├─ apiService.getServicios()
   └─ Mapea datos del backend al modelo frontend

4. ApiService
   ├─ GET http://localhost:4000/api/servicios
   ├─ Agrega token Authorization header (si existe)
   └─ Maneja errores y excepciones

5. Backend Controller
   ├─ Verifica autenticación (si es necesario)
   ├─ Valida datos
   └─ Retorna JSON

6. Backend Service
   └─ Obtiene datos de la base de datos

7. SQL Server Database
   └─ SELECT * FROM servicios

8. Respuesta vuelve al Frontend
   ├─ JSON → Modelo Dart
   ├─ Actualiza estado del Provider
   └─ UI se redibuja con nuevos datos

9. UI (ManageServicesScreen)
   └─ Muestra servicios en ListView
```

---

## 🔐 Flujo de Autenticación

```
1. Usuario ingresa email y contraseña
   └─ LoginScreen → AuthService.login(email, password)

2. AuthService
   ├─ ApiService.login(email, password)
   ├─ POST /api/auth/login con credenciales
   └─ Guarda token en SharedPreferences

3. Backend
   ├─ auth.controller.login()
   ├─ Verifica credenciales en BD
   ├─ Genera JWT token
   └─ Retorna {token, user_data}

4. Frontend recibe token
   ├─ SharedPreferences.setString('auth_token', token)
   ├─ ApiService.interceptor agrega token a headers
   └─ Redirige a pantalla principal

5. Todas las solicitudes futuras incluyen:
   ├─ Authorization: Bearer {token}
   └─ Backend valida token en middleware
```

---

## 📊 Mapeo de Datos Backend → Frontend

### Servicios

| Backend | Frontend |
|---------|----------|
| `id_servicio` | `id` |
| `nombre` | `name` |
| `descripcion` | `description` |
| `precio` | `price` |
| `duracion` | `duration` |
| `img` | `imageUrl` |

### Citas

| Backend | Frontend |
|---------|----------|
| `id_cita` | `id` |
| `id_cliente` | `clientId` |
| `id_barbero` | `barberId` |
| `id_servicio` | `serviceId` |
| `fecha` | `date` |
| `hora` | `hour` |
| `nombre_servicio` | `service` |
| `estado` | `status` |

### Clientes

| Backend | Frontend |
|---------|----------|
| `id_cliente` | `id` |
| `nombre` | `nombre` |
| `apellido` | `apellido` |
| `correo` | `correo` |
| `telefono` | `telefono` |
| `numero_documento` | `numero_documento` |
| `tipo_documento` | `tipo_documento` |

---

## 🛡️ Seguridad

### Token Storage
- ✅ Almacenado en SharedPreferences (encriptado en Android/iOS)
- ✅ Incluido automáticamente en cada request
- ✅ Eliminado al logout

### Headers de Seguridad
- ✅ `Authorization: Bearer {token}` en solicitudes autenticadas
- ✅ `Content-Type: application/json` en POST/PUT
- ✅ CORS configurado en backend

### Manejo de Errores
- ✅ 401 Unauthorized → Limpia token y redirige a login
- ✅ 400 Bad Request → Muestra errores de validación
- ✅ 500 Internal Server → Muestra error genérico

---

## ✅ Checklist de Implementación

- [x] ApiService creado (cliente HTTP centralizado)
- [x] AuthService creado (autenticación)
- [x] ServiceService actualizado (servicios)
- [x] CitaService creado (citas)
- [x] ClienteService creado (clientes)
- [ ] Actualizar todos los Providers para usar nuevos servicios
- [ ] Probar autenticación
- [ ] Probar CRUD de servicios
- [ ] Probar CRUD de citas
- [ ] Probar CRUD de clientes
- [ ] Validar manejo de errores
- [ ] Probar en dispositivo real

---

## 🧪 Pruebas Recomendadas

### 1. Test de Conexión
```dart
void testConnection() async {
  try {
    final servicios = await serviceService.getAllServices();
    print('✅ Conexión OK: ${servicios.length} servicios');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### 2. Test de Autenticación
```dart
void testAuth() async {
  try {
    final response = await authService.login('admin@barberia.com', 'password');
    print('✅ Login OK: ${response['token']}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## 📞 Endpoints Documentados

Ver archivo completo: **`BACKEND_CONNECTION_GUIDE.md`**

---

## 🚀 Próximo Paso: Actualizar Providers

Los Providers necesitan usar los nuevos servicios. Ejemplo:

```dart
// ANTES (usando http)
Future<void> loadServices() async {
  final http.Response response = 
    await http.get(Uri.parse('$apiUrl/servicios'));
  // ...
}

// DESPUÉS (usando ApiService)
Future<void> loadServices() async {
  try {
    services = await _serviceService.getAllServices();
    notifyListeners();
  } catch (e) {
    // Manejar error
  }
}
```

---

¡Listo para conectar tu app con el backend! 🎉
