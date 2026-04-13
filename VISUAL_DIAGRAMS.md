# 🎨 DIAGRAMA VISUAL DEL PROYECTO

## 1. Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENTE (Navegador Web)                   │
│              http://localhost:8000                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  HTML + CSS + JavaScript                            │   │
│  │  - Interfaz de usuario                              │   │
│  │  - Cálculos dinámicos                               │   │
│  │  - Validaciones cliente                             │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP Request/Response
                     │ JSON/HTML
                     ↓
┌─────────────────────────────────────────────────────────────┐
│               SERVIDOR PHP (Apache/PHP-CLI)                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Archivos PHP (.php)                                │   │
│  │  - index.php (Login)                                │   │
│  │  - invoice_list.php (Listado)                       │   │
│  │  - create_invoice.php (Crear)                       │   │
│  │  - edit_invoice.php (Editar)                        │   │
│  │  - print_invoice.php (PDF)                          │   │
│  │  - action.php (AJAX)                                │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Clase Invoice.php                                  │   │
│  │  - Conexión a BD                                    │   │
│  │  - Consultas SQL                                    │   │
│  │  - Lógica de negocio                                │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  dompdf (Generador de PDFs)                         │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │ SQL Queries
                     │ (mysqli)
                     ↓
┌─────────────────────────────────────────────────────────────┐
│              BASE DE DATOS MySQL                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Database: factura                                  │   │
│  │  ┌─────────────────────────────────────────────┐    │   │
│  │  │ Tabla: invoice_user                         │    │   │
│  │  │ - id, first_name, last_name, email,pwd ... │    │   │
│  │  └─────────────────────────────────────────────┘    │   │
│  │  ┌─────────────────────────────────────────────┐    │   │
│  │  │ Tabla: invoice_order                        │    │   │
│  │  │ - order_id, user_id, totales ...            │    │   │
│  │  └─────────────────────────────────────────────┘    │   │
│  │  ┌─────────────────────────────────────────────┐    │   │
│  │  │ Tabla: invoice_order_item                   │    │   │
│  │  │ - order_item_id, order_id, item_name ...    │    │   │
│  │  └─────────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Flujo de Navegación

```
START
  ↓
┌─────────────────────┐
│   index.php         │
│   (Login Page)      │
└──────┬──────────────┘
       │
       ├─→ Credenciales válidas
       │    ↓
       │  $_SESSION['userid'] = ...
       │    ↓
       │  session_start()
       │
       └─→ Credenciales inválidas
            ↓
          Mensaje error
            ↓
          Vuelve a login
            
       ↓ (Válido)
┌─────────────────────────────────────┐
│  invoice_list.php                   │
│  (Dashboard - Listar Facturas)      │
└──┬────────────────────┬──────┬──────┘
   │                    │      │
   ↓                    ↓      ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Ver Factura  │  │Crear Nueva   │  │Editar        │
│              │  │Factura       │  │Factura       │
│print_invoice │  │              │  │              │
│.php          │  │create_invoice│  │edit_invoice  │
│    ↓         │  │.php          │  │.php          │
│   PDF        │  │    ↓         │  │    ↓         │
│Descarga      │  │  Formulario  │  │ Formulario   │
│              │  │  Dinámico    │  │ Precargado   │
└──────────────┘  │      ↓       │  │      ↓       │
                  │  invoice.js  │  │ invoice.js   │
                  │ - Agregar    │  │ - Modificar  │
                  │   items      │  │   items      │
                  │ - Calcular   │  │ - Recalcular │
                  │   totales    │  │   totales    │
                  │      ↓       │  │      ↓       │
                  │  Guardar ✓   │  │ Actualizar ✓ │
                  │              │  │              │
                  └──────┬───────┘  └──────┬───────┘
                         │                 │
                         └────────┬────────┘
                                  ↓
                    Vuelva a invoice_list.php
                                  ↓
       ┌─────────────────────────────────────┐
       │  ¿Más acciones?                     │
       │  [Ver] [Editar] [Eliminar] [PDF]    │
       │  [Salir]                            │
       └────┬──────────────────────┬─────────┘
            │                      │
            ↓                      ↓
        Más operaciones        action.php
                               (AJAX Delete)
                                  ↓
                          Elimina de BD
                                  ↓
                          Responde JSON
                                  ↓
                          Actualiza tabla
                                  │
                                  ↓
                    Vuelva a invoice_list.php
                                  ↓
                              ┌─────────┐
                              │ [Salir] │
                              └────┬────┘
                                   ↓
                          Destruir sesión
                                   ↓
                            Ir a login
                                   ↓
                                 END
```

