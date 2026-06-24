# 📋 Estructura de Respuestas del Backend

## Servicios

### GET /api/servicios
```json
[
  {
    "id_servicio": 1,
    "nombre": "Corte Moderno",
    "descripcion": "Corte con diseño moderno",
    "precio": 25000,
    "duracion": 30,
    "porcentaje_barbero": 30,
    "img": "https://example.com/image.jpg"
  },
  {
    "id_servicio": 2,
    "nombre": "Barba Completa",
    "descripcion": "Afeitado profesional",
    "precio": 15000,
    "duracion": 20,
    "porcentaje_barbero": 30,
    "img": null
  }
]
```

### POST /api/servicios (Crear)
**Request:**
```json
{
  "nombre": "Corte Clásico",
  "descripcion": "Corte tradicional",
  "precio": 20000,
  "duracion": 25,
  "porcentaje_barbero": 30
}
```

**Response:**
```json
{
  "message": "Servicio creado",
  "data": {
    "id_servicio": 3,
    "nombre": "Corte Clásico",
    "descripcion": "Corte tradicional",
    "precio": 20000,
    "duracion": 25,
    "porcentaje_barbero": 30
  }
}
```

### PUT /api/servicios/:id (Actualizar)
**Response:**
```json
{
  "message": "Servicio actualizado",
  "data": {
    "id_servicio": 1,
    "nombre": "Corte Moderno Actualizado",
    "descripcion": "Actualizado",
    "precio": 27000,
    "duracion": 30,
    "porcentaje_barbero": 30
  }
}
```

### DELETE /api/servicios/:id
**Response:**
```json
{
  "message": "Servicio eliminado"
}
```

---

## Autenticación

### POST /api/auth/login
**Request:**
```json
{
  "email": "usuario@barberia.com",
  "password": "password123"
}
```

**Response (Éxito):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "id_usuario": 1,
      "nombre": "Juan",
      "apellido": "Pérez",
      "correo": "usuario@barberia.com",
      "id_rol": 1,
      "telefono": "3005551234"
    }
  }
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Credenciales inválidas"
}
```

### POST /api/auth/register
**Request:**
```json
{
  "nombre": "Carlos",
  "apellido": "García",
  "correo": "carlos@barberia.com",
  "password": "password123",
  "telefono": "3105551234",
  "numero_documento": "1234567890",
  "tipo_documento": "CC"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "data": {
    "id_usuario": 5,
    "nombre": "Carlos",
    "apellido": "García",
    "correo": "carlos@barberia.com"
  }
}
```

### GET /api/auth/profile (Requiere Token)
**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id_usuario": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "correo": "usuario@barberia.com",
    "id_rol": 1,
    "telefono": "3005551234"
  }
}
```

### POST /api/auth/forgot-password
**Request:**
```json
{
  "email": "usuario@barberia.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Email de recuperación enviado"
}
```

### POST /api/auth/reset-password
**Request:**
```json
{
  "token": "reset_token_here",
  "password": "nueva_password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Contraseña actualizada"
}
```

---

## Citas

