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
);

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
);

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
);

-- Insertar usuario de prueba (email: admin@example.com, password: 123456)
INSERT INTO invoice_user (first_name, last_name, email, password, address, mobile) VALUES
('Admin', 'User', 'admin@example.com', '123456', '123 Main Street', '555-0000');