---

## 3. Flujo de Datos en Crear Factura

```
┌─────────────────────────────────────────────────────┐
│  CLIENTE (Formulario)                               │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ Cliente:                                    │   │
│  │ ├─ Nombre: [____________]                   │   │
│  │ └─ Dirección: [_________________________]    │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ Items (Tabla dinámica):                     │   │
│  │ ┌──┬─────┬──────┬────┬─────┬────────────┐   │   │
│  │ │✓ │Code │Name  │Qty │Price│Total      │   │   │
│  │ ├──┼─────┼──────┼────┼─────┼────────────┤   │   │
│  │ │  │P001 │Mouse │ 2  │ 15 │   30 ✓ JS │   │   │
│  │ │  │P002 │Board │ 1  │ 50 │   50 ✓ JS │   │   │
│  │ └──┴─────┴──────┴────┴─────┴────────────┘   │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ Cálculos (JavaScript automático):           │   │
│  │ ├─ Subtotal: 80.00                          │   │
│  │ ├─ Tax %:    10                             │   │
│  │ ├─ Tax Amt:  8.00                           │   │
│  │ ├─ Total:    88.00                          │   │
│  │ ├─ Pagado:   100.00                         │   │
│  │ └─ Cambio:   12.00                          │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│          [+ Agregar Item] [- Eliminar]             │
│          [Guardar Factura]                         │
└────────────────┬──────────────────────────────────┘
                 │
                 │ POST con JSON
                 │
                 ↓
┌─────────────────────────────────────────────────────┐
│  SERVIDOR (create_invoice.php)                      │
│                                                     │
│  1. Verifica sesión: checkLoggedIn()                │
│  2. Recibe POST data                                │
│  3. Llama: $invoice->saveInvoice($_POST)            │
│     │                                               │
│     ├─→ INSERT en invoice_order                    │
│     │   ├─ user_id: 1                              │
│     │   ├─ order_receiver_name: "Cliente XYZ"      │
│     │   ├─ order_total_before_tax: 80.00           │
│     │   ├─ order_total_tax: 8.00                   │
│     │   ├─ order_total_after_tax: 88.00            │
│     │   ├─ order_amount_paid: 100.00               │
│     │   ├─ order_total_amount_due: -12.00          │
│     │   └─ created_at: 2026-04-13 14:30:00         │
│     │   ↓ Retorna: order_id = 42                   │
│     │                                               │
│     ├─→ POR CADA ITEM: INSERT en invoice_order_item
│     │   Item 1:                                    │
│     │   ├─ order_id: 42                            │
│     │   ├─ item_code: P001                         │
│     │   ├─ item_name: Mouse                        │
│     │   ├─ order_item_quantity: 2                  │
│     │   ├─ order_item_price: 15.00                 │
│     │   └─ order_item_final_amount: 30.00          │
│     │                                               │
│     │   Item 2:                                    │
│     │   ├─ order_id: 42                            │
│     │   ├─ item_code: P002                         │
│     │   ├─ item_name: Board                        │
│     │   ├─ order_item_quantity: 1                  │
│     │   ├─ order_item_price: 50.00                 │
│     │   └─ order_item_final_amount: 50.00          │
│     │                                               │
│     └─→ ✓ Completado                               │
│                                                     │
│  4. Redirige: header("Location:invoice_list.php")   │
└────────────────┬──────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────┐
│  BASE DE DATOS (factura)                            │
│                                                     │
│  invoice_order:                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │ order_id│user│name       │addr│total│created │   │
│  ├─────────┼────┼───────────┼────┼─────┼────────┤   │
│  │    42   │ 1  │Cliente XYZ│... │88.00│2026... │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  invoice_order_item:                                │
│  ┌──────────────────────────────────────────────┐   │
│  │ id│oid│code│name │qty│price│amount│         │   │
│  ├───┼───┼────┼─────┼───┼─────┼──────┤         │   │
│  │1  │42 │P001│Mouse│2  │15   │30.00 │         │   │
│  │2  │42 │P002│Board│1  │50   │50.00 │         │   │
│  └──────────────────────────────────────────────┘   │
└────────────────┬──────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────┐
│  REDIRECCIÓN A invoice_list.php                      │
│  (Muestra factura recién creada en la tabla)        │
└─────────────────────────────────────────────────────┘
```

