# API consumida por FINGO Mobile

Este documento describe las solicitudes que el cliente móvil construye actualmente en `lib/`. Refleja el uso observado en el código; no sustituye la especificación del backend ni confirma campos de respuesta que el cliente no valide.

## URL base y transporte

La URL base se obtiene de la variable de compilación `API_BASE_URL`. El valor predeterminado es `https://fingo-backend-eag1.onrender.com`.

`ApiClient` envía `Accept: application/json`; agrega `Content-Type: application/json` cuando hay cuerpo. Las solicitudes autenticadas incluyen `Authorization: Bearer <token>` si hay un token cargado. El tiempo límite por solicitud es 25 segundos. Una respuesta 401 elimina el token de acceso local.

## Rutas

| Método | Ruta | Autenticación | Uso en la aplicación |
| --- | --- | --- | --- |
| `POST` | `/auth/registro` | No | Crear una cuenta. Envía `nombre`, `correo`, `fecha_nacimiento` (`YYYY-MM-DD`) y `password`. |
| `POST` | `/auth/login` | No | Iniciar sesión. Envía `correo` y `password`; el cliente espera `access_token` en la respuesta. |
| `GET` | `/movimientos/` | Sí | Cargar movimientos. Envía `limite=100` y `desplazamiento=0`. |
| `POST` | `/movimientos/` | Sí | Crear un movimiento. Véase el cuerpo de movimiento abajo; el cliente espera `id` en la respuesta. |
| `PUT` | `/movimientos/{id}` | Sí | Actualizar un movimiento existente. |
| `DELETE` | `/movimientos/{id}` | Sí | Eliminar un movimiento existente. |
| `GET` | `/categorias/` | Sí | Cargar categorías financieras. |
| `GET` | `/presupuestos/` | Sí | Listar presupuestos. |
| `POST` | `/presupuestos/` | Sí | Crear un presupuesto. Véase el cuerpo de presupuesto. |
| `PUT` | `/presupuestos/{id}` | Sí | Actualizar un presupuesto. Véase el cuerpo de presupuesto. |
| `DELETE` | `/presupuestos/{id}` | Sí | Eliminar un presupuesto. |

Los prefijos y convenciones de rutas se deben cotejar con el backend antes de cambiarlos.

## Esquemas enviados

### Movimiento

`FinancialMovement.toApiJson()` produce:

```json
{
  "tipo": "ingreso o gasto",
  "monto": "12.34",
  "categoria_id": 1,
  "descripcion": "opcional; null si está vacía",
  "fecha": "YYYY-MM-DD"
}
```

El lector actual de movimientos espera una fila posicional con este orden: `id`, tipo, monto, `categoria_id`, nombre de categoría, descripción y fecha. `tipo` igual a `ingreso` se interpreta como ingreso; cualquier otro valor se interpreta como gasto.

### Presupuesto

`Budget.toApiJson()` produce:

```json
{
  "categoria_id": 1,
  "tipo_periodo": "mensual",
  "fecha_inicio": "YYYY-MM-DD",
  "fecha_fin": "YYYY-MM-DD",
  "monto_limite": "100.00"
}
```

El lector espera un objeto con `id`, `categoria_nombre`, `monto_limite`, `gasto_acumulado`, `categoria_id`, `fecha_inicio`, `fecha_fin`, `tipo_periodo` y `estado`.

## Errores

Las respuestas no exitosas se convierten en `ApiException`, con el código HTTP y el mensaje mostrado por la interfaz. Si el JSON de error contiene `detail` como texto, el cliente lo usa directamente; para otros formatos usa mensajes genéricos. Los errores de conexión y tiempo límite se presentan como errores de conectividad.

## Mantener esta referencia

Cuando cambie una llamada en `ApiClient`, `MovementService`, `BudgetService` o las pantallas de autenticación, actualiza esta tabla y los esquemas correspondientes. Para precisar un contrato, contrástalo con la documentación o implementación vigente del backend; no infieras el formato completo a partir de la conversión parcial del cliente.
