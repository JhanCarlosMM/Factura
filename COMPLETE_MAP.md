# 📊 MAPA COMPLETO DEL PROYECTO - Sistema de Facturación

## 🌳 Estructura de Archivos y Funciones

```
FACTURA/
├── 📄 Archivos Principales
│   ├── index.php                  ➜ Página de login
│   ├── Invoice.php                ➜ Clase principal (conexión BD)
│   ├── invoice_list.php           ➜ Listado de facturas del usuario
│   ├── create_invoice.php         ➜ Crear nueva factura
│   ├── edit_invoice.php           ➜ Editar factura existente
│   ├── print_invoice.php          ➜ Vista de impresión/PDF
│   ├── action.php                 ➜ Manejador AJAX (delete)
│   ├── menu.php                   ➜ Menú de navegación
│   │
│   ├── 📁 inc/                    ➜ Componentes reutilizables
│   │   ├── header.php             ➜ <!DOCTYPE>, meta, CSS, JS
│   │   ├── footer.php             ➜ Cierre de HTML
│   │   └── container.php          ➜ Navbar Bootstrap
│   │
│   ├── 📁 css/
│   │   └── style.css              ➜ Estilos personalizados
│   │
│   ├── 📁 js/
│   │   └── invoice.js             ➜ Cálculos, AJAX, validaciones
│   │
│   ├── 📁 dompdf/                 ➜ Librería para PDFs
│   │   ├── src/Dompdf.php
│   │   └── lib/fonts/
│   │
│   └── 📁 images/                 ➜ Imagenes (favicon, etc)
```

---

## 🔄 FLUJO DE LA APLICACIÓN

### 1️⃣ INICIO (index.php)
```
Usuario accede → http://localhost:8000
                ↓
        [Formulario de Login]
        Email / Contraseña
                ↓
        invoice->loginUsers()
                ↓
        Valida en BD (invoice_user)
                ↓
        Si OK → Crea $_SESSION → Redirige a invoice_list.php
        Si NO → Mensaje de error
```

### 2️⃣ LISTA DE FACTURAS (invoice_list.php)
```
Usuario autenticado
        ↓
checkLoggedIn() verifca sesión
        ↓
getInvoiceList() obtiene facturas
        ↓
Muestra tabla con todas las facturas
                ↓
Opciones: [Ver] [Editar] [Eliminar] [PDF] [Salir]
```

### 3️⃣ CREAR FACTURA (create_invoice.php)
```
Usuario hace click "Nueva Factura"
        ↓
        [Formulario Dinámico]
        - Cliente (nombre, dirección)
        - Tabla de items (agregable)
        - Cálculos automáticos (JS)
        - Impuestos y totales
        ↓
Usuario ingresa datos
        ↓
JavaScript calcula automáticamente:
        - Total por item = cantidad × precio
        - Subtotal = suma totales
        - Impuestos = subtotal × % tax
        - Total = subtotal + impuestos
        - Cambio = pago - total
        ↓
Usuario hace click "Guardar"
        ↓
saveInvoice() inserta en BD:
        - invoice_order (1 registro)
        - invoice_order_item (N registros)
        ↓
Redirige a invoice_list.php
```

### 4️⃣ EDITAR FACTURA (edit_invoice.php)
```
Usuario hace click "Editar" en tabla
        ↓
Obtiene ID de la factura
        ↓
getInvoice() carga datos principales
        getInvoiceItems() carga items
        ↓
Muestra formulario pre-llenado
        ↓
Usuario modifica datos
        ↓
updateInvoice():
        - UPDATE en invoice_order
        - DELETE todos items antiguos
        - INSERT items nuevos
        ↓
Vuelve a invoice_list.php
```

### 5️⃣ VER PDF (print_invoice.php)
```
Usuario hace click "Descargar PDF" o "Ver"
        ↓
Carga factura con getInvoice()
        ↓
Genera HTML formateado
        ↓
dompdf genera PDF
        ↓
Descarga o visualiza en navegador
```

### 6️⃣ ELIMINAR FACTURA (AJAX)
```
Usuario hace click "Eliminar"
        ↓
Confirmación JavaScript
        ↓
AJAX POST a action.php
        ↓
action.php procesa:
        deleteInvoice(id)
        - DELETE de invoice_order_item
        - DELETE de invoice_order
        ↓
AJAX responde con JSON
        ↓
JavaScript actualiza tabla
```

### 7️⃣ LOGOUT
```
Usuario hace click "Salir"
        ↓
action.php: $_GET['action'] == 'logout'
        ↓
Destruye sesión
        ↓
Redirige a index.php
```

---

## 💾 CICLO DE DATOS