---

## 4. Ciclo de Vida de una Factura

```
CREAR
  ↓
┌─────────────────┐      EDITAR
│   Factura      │──→──────┐
│   Borrada     │          ↓
│   (Nueva)     │    ┌─────────────┐
└─────────────────┘    │   Factura  │
         ↑             │ Modificada │
         │             └─────────────┘
         │                    ↓
         │             ┌─────────────┐
         │             │   Factura   │
         └─────────────│  Actualizada │
          (guardar)    └─────────────┘
                              ↓
                       ┌─────────────┐
                       │  Factura    │
                       │  Vigente    │
                       │  (Activa)   │
                       └──────┬──────┘
                              ├─ VER (Vista/Print)
                              ├─ DESCARGAR PDF
                              ├─ EDITAR (Vuelve a Modificada)
                              └─ ELIMINAR
                                      ↓
                              ┌─────────────┐
                              │  Factura    │
                              │  Eliminada  │
                              │  (Borrada)  │
                              └─────────────┘
```

---

## 5. Matriz de Archivos y Responsabilidades

```
                    CREATE  READ  UPDATE DELETE
────────────────────────────────────────────────
index.php             ✓      ✓
invoice_list.php             ✓
create_invoice.php    ✓             ✓
edit_invoice.php             ✓      ✓
print_invoice.php            ✓
action.php                                ✓
Invoice.php           ✓      ✓      ✓     ✓
────────────────────────────────────────────────

Archivos de Layout:
├── inc/header.php    (HTML head, Bootstrap CSS/JS)
├── inc/footer.php    (Cierre de HTML)
├── inc/container.php (Navbar)
├── menu.php          (Menú de opciones)
├── css/style.css     (Estilos personalizados)
└── js/invoice.js     (Lógica interactiva)
```

---

## 6. Estados de Transacción

```
Inicio: Usuario en login
   ↓
[1] Autenticación
   └─→ SELECT en invoice_user
       └─→ ✓ Válido → Crear sesión
       └─→ ✗ Inválido → Error

[2] Listado (READ)
   ├─→ SELECT * FROM invoice_order WHERE user_id = ?
   ├─→ Mostra tabla con todas las facturas
   └─→ 0 filas → "No hay facturas"

[3] Crear (CREATE)
   ├─→ INSERT en invoice_order → order_id = X
   ├─→ N × INSERT en invoice_order_item
   └─→ ✓ Guardado → invoice_list.php

[4] Editar (UPDATE)
   ├─→ SELECT para cargar datos
   ├─→ UPDATE en invoice_order
   ├─→ DELETE items antiguos
   ├─→ N × INSERT items nuevos
   └─→ ✓ Actualizado → invoice_list.php

[5] Eliminar (DELETE - AJAX)
   ├─→ DELETE FROM invoice_order_item WHERE order_id = X
   ├─→ DELETE FROM invoice_order WHERE order_id = X
   ├─→ JSON response: {"status": 1}
   └─→ ✓ JavaScript actualiza tabla

[6] Ver PDF
   ├─→ SELECT para obtener datos
   ├─→ Generar HTML
   ├─→ dompdf(HTML) → PDF
   └─→ Descargar file.pdf
```

---

**Pie de página**: Diagramas generados el 13 de Abril de 2026
