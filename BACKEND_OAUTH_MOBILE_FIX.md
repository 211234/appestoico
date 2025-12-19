# 🔧 Configuración Backend para OAuth Móvil

## ❌ Problema Actual

El backend está usando `redirect_uri=http://localhost:8000/auth/google/callback` que **NO FUNCIONA** en dispositivos móviles porque:

- `localhost` en móvil = el propio dispositivo
- No puede conectarse a tu PC
- Chrome muestra: **ERR_CONNECTION_REFUSED**

---

## ✅ Solución Implementada en la App

La app ahora **reemplaza automáticamente** `localhost` por el dominio ngrok:

```dart
// Antes: http://localhost:8000/auth/google/callback
// Ahora: https://12ed3568a8de.ngrok-free.app/auth/google/callback
```

---

## 🔧 Cambios Necesarios en el Backend

### Opción 1: Endpoint de Callback (Recomendado para desarrollo rápido)

Tu backend ya tiene el endpoint `/auth/google/callback`, solo necesita redirigir al deep link:

**Endpoint**: `GET /auth/google/callback`

**Código Actual** (probablemente):
```python
@app.get('/auth/google/callback')
async def google_callback(code: str):
    # Intercambiar code por token con Google
    user_data = await get_google_user_data(code)
    
    # Crear usuario o hacer login
    token = create_jwt_token(user_data)
    
    # ❌ Actualmente redirige a localhost web
    return RedirectResponse(url=f'http://localhost:3000/home?token={token}')
```

**Código Necesario**:
```python
@app.get('/auth/google/callback')
async def google_callback(code: str):
    # Intercambiar code por token con Google
    user_data = await get_google_user_data(code)
    
    # Crear usuario o hacer login
    token = create_jwt_token(user_data)
    user_id = user_data['id']
    nombre = user_data.get('nombre', '')
    apellidos = user_data.get('apellidos', '')
    email = user_data.get('email', '')
    
    # ✅ Redirigir al deep link de la app móvil
    deep_link = f'estoico://auth/success?token={token}&userId={user_id}&nombre={nombre}&apellidos={apellidos}&email={email}'
    
    return RedirectResponse(url=deep_link)
```

### Opción 2: Configurar Google OAuth Console (Opcional pero mejor)