```
┌─────────────────────────────────────────────────┐
│         CLIENTE (Usuario Autenticado)            │
└────────────────┬────────────────────────────────┘
                 │
                 ↓ Envía datos
         ┌───────────────────┐
         │   API PHP (action)│
         │   create_invoice  │
         │   edit_invoice    │
         │   print_invoice   │
         └────────┬──────────┘
                  │
                  ↓ Procesa
         ┌─────────────────────┐
         │  CLASE Invoice      │
         │ - saveInvoice()     │
         │ - updateInvoice()   │
         │ - deleteInvoice()   │
         │ - getInvoice()      │
         └────────┬────────────┘
                  │
                  ↓ Queries
         ┌──────────────────────────┐
         │    BASE DE DATOS MySQL   │
         │ ┌──────────────────────┐ │
         │ │ invoice_user         │ │
         │ │ invoice_order        │ │
         │ │ invoice_order_item   │ │
         │ └──────────────────────┘ │
         └────────┬─────────────────┘
                  │
                  ↓ Retorna datos
         ┌──────────────────────┐
         │ Archivo PHP          │
         │ (genera HTML/JSON)   │
         └────────┬─────────────┘
                  │
                  ↓ Envía al cliente
         ┌──────────────────────────┐
         │ Cliente recibe:          │
         │ - HTML (UI)              │
         │ - JSON (respuestas AJAX) │
         │ - PDF (descarga)         │
         └──────────────────────────┘
```

---

## 🎯 FUNCIONES CRÍTICAS POR ARCHIVO

### **Invoice.php** (Clase principal)
```php
✅ __construct()              Conecta a BD
✅ getData($sql)              Ejecuta SELECT
✅ getNumRows($sql)           Cuenta filas
✅ loginUsers($email, $pwd)   Autentica usuario
✅ saveInvoice($data)         Guarda factura + items
✅ updateInvoice($data)       Actualiza factura
✅ getInvoiceList()           Lista facturas del usuario
✅ getInvoice($id)            Obtiene detalles
✅ getInvoiceItems($id)       Obtiene items
✅ deleteInvoice($id)         Borra factura + items
✅ checkLoggedIn()            Verifica sesión
```

### **invoice.js** (Funciones JavaScript)
```js
✅ calculateTotal()           Calcula subtotal, impuestos, total
✅ addRows()                  Agrega fila a tabla de items
✅ removeRows()               Elimina filas seleccionadas
✅ deleteInvoice(id)          AJAX para eliminar
```

### **header.php**
```html
✅ Meta tags
✅ Bootstrap CSS/JS
✅ jQuery
✅ Favicon
```

---

## 📋 CONSULTAS SQL GENERADAS

### Login
```sql
SELECT id, email, first_name, last_name, address, mobile 
FROM invoice_user 
WHERE email='admin@example.com' AND password='123456'
```

### Listar facturas
```sql
SELECT * FROM invoice_order 
WHERE user_id = 1
```

### Guardar factura
```sql
INSERT INTO invoice_order(user_id, order_receiver_name, ...)
VALUES (1, 'Cliente XYZ', ...)

INSERT INTO invoice_order_item(order_id, item_code, ...)
VALUES (1, 'PROD001', ...)
```

### Obtener detalles
```sql
SELECT * FROM invoice_order 
WHERE user_id = 1 AND order_id = 5

SELECT * FROM invoice_order_item 
WHERE order_id = 5
```

### Eliminar
```sql
DELETE FROM invoice_order_item WHERE order_id = 5
DELETE FROM invoice_order WHERE order_id = 5
```

---

## 🚀 STACK TECNOLÓGICO

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| Backend | PHP | 7.0+ |
| Base de Datos | MySQL | 5.5+ |
| Frontend | HTML5 | - |
| Estilos | Bootstrap | 3.3.5 |
| Interactividad | jQuery | 2.1.3 |
| Generador PDF | dompdf | Incluida |
| Servidor | Apache PHP | - |

---

## 📱 Especificaciones de la Interfaz

### Responsive Design
- ✅ Bootstrap grid (col-xs, col-sm, col-md, col-lg)
- ✅ Tablas responsivas
- ✅ Formularios adaptables

### Componentes UI
- ✅ Navbars Bootstrap
- ✅ Modales (posible con JS)
- ✅ Tablas con checkbox para seleccionar
- ✅ Formularios dinámicos

### Campos de Entrada
```
Factura:
├── Cliente
│   ├── Nombre (text)
│   └── Dirección (textarea)
├── Items (dinámicos)
│   ├── Código (text)
│   ├── Nombre (text)
│   ├── Cantidad (number)
│   ├── Precio (number)
│   └── Total calculado (number)
└── Totales
    ├── Subtotal
    ├── % Impuesto
    ├── Monto Impuesto
    ├── Total
    ├── Monto Pagado
    └── Cambio
```

---

## 🔌 PUNTOS DE INTEGRACIÓN

### Con Base de Datos
- Se conecta automáticamente en `__construct()`
- Simula connection pooling

### Con Frontend
- AJAX para operaciones asincrónicas
- JSON para respuestas

### Con PDFgen
- dompdf convierte HTML a PDF
- Se carga en `print_invoice.php`

---

**Última actualización**: 13 Abril 2026
