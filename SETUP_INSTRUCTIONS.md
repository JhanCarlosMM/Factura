# ANÁLISIS Y SETUP DEL PROYECTO - Sistema de Facturación

## 📋 Descripción del Proyecto
Sistema básico de facturación en PHP y MySQL que permite:
- ✅ Autenticación de usuarios
- ✅ Crear, editar y eliminar facturas
- ✅ Gestionar ítems en las facturas (productos/servicios)
- ✅ Calcular subtotal, impuestos y totales
- ✅ Generar y descargar PDFs de facturas (usando dompDF)
- ✅ Listar historial de facturas por usuario

## 🏗️ Estructura del Proyecto

```
Factura/
├── index.php              # Login de usuarios
├── invoice_list.php       # Listado de facturas del usuario
├── create_invoice.php     # Crear nueva factura
├── edit_invoice.php       # Editar factura existente
├── print_invoice.php      # Vista de impresión/PDF
├── action.php             # Manejador de acciones AJAX
├── Invoice.php            # Clase principal (lógica de BD)
├── menu.php              # Menú de navegación
├── inc/                  # Inclusos (header, footer, container)
├── css/style.css         # Estilos CSS
├── js/invoice.js         # JavaScript para interacción
├── dompdf/               # Librería para generar PDFs
└── images/              # Imágenes del proyecto
```

## 🗄️ Base de Datos

### Nombre: `factura`

### Tablas:

1. **invoice_user** - Usuarios del sistema
   - `id` (INT) - PK
   - `first_name` (VARCHAR)
   - `last_name` (VARCHAR)
   - `email` (VARCHAR) - UNIQUE
   - `password` (VARCHAR)
   - `address` (VARCHAR)
   - `mobile` (VARCHAR)

2. **invoice_order** - Facturas/Órdenes
   - `order_id` (INT) - PK
   - `user_id` (INT) - FK a invoice_user
   - `order_receiver_name` (VARCHAR)
   - `order_receiver_address` (VARCHAR)
   - `order_total_before_tax` (FLOAT)
   - `order_total_tax` (FLOAT)
   - `order_tax_per` (FLOAT)
   - `order_total_after_tax` (FLOAT)
   - `order_amount_paid` (FLOAT)
   - `order_total_amount_due` (FLOAT)
   - `note` (TEXT)
   - `created_at` (TIMESTAMP)

3. **invoice_order_item** - Items de las facturas
   - `order_item_id` (INT) - PK
   - `order_id` (INT) - FK a invoice_order
   - `item_code` (VARCHAR)
   - `item_name` (VARCHAR)
   - `order_item_quantity` (FLOAT)
   - `order_item_price` (FLOAT)
   - `order_item_final_amount` (FLOAT)

## ⚙️ Requisitos del Sistema

- **PHP**: 7.0+
- **MySQL**: 5.5+
- **Servidor Web**: Apache (con mod_rewrite)
- **Extensiones PHP**: mysqli, PDO

## 🚀 Pasos para Ejecutar

### 1. Configurar la Base de Datos
```sql
-- Importar el archivo database.sql a tu servidor MySQL
-- Ejecutar: mysql -u root < database.sql
```

Usuario de prueba:
- Email: `admin@example.com`
- Contraseña: `123456`

### 2. Configurar Credenciales (Invoice.php)
Modificar líneas 6-9 si es necesario:
```php
private $host  = 'localhost';
private $user  = 'root';
private $password   = "";
private $database  = "factura";
```

### 3. Iniciar Servidor PHP (Opción A - Desarrollo)
```bash
php -S localhost:8000
```

### 4. O usar Apache (Opción B - Producción)
- Copiar carpeta a htdocs
- Acceder a `http://localhost/Factura`

### 5. Acceder a la Aplicación
- URL: `http://localhost:8000`
- Acceder con: admin@example.com / 123456

## ⚠️ Problemas Comunes

### PHP no reconocido
- Instalar PHP WindowsBinaries desde php.net
- Agregar a PATH del sistema

### Error de conexión MySQL
- Verificar que MySQL está en ejecución
- Revisar credenciales en Invoice.php
- Verificar que la base de datos existe

### Error de permisos en PDF
- Crear carpeta `/tmp` o `/uploads` con permisos de escritura

## 🔧 Solución de Seguridad Recomendada

⚠️ **NOTA**: El código tiene vulnerabilidades SQL injection. Para producción, utilizar prepared statements:

```php
// ❌ Actual (inseguro)
$sqlQuery = "SELECT * FROM users WHERE email='" . $email . "'";

// ✅ Recomendado (seguro)
$stmt = $conn->prepare("SELECT * FROM users WHERE email=?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
```

## 📝 Funcionalidades Clave

1. **Login** - Autenticación básica con email/contraseña
2. **Dashboard** - Listado de facturas del usuario autenticado
3. **Crear Factura** - Formulario para crear nueva factura con múltiples items
4. **Editar Factura** - Modificar factura existente
5. **Eliminar Factura** - Borrar factura mediante AJAX
6. **Generar PDF** - Crear PDF descargable usando dompDF
7. **Imprimir** - Vista formateada para impresión

## 🔑 Funciones Principales (Invoice.php)

- `loginUsers()` - Autenticación de usuario
- `saveInvoice()` - Guardar nueva factura
- `updateInvoice()` - Actualizar factura
- `getInvoiceList()` - Lista facturas del usuario
- `getInvoice()` - Obtener detalles de una factura
- `getInvoiceItems()` - Obtener items de una factura
- `deleteInvoice()` - Eliminar factura
- `checkLoggedIn()` - Verificar sesión activa

## 📦 Dependencias Externas

- **dompdf** - Generación de PDFs (incluida en el proyecto)
- **HTML5Lib** - Parser HTML (incluida con dompdf)

---

**Estado**: ✅ Proyecto completo y funcional (requiere PHP y MySQL)
