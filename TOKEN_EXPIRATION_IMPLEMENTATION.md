# Token Expiration Handler - Implementación

## Resumen
Se ha implementado un sistema automático que detecta cuando el token de autenticación ha expirado (respuesta HTTP 401) y cierra la sesión automáticamente, redirigiendo al usuario a la pantalla de login.

## Cambios Realizados

### 1. Nuevo Archivo: `token_expiration_handler.dart`
- **Ubicación**: `lib/services/token_expiration_handler.dart`
- **Función**: Manejador centralizado para detectar y gestionar expiración de tokens
- **Métodos principales**:
  - `initialize(navigatorKey)`: Inicializa el manejador con la clave del navegador
  - `handleTokenExpiration(statusCode)`: Detecta si el status code es 401 y ejecuta logout
  - `logoutWithContext(context)`: Cierra sesión mostrando un diálogo informativo

### 2. Actualización de Servicios API
Se agregó detección de tokens expirados en los siguientes servicios:

#### `user_service.dart`
- `getUserProfile()`: Verifica status 401
- `updateQuizInfo()`: Verifica status 401
- `updateProfile()`: Verifica status 401

#### `diary_service.dart`
- `getAllReflections()`: Verifica status 401
- `getReflectionByDate()`: Verifica status 401
- `saveMorningReflection()`: Verifica status 401
- `deleteReflection()`: Verifica status 401
- `updateReflection()`: Verifica status 401

#### `quiz_service.dart`
- `submitQuiz()`: Verifica status 401
- `getQuizData()`: Verifica status 401

#### `content_service.dart`
- `getDailyQuote()`: Verifica status 401

### 3. Actualización de `main.dart`
- Se agregó inicialización del `TokenExpirationHandler` en `EstoicoApp`
- Se agregó `navigatorKey` para permitir navegación automática
- Se definieron rutas con nombres (`/login`, `/home`, `/splash`)
- Se importó `LoginScreen`

## Cómo Funciona

1. **Cuando una petición recibe respuesta 401 (Unauthorized)**:
   - El servicio API detecta el status code 401
   - Llama a `TokenExpirationHandler.handleTokenExpiration(401)`

2. **El TokenExpirationHandler**:
   - Borra todos los datos de sesión usando `LocalStorageService.logout()`
   - Navega automáticamente a la pantalla de login
   - Retorna un objeto con `'tokenExpired': true` para que el UI pueda reaccionar si es necesario

3. **Respuesta del API**:
   - Todos los métodos retornan un objeto con estructura:
     ```dart
     {
       'success': false,
       'message': 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
       'tokenExpired': true,
     }
     ```

## Uso en Widgets

En cualquier widget que haga llamadas a servicios autenticados, puedes verificar si el token expiró:

```dart
final response = await UserService.getUserProfile();
if (response['tokenExpired'] == true) {
  // La sesión expiró, el usuario será redirigido automáticamente
  // Pero puedes agregar lógica adicional aquí si es necesario
}
```

Alternativa con contexto (más detallada):
```dart
final response = await UserService.getUserProfile();
if (!mounted) return;

if (response['tokenExpired'] == true) {
  await TokenExpirationHandler.logoutWithContext(context);
}
```

## Flujo Completo

```
Usuario hace petición autenticada
           ↓
Token ha expirado (respuesta 401)
           ↓
Servicio API detecta status 401
           ↓
Llama TokenExpirationHandler.handleTokenExpiration(401)
           ↓
1. Borra token y datos de sesión
2. Navega a pantalla de login
           ↓
Usuario ve mensaje de sesión expirada
```

## Notas Importantes

- El logout es **automático** cuando el servidor retorna 401
- El usuario es redirigido a la pantalla de login sin perder datos importantes (solo se borra el token)
- Todos los servicios API ahora están protegidos contra tokens expirados
- La implementación es **centralizada** en `TokenExpirationHandler` para fácil mantenimiento

## Futuras Mejoras

- Implementar refresh token automático (si el backend lo soporta)
- Mostrar notificaciones toast informando sobre la expiración
- Agregar reintentos automáticos en lugar de logout inmediato
