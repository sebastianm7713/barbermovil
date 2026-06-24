# ⚡ Guía Rápida - Ejemplos de Uso

## 1️⃣ Importar Servicios

```dart
import 'package:barber_app/services/auth_service.dart';
import 'package:barber_app/services/service_service.dart';
import 'package:barber_app/services/cita_service.dart';
import 'package:barber_app/services/cliente_service.dart';
```

---

## 2️⃣ Login Rápido

```dart
final authService = AuthService();

try {
  final response = await authService.login(
    'usuario@email.com',
    'password123'
  );
  print('✅ Login exitoso');
  print('Token: ${response['token']}');
} catch (e) {
  print('❌ Error: $e');
}
```

---

## 3️⃣ Obtener Servicios

```dart
final serviceService = ServiceService();

List<Service> servicios = await serviceService.getAllServices();

for (var servicio in servicios) {
  print('${servicio.name}: \$${servicio.price}');
}
```

---

## 4️⃣ Crear Servicio (Admin)

```dart
final newService = Service(
  id: 0,
  name: 'Barba Completa',
  description: 'Afeitado y barba completa',
  price: 15000,
  duration: 20,
  imageUrl: 'https://...',
);

final creado = await serviceService.createService(newService);
if (creado != null) {
  print('✅ Servicio creado: ${creado.id}');
}
```

---

## 5️⃣ Crear Cita

```dart
final cita = BarberAppointment(
  id: 0,
  clientId: 1,
  barberId: 2,
  serviceId: 1,
  date: DateTime.now().add(Duration(days: 2)),
  hour: '14:00',
  service: 'Corte Moderno',
  status: 'pending',
);

final citaCreada = await CitaService().createCita(cita);
if (citaCreada != null) {
  print('✅ Cita creada para ${cita.date}');
}
```

---

## 6️⃣ Horas Disponibles

```dart
final horas = await CitaService().getHorasDisponibles(
  barberoId: 2,
  fecha: '2024-04-25',
);

print('Horas disponibles: $horas');
// Output: [09:00, 10:00, 11:00, 14:00, 15:00, ...]
```

---

## 7️⃣ Obtener Clientes (Admin)

```dart
final clientes = await ClienteService().getAllClientes();

for (var cliente in clientes) {
  print('${cliente['nombre']} - ${cliente['correo']}');
}
```

---

## 8️⃣ Verificar Autenticación

```dart
final isAuth = await authService.isAuthenticated();

if (isAuth) {
  print('✅ Usuario autenticado');
  final email = await authService.getUserEmail();
  print('Email: $email');
} else {
  print('❌ No autenticado - redirigir a login');
}
```

---

## 9️⃣ Logout

```dart
await authService.logout();
print('✅ Sesión cerrada');
```

---

## 🔟 Manejo de Errores

```dart
try {
  final servicios = await serviceService.getAllServices();
  // ...
} on Exception catch (e) {
  // Mostrar error al usuario
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## 📌 Tips Importantes

### ✅ Usa Try-Catch siempre
```dart
try {
  // tu código
} catch (e) {
  print('Error: $e');
}
```

### ✅ Carga datos en initState o didChangeDependencies
```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  try {
    final servicios = await serviceService.getAllServices();
    setState(() => this.servicios = servicios);
  } catch (e) {
    // Manejar error
  }
}
```

### ✅ Usa Providers para estado global
```dart
// En build()
Consumer<ServiceProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      itemCount: provider.services.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(provider.services[i].name),
      ),
    );
  },
)
```

---

## 🛠️ Troubleshooting

### Error: "Unable to connect to host"
- Verifica que backend esté ejecutándose en `localhost:4000`
- Verifica URL en `api_service.dart`

### Error: 401 Unauthorized
- Token expirado o inválido
- Llama a `authService.logout()` y redirige a login

### Error: "Connection timeout"
- Backend está lento
- Aumenta timeout en `ApiService`:
```dart
connectTimeout: const Duration(seconds: 60),
receiveTimeout: const Duration(seconds: 60),
```

### No se guarda el token
- Verifica que `SharedPreferences` esté instalado
- Revisa logs de `authService.login()`

---

## 📱 En StatefulWidget

```dart
class MiScreen extends StatefulWidget {
  @override
  State<MiScreen> createState() => _MiScreenState();
}

class _MiScreenState extends State<MiScreen> {
  final serviceService = ServiceService();
  List<Service> servicios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServicios();
  }

  Future<void> _loadServicios() async {
    try {
      final data = await serviceService.getAllServices();
      setState(() {
        servicios = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: servicios.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(servicios[i].name),
        subtitle: Text('\$${servicios[i].price}'),
      ),
    );
  }
}
```

---

## 📱 Con Provider (Recomendado)

```dart
// En main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ServiceProvider()),
    ChangeNotifierProvider(create: (_) => BarberAppointmentProvider()),
  ],
  child: MyApp(),
)

// En tu screen
@override
void initState() {
  super.initState();
  Provider.of<ServiceProvider>(context, listen: false).loadServices();
}

@override
Widget build(BuildContext context) {
  return Consumer<ServiceProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) return CircularProgressIndicator();
      return ListView.builder(
        itemCount: provider.services.length,
        itemBuilder: (_, i) => ServiceTile(provider.services[i]),
      );
    },
  );
}
```

---

## 🚀 Checklist Antes de Producción

- [ ] Cambiar `baseUrl` a servidor real
- [ ] Verificar timeout de conexión
- [ ] Probar en dispositivo real
- [ ] Verificar manejo de errores de red
- [ ] Probar logout y login
- [ ] Verificar que el token persista después de cerrar app
- [ ] Validar CORS en backend

---

¡Listo para usar! 🎉
