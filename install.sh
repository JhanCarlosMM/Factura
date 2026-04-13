#!/bin/bash
# Script para instalar y ejecutar el Sistema de Facturación en Linux/Windows Bash

echo "=========================================="
echo "   Sistema de Facturación - Instalación"
echo "=========================================="

# Verificar requisitos
echo ""
echo "Verificando requisitos..."

# Verificar PHP
if ! command -v php &> /dev/null; then
    echo "❌ PHP no está instalado"
    echo "Instala PHP desde: https://www.php.net/downloads"
    exit 1
else
    PHP_VERSION=$(php -v | head -n 1)
    echo "✅ PHP encontrado: $PHP_VERSION"
fi

# Verificar MySQL
if ! command -v mysql &> /dev/null; then
    echo "⚠️  MySQL client no encontrado (pero podrías tener MySQL Server)"
else
    MYSQL_VERSION=$(mysql --version)
    echo "✅ MySQL encontrado: $MYSQL_VERSION"
fi

echo ""
echo "Preparando base de datos..."

# Crear script SQL
cat > /tmp/setup_factura.sql << 'EOF'
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS factura;
USE factura;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS invoice_user (
  id INT(11) PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(100),
  password VARCHAR(100),
  address VARCHAR(255),
  mobile VARCHAR(20),
  UNIQUE KEY unique_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Tabla de órdenes/facturas
CREATE TABLE IF NOT EXISTS invoice_order (
  order_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  user_id INT(11),
  order_receiver_name VARCHAR(255),
  order_receiver_address VARCHAR(500),
  order_total_before_tax FLOAT,
  order_total_tax FLOAT,
  order_tax_per FLOAT,
  order_total_after_tax FLOAT,
  order_amount_paid FLOAT,
  order_total_amount_due FLOAT,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES invoice_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Tabla de ítems de órdenes
CREATE TABLE IF NOT EXISTS invoice_order_item (
  order_item_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  order_id INT(11),
  item_code VARCHAR(50),
  item_name VARCHAR(255),
  order_item_quantity FLOAT,
  order_item_price FLOAT,
  order_item_final_amount FLOAT,
  FOREIGN KEY (order_id) REFERENCES invoice_order(order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Insertar usuario de prueba
INSERT INTO invoice_user (first_name, last_name, email, password, address, mobile) VALUES
('Admin', 'User', 'admin@example.com', '123456', '123 Main Street', '555-0000');
EOF

echo ""
echo "Ejecutando script SQL..."
echo "Comando a ejecutar:"
echo "mysql -u root < /tmp/setup_factura.sql"
echo ""
echo "Ingresa tu contraseña de MySQL cuando se te pida (si tiene):"
mysql -u root < /tmp/setup_factura.sql 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Base de datos instalada exitosamente"
else
    echo "⚠️  Podría haber error de autenticación MySQL"
    echo "Intenta manualmente:"
    echo "  mysql -u root -p < /tmp/setup_factura.sql"
fi

echo ""
echo "=========================================="
echo "   Iniciando Servidor PHP"
echo "=========================================="
echo ""
echo "Accede a: http://localhost:8000"
echo "Email: admin@example.com"
echo "Contraseña: 123456"
echo ""
echo "Presiona Ctrl+C para detener el servidor"
echo ""

php -S localhost:8000