En [Google Cloud Console](https://console.cloud.google.com/):

1. Ve a **APIs & Services** > **Credentials**
2. Edita tu **OAuth 2.0 Client ID**
3. En **Authorized redirect URIs**, agrega:
   ```
   https://12ed3568a8de.ngrok-free.app/auth/google/callback
   ```
4. También puedes agregar (para desarrollo local):
   ```
   http://localhost:8000/auth/google/callback
   ```

**Nota**: Cada vez que cambies el dominio de ngrok, tendrás que actualizar esta configuración.

### Opción 3: Variable de Entorno (Mejor práctica)

Configura el redirect_uri dinámicamente:

**`.env`**:
```bash
# Para desarrollo móvil
GOOGLE_REDIRECT_URI=https://12ed3568a8de.ngrok-free.app/auth/google/callback

# Para desarrollo web local
# GOOGLE_REDIRECT_URI=http://localhost:8000/auth/google/callback
```

**Código Backend**:
```python
import os
from dotenv import load_dotenv

load_dotenv()

GOOGLE_REDIRECT_URI = os.getenv('GOOGLE_REDIRECT_URI')

@app.get('/auth/google/redirect')
async def google_redirect():
    google_auth_url = (
        f"https://accounts.google.com/o/oauth2/v2/auth"
        f"?client_id={GOOGLE_CLIENT_ID}"
        f"&redirect_uri={GOOGLE_REDIRECT_URI}"
        f"&response_type=code"
        f"&scope=openid%20email%20profile"
    )
    return {"data": {"url": google_auth_url}}
```

---

## 📱 Flujo Completo Correcto

```
1. App llama a: GET /auth/google/redirect
   ↓
2. Backend devuelve URL de Google con redirect_uri=https://ngrok.../callback
   ↓
3. App abre Chrome Custom Tab con esa URL
   ↓
4. Usuario autentica en Google
   ↓
5. Google redirige a: https://ngrok.../callback?code=...
   ↓
6. Backend recibe el code, intercambia por token
   ↓
7. Backend crea JWT y redirige a: estoico://auth/success?token=...
   ↓
8. Android detecta deep link y abre la app
   ↓
9. App recibe token y navega a Home
```

---

## 🧪 Cómo Probar

### 1. Verificar que el backend esté corriendo con ngrok:
```bash
curl https://12ed3568a8de.ngrok-free.app/api/auth/google/redirect
```

Debería devolver un JSON con la URL de Google OAuth.

### 2. Verificar que el redirect_uri use ngrok:
```bash
curl https://12ed3568a8de.ngrok-free.app/api/auth/google/redirect | grep redirect_uri
```

Debería mostrar:
```
redirect_uri=https://12ed3568a8de.ngrok-free.app/auth/google/callback
```

**NO** debe mostrar `localhost`.

### 3. Probar el callback manualmente:

Después de que Google redirija con un code, el backend debe redirigir a:
```
estoico://auth/success?token=JWT_TOKEN&userId=USER_ID&nombre=NOMBRE&apellidos=APELLIDOS&email=EMAIL
```

---

## ⚠️ Importante: Diferencia Web vs Móvil

### Para Web (localhost funciona):
```python
# redirect_uri en Google OAuth
redirect_uri = "http://localhost:8000/auth/google/callback"

# Después del callback, redirigir a:
return RedirectResponse(url=f'http://localhost:3000/home?token={token}')
```

### Para Móvil (necesita ngrok + deep link):
```python
# redirect_uri en Google OAuth
redirect_uri = "https://12ed3568a8de.ngrok-free.app/auth/google/callback"

# Después del callback, redirigir a:
return RedirectResponse(url=f'estoico://auth/success?token={token}&userId={user_id}')
```

---

## 🎯 Fix Rápido (Sin modificar backend)

Si **NO puedes modificar el backend ahora**, la app ya está haciendo el reemplazo:

```dart
// En google_auth_screen.dart (YA IMPLEMENTADO)
if (redirectUri.contains('localhost')) {
  redirectUri = redirectUri.replaceAll(
    'http://localhost:8000',
    'https://12ed3568a8de.ngrok-free.app',
  );
}
```

**Pero el backend DEBE redirigir a `estoico://auth/...` después del callback.**

---

## 📋 Checklist Backend

- [ ] **Endpoint `/auth/google/redirect`** devuelve URL con redirect_uri correcto
- [ ] **Endpoint `/auth/google/callback`** recibe el code de Google
- [ ] **Endpoint `/auth/google/callback`** intercambia code por datos de usuario
- [ ] **Endpoint `/auth/google/callback`** crea JWT token
- [ ] **Endpoint `/auth/google/callback`** redirige a `estoico://auth/success?token=...&userId=...`
- [ ] **Google Cloud Console** tiene el redirect_uri autorizado (si es nuevo dominio ngrok)

---

## 🚨 Error Común

Si ves este error:
```
redirect_uri_mismatch
```

Significa que el `redirect_uri` en la petición a Google NO coincide con los URIs autorizados en Google Cloud Console.

**Solución**: Agregar el URI en Google Cloud Console > Credentials > OAuth 2.0 Client ID > Authorized redirect URIs.

---

## ✅ Resumen

**Cambio mínimo necesario en backend**:

```python
# En /auth/google/callback
# Cambiar:
return RedirectResponse(url=f'http://localhost:3000/home?token={token}')

# Por:
return RedirectResponse(url=f'estoico://auth/success?token={token}&userId={user_id}&nombre={nombre}&apellidos={apellidos}&email={email}')
```

**Estado actual de la app**: ✅ Ya reemplaza localhost por ngrok automáticamente

**Siguiente paso**: Modificar el callback del backend para redirigir al deep link de la app.

---

*Fecha: 17 de octubre de 2025*
