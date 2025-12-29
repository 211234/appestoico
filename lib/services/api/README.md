# Estructura de Servicios API

Esta carpeta contiene los servicios API organizados por funcionalidad.

## Archivos

### 📁 `auth_service.dart`
**Autenticación de usuarios**
- `register()` - Registro de nuevos usuarios
- `login()` - Inicio de sesión
- `forgotPassword()` - Solicitar restablecimiento de contraseña
- `verifyResetCode()` - Verificar código de recuperación
- `resetPassword()` - Restablecer contraseña

### 📁 `verification_service.dart`
**Verificación de códigos**
- `verifyEmailCode()` - Verificar código de email

### 📁 `local_storage_service.dart`
**Almacenamiento local de datos**
- `saveUserData()` - Guardar datos del usuario localmente
- `getUserData()` - Obtener datos del usuario
- `isLoggedIn()` - Verificar si hay sesión activa
- `logout()` - Cerrar sesión
- `getToken()` - Obtener token de autenticación

### 📁 `user_service.dart`
**Gestión del perfil de usuario**
- `getUserProfile()` - Obtener perfil del usuario desde el servidor
- `updateQuizInfo()` - Actualizar información básica del quiz
- `updateProfile()` - Actualizar perfil completo

### 📁 `quiz_service.dart`
**Gestión de quiz**
- `submitQuiz()` - Enviar quiz completo
- `getQuizData()` - Obtener datos del quiz completado

### 📁 `diary_service.dart`
**Gestión del diario (reflexiones)**
- `getAllReflections()` - Obtener todas las reflexiones del usuario
- `getReflectionByDate()` - Obtener reflexión de una fecha específica
- `saveMorningReflection()` - Crear/actualizar reflexión matutina
- `deleteReflection()` - Eliminar reflexión
- `updateReflection()` - Actualizar reflexión
- `saveReflection()` - Método de compatibilidad

### 📁 `content_service.dart`
**Contenido general**
- `getDailyQuote()` - Obtener frase del día
- `searchEmblemas()` - Buscar emblemas (apellidos/familias)

## Uso

### Para código existente
Continúa usando `ApiService` como antes:
```dart
import 'package:estoico/services/api_service.dart';

final result = await ApiService.login(email: email, password: password);
```

### Para código nuevo (recomendado)
Importa directamente los servicios especializados:
```dart
import 'package:estoico/services/api/auth_service.dart';

final result = await AuthService.login(email: email, password: password);
```

## Ventajas de esta estructura

1. **Código más organizado** - Cada servicio tiene una responsabilidad clara
2. **Más fácil de mantener** - Los cambios se hacen en archivos pequeños
3. **Mejor rendimiento** - Solo se importa lo necesario
4. **Más fácil de testear** - Se pueden mockear servicios individuales
5. **Retrocompatibilidad** - El código existente sigue funcionando sin cambios
