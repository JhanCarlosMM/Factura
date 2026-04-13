@ECHO OFF
REM Script para instalar y ejecutar el Sistema de Facturación en Windows

SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ==========================================
ECHO.   Sistema de Facturación - Instalación
ECHO ==========================================
ECHO.

REM Verificar PHP
WHERE php >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO ❌ PHP no está en el PATH
    ECHO.
    ECHO Descarga PHP desde: https://www.php.net/downloads
    ECHO Descomprime y configura:
    ECHO   1. Descomprime PHP en C:\php (ej: C:\php\php.exe)
    ECHO   2. Abre Variables de Entorno del Sistema
    ECHO   3. Edita la variable PATH
    ECHO   4. Agrega: C:\php
    ECHO   5. Reinicia el IDE/Terminal
    ECHO.
    PAUSE
    EXIT /B 1
)

ECHO ✅ PHP encontrado
php -v

ECHO.
ECHO Preparando base de datos...
ECHO.

REM Crear script SQL
(
    ECHO -- Crear base de datos
    ECHO CREATE DATABASE IF NOT EXISTS factura;
    ECHO USE factura;
    ECHO.
    ECHO -- Tabla de usuarios
    ECHO CREATE TABLE IF NOT EXISTS invoice_user (
    ECHO   id INT(11) PRIMARY KEY AUTO_INCREMENT,
    ECHO   first_name VARCHAR(100),
    ECHO   last_name VARCHAR(100),
    ECHO   email VARCHAR(100),
    ECHO   password VARCHAR(100),
    ECHO   address VARCHAR(255),
    ECHO   mobile VARCHAR(20),
    ECHO   UNIQUE KEY unique_email (email)
    ECHO ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ECHO.
    ECHO -- Tabla de órdenes/facturas
    ECHO CREATE TABLE IF NOT EXISTS invoice_order (
    ECHO   order_id INT(11) PRIMARY KEY AUTO_INCREMENT,
    ECHO   user_id INT(11),
    ECHO   order_receiver_name VARCHAR(255),
    ECHO   order_receiver_address VARCHAR(500),
    ECHO   order_total_before_tax FLOAT,
    ECHO   order_total_tax FLOAT,
    ECHO   order_tax_per FLOAT,
    ECHO   order_total_after_tax FLOAT,
    ECHO   order_amount_paid FLOAT,
    ECHO   order_total_amount_due FLOAT,
    ECHO   note TEXT,
    ECHO   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ECHO   FOREIGN KEY (user_id) REFERENCES invoice_user(id)
    ECHO ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ECHO.
    ECHO -- Tabla de ítems de órdenes
    ECHO CREATE TABLE IF NOT EXISTS invoice_order_item (
    ECHO   order_item_id INT(11) PRIMARY KEY AUTO_INCREMENT,
    ECHO   order_id INT(11),
    ECHO   item_code VARCHAR(50),
    ECHO   item_name VARCHAR(255),
    ECHO   order_item_quantity FLOAT,
    ECHO   order_item_price FLOAT,
    ECHO   order_item_final_amount FLOAT,
    ECHO   FOREIGN KEY (order_id) REFERENCES invoice_order(order_id)
    ECHO ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ECHO.
    ECHO -- Insertar usuario de prueba
    ECHO INSERT INTO invoice_user (first_name, last_name, email, password, address, mobile) VALUES
    ECHO ('Admin', 'User', 'admin@example.com', '123456', '123 Main Street', '555-0000');
) > %TEMP%\setup_factura.sql

ECHO Ejecutando script SQL...
ECHO.
ECHO Comando a ejecutar:
ECHO mysql -u root %TEMP%\setup_factura.sql
ECHO.
ECHO Si MySQL pide contraseña, ingresa la tuya (o presiona Enter si no tiene)
ECHO.

mysql -u root < %TEMP%\setup_factura.sql

IF %ERRORLEVEL% EQU 0 (
    ECHO.
    ECHO ✅ Base de datos instalada exitosamente
) ELSE (
    ECHO.
    ECHO ⚠️  Error al ejecutar MySQL
    ECHO Asegúrate de que:
    ECHO   1. MySQL Server está ejecutándose
    ECHO   2. El usuario 'root' existe
    ECHO   3. mysql.exe está en el PATH
    ECHO.
    PAUSE
)

ECHO.
ECHO ==========================================
ECHO.   Iniciando Servidor PHP
ECHO ==========================================
ECHO.
ECHO Accede a: http://localhost:8000
ECHO Email: admin@example.com
ECHO Contraseña: 123456
ECHO.
ECHO Presiona Ctrl+C para detener el servidor
ECHO.

php -S localhost:8000

PAUSE
