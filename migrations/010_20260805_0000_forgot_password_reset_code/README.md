# forgot_password_reset_code

Reemplaza el flujo roto de "recuperar contraseña" (`POST /auth/2AF`, que mandaba el código de
verificación por email PERO también lo devolvía en la misma respuesta HTTP, y no tenía forma de
verificarlo en el servidor — el móvil comparaba el código contra ese valor filtrado, puramente en
cliente). El nuevo flujo (`POST /auth/forgot-password` + `POST /auth/reset-password`) necesita un
lugar para guardar el código pendiente de verificación, hasheado (nunca en texto plano, mismo
patrón que la contraseña) y con expiración.

Agrega a `users`:
- `reset_code_hash VARCHAR(255) NULL` — hash bcrypt del código de 6 dígitos vigente (NULL si no hay
  ninguno pendiente).
- `reset_code_expires_at TIMESTAMP NULL` — vencimiento del código (ambos campos se limpian al
  usarse o al pedir uno nuevo).

PARA REVERTIR: ejecutar down.sql de esta misma carpeta.
