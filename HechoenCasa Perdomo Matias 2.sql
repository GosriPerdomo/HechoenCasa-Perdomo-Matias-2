CREATE DATABASE IF NOT EXISTS HechoEnCasa;
USE HechoEnCasa;
-- creo la tabla para guardar los productos
CREATE TABLE Productos (
    ProductoID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Precio INT NOT NULL,
    Stock INT NOT NULL
);
-- creo la tabla para guardar los clientes
CREATE TABLE Clientes (
    ClienteID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Telefono VARCHAR(20)
);
-- creo la tabla de pedidos
CREATE TABLE Pedidos (
    PedidoID INT AUTO_INCREMENT PRIMARY KEY,
    Fecha TIME NOT NULL,
     ClienteID INT NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);
 -- creo la tabla sobre los detalles de pedido
CREATE TABLE DetallePedido (
    DetalleID INT AUTO_INCREMENT PRIMARY KEY,
    PedidoID INT,
    ProductoID INT,
    Cantidad INT NOT NULL,
    Precio INT NOT NULL,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

INSERT INTO 
hechoencasa.productos (ProductoID,Nombre,Precio,Stock)
VALUES
(NULL, 'Lapicera', 350, 20),
(NULL, 'MarcaPaginas', 200, 20),
(NULL, 'Lapicera Y Marca Paginas', 500, 20),
(NULL, 'Llavero Patita', 200, 15),
(NULL, 'Cenicero naranjas', 500, 20),
(NULL, 'Cenicero Patita', 500, 17),
(NULL, 'Cenicero Beer', 500, 14);

INSERT INTO 
hechoencasa.Clientes(Clienteid,Nombre,Email,Telefono)
VALUES
(NULL, 'Haydon', 'hgoldsbury0@java.com', '+380 689 174 9576'),
(NULL, 'Jody', 'jrickaby1@princeton.edu', '+1 997 951 0002'),
(NULL, 'Shurlock', 'sjeromson2@nytimes.com', '+976 642 616 0547'),
(NULL, 'Hamilton', 'hdraude3@dropbox.com', '+63 175 570 0372'),
(NULL, 'Fons', 'fkield4@sun.com', '+48 116 747 3700'),
(NULL, 'Rheta', 'rwrangle5@360.cn', '+52 156 661 9562');

INSERT INTO HechoEnCasa.Pedidos (Fecha, ClienteID)
VALUES
('2024-03-06 15:00:00', 1), 
('2024-03-07 16:30:00', 2), 
('2024-03-08 17:45:00', 3); 

INSERT INTO HechoEnCasa.DetallePedido (DetalleID,PedidoID, ProductoID, Cantidad, Precio)
VALUES
(NULL,1, 1, 3, 1050),
(NULL,2, 2, 2, 400), 
(NULL,3, 3, 4, 2000); 
-- VIstas

CREATE VIEW ClientesConCantidadPedidos AS
SELECT c.ClienteID, c.Nombre, c.Email, c.Telefono, COUNT(p.PedidoID) AS CantidadPedidos
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.ClienteID;


CREATE VIEW ProductosAgotados AS
SELECT *
FROM Productos
WHERE Stock = 0;

CREATE VIEW ProductosMasVendidos AS
SELECT p.ProductoID, p.Nombre, SUM(dp.Cantidad) AS TotalVendido
FROM Productos p
JOIN DetallePedido dp ON p.ProductoID = dp.ProductoID
GROUP BY p.ProductoID
ORDER BY TotalVendido DESC;

CREATE VIEW ClientesPedidosRecientes AS
SELECT c.ClienteID, c.Nombre AS NombreCliente, p.PedidoID, p.Fecha AS FechaPedido
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.Fecha >= CURRENT_DATE - INTERVAL 7 DAY; 


-- Funciones 

DELIMITER //
CREATE FUNCTION TotalPedidosCliente(ClienteID INT) RETURNS INT
BEGIN
    DECLARE cantidad_pedidos INT;
    SELECT COUNT(*) INTO cantidad_pedidos FROM Pedidos p WHERE p.ClienteID = ClienteID;
    RETURN cantidad_pedidos;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION CalcularTotalPedido(PedidoID INT) RETURNS INT
BEGIN
    DECLARE total INT;
    SELECT SUM(Precio * Cantidad) INTO total
    FROM DetallePedido WHERE PedidoID = PedidoID;
    RETURN total;
END //
DELIMITER ;


--Procedimientos
DELIMITER //
CREATE PROCEDURE ActualizarStock(IN ProductoID INT, IN Cantidad INT)
BEGIN
    UPDATE Productos SET Stock = Stock - Cantidad WHERE ProductoID = ProductoID;
END //;


DELIMITER //
CREATE PROCEDURE AgregarProducto(
    IN NombreProducto VARCHAR(100),
    IN PrecioProducto INT,
    IN StockProducto INT
)
BEGIN
    INSERT INTO Productos (Nombre, Precio, Stock) VALUES (NombreProducto, PrecioProducto, StockProducto);
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE EliminarProducto(IN ProductoID INT)
BEGIN
    DELETE FROM DetallePedido WHERE ProductoID = ProductoID;
    DELETE FROM Productos WHERE ProductoID = ProductoID;
END //
DELIMITER ;

--Triggers
DELIMITER //

CREATE TRIGGER ActualizarStockDespuesVenta
AFTER INSERT ON DetallePedido
FOR EACH ROW

BEGIN
    UPDATE Productos
    SET Stock = Stock - NEW.Cantidad
    WHERE ProductoID = NEW.ProductoID;
END;