### GET /api/citas (Requiere Token)
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id_cita": 1,
      "id_cliente": 5,
      "id_barbero": 2,
      "id_servicio": 1,
      "fecha": "2024-04-25T00:00:00.000Z",
      "hora": "14:00",
      "nombre_servicio": "Corte Moderno",
      "estado": "pending",
      "created_at": "2024-04-20T10:30:00.000Z"
    },
    {
      "id_cita": 2,
      "id_cliente": 6,
      "id_barbero": 2,
      "id_servicio": 2,
      "fecha": "2024-04-26T00:00:00.000Z",
      "hora": "15:00",
      "nombre_servicio": "Barba Completa",
      "estado": "completed",
      "created_at": "2024-04-20T11:00:00.000Z"
    }
  ]
}
```

### POST /api/citas (Requiere Token)
**Request:**
```json
{
  "id_cliente": 5,
  "id_barbero": 2,
  "id_servicio": 1,
  "fecha": "2024-04-25",
  "hora": "14:00",
  "estado": "pending"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id_cita": 3,
    "id_cliente": 5,
    "id_barbero": 2,
    "id_servicio": 1,
    "fecha": "2024-04-25T00:00:00.000Z",
    "hora": "14:00",
    "nombre_servicio": "Corte Moderno",
    "estado": "pending"
  }
}
```

### POST /api/citas/landing (Sin Autenticación)
**Request:**
```json
{
  "id_cliente": 0,
  "id_barbero": 2,
  "id_servicio": 1,
  "fecha": "2024-04-25",
  "hora": "14:00",
  "estado": "pending"
}
```

**Response:** (Mismo que arriba)

### GET /api/citas/disponibilidad/horario?id_barbero=2&fecha=2024-04-25
**Response:**
```json
{
  "success": true,
  "data": [
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00"
  ]
}
```

### PUT /api/citas/:id (Requiere Token)
**Request:**
```json
{
  "estado": "completed"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id_cita": 1,
    "estado": "completed"
  }
}
```

### DELETE /api/citas/:id
**Response:**
```json
{
  "success": true,
  "message": "Cita eliminada"
}
```

---

## Clientes

### GET /api/clientes (Requiere Token - Admin/Barbero)
**Response:**
```json
[
  {
    "id_cliente": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "telefono": "3005551234",
    "correo": "juan@email.com",
    "tipo_documento": "CC",
    "numero_documento": "1234567890",
    "genero": "Masculino",
    "fecha_nacimiento": "1990-01-15"
  },
  {
    "id_cliente": 2,
    "nombre": "María",
    "apellido": "García",
    "telefono": "3105559999",
    "correo": "maria@email.com",
    "tipo_documento": "CC",
    "numero_documento": "9876543210",
    "genero": "Femenino",
    "fecha_nacimiento": "1992-05-20"
  }
]
```

### POST /api/clientes (Requiere Token - Admin)
**Request:**
```json
{
  "nombre": "Carlos",
  "apellido": "López",
  "telefono": "3115554444",
  "correo": "carlos@email.com",
  "tipo_documento": "CC",
  "numero_documento": "5555555555",
  "genero": "Masculino",
  "fecha_nacimiento": "1988-03-10"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id_cliente": 3,
    "nombre": "Carlos",
    "apellido": "López",
    "telefono": "3115554444",
    "correo": "carlos@email.com",
    "tipo_documento": "CC",
    "numero_documento": "5555555555",
    "genero": "Masculino",
    "fecha_nacimiento": "1988-03-10"
  }
}
```

### PUT /api/clientes/:id (Requiere Token - Admin)
**Response:** (Mismo estructura que POST)

### DELETE /api/clientes/:id
**Response:**
```json
{
  "success": true,
  "message": "Cliente eliminado"
}
```

---

## Códigos HTTP de Respuesta

| Código | Significado | Acción |
|--------|-------------|--------|
| **200** | OK | Request exitoso |
| **201** | Created | Recurso creado |
| **400** | Bad Request | Datos inválidos |
| **401** | Unauthorized | Token inválido o expirado |
| **403** | Forbidden | Sin permisos |
| **404** | Not Found | Recurso no existe |
| **500** | Internal Server Error | Error del servidor |

---

## Manejo de Errores en Respuesta

Todos los errores siguen este formato:

```json
{
  "success": false,
  "message": "Descripción del error",
  "errors": [
    {
      "field": "nombre",
      "message": "El nombre es requerido"
    }
  ]
}
```

---

## Headers Necesarios

### Autenticado
```
Authorization: Bearer {token}
Content-Type: application/json
```

### Sin Autenticación
```
Content-Type: application/json
```

---

## Rol e ID en JWT

El token contiene este payload (ejemplo):

```json
{
  "id": 1,
  "email": "admin@barberia.com",
  "rol": 1,
  "iat": 1713607400,
  "exp": 1713693800
}
```

---

## Estados de Cita

- `pending` → Pendiente
- `confirmed` → Confirmada
- `completed` → Completada
- `cancelled` → Cancelada

---

## Roles

- `1` → Admin
- `2` → Barbero/Empleado
- `3` → Cliente

---

¡Referencia completa del backend! 📚
