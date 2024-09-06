-- Usar la base de datos master
USE master;
GO

-- Crear la base de datos si no existe
IF NOT EXISTS(SELECT name FROM sys.databases WHERE name = 'DB_AEROLINEA')
BEGIN
    CREATE DATABASE DB_AEROLINEA;
    PRINT 'Base de datos creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La base de datos ya existe';
END
GO

-- Cambiar el contexto a la nueva base de datos
USE DB_AEROLINEA;
GO

-- Crear la tabla de category_customer
IF OBJECT_ID('dbo.category_customer', 'U') IS NULL
BEGIN
    CREATE TABLE category_customer(
        id_category INT PRIMARY KEY,
        category_name VARCHAR(100) NOT NULL UNIQUE, -- Garantiza que no haya categorías con nombres duplicados
        description VARCHAR(100) NOT NULL,
        discount DECIMAL(5,2) NOT NULL CHECK (discount >= 0 AND discount <= 100), -- Asegura que el discount esté entre 0% y 100%,
        creation_date DATE DEFAULT CAST(GETDATE() AS DATE),
        status VARCHAR(10) NOT NULL CHECK (status IN ('Inactive', 'Active')) -- Asegura que el estado sea uno de los valores permitidos
    );
    PRINT 'Tabla category_customer creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla category_customer ya existe';
END
GO

-- Crear la tabla de age_group
IF OBJECT_ID('dbo.age_group', 'U') IS NULL
BEGIN
    CREATE TABLE age_group (
        id_age_group INT PRIMARY KEY,
        age_group_name VARCHAR(20) NOT NULL CHECK (age_group_name IN ('Bebe', 'Niño', 'Adulto', 'Anciano')) -- Asegura que el nombre del grupo de edad sea uno de los valores permitidos
    );
    PRINT 'Tabla age_group creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla age_group ya existe';
END

-- Crear la tabla de customer
IF OBJECT_ID('dbo.customer', 'U') IS NULL
BEGIN
    CREATE TABLE customer (
        id_customer INT PRIMARY KEY,
        date_of_birth DATE NOT NULL CHECK (date_of_birth <= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de nacimiento sea menor o igual a la fecha actual
        Name VARCHAR(100) NOT NULL, 
        id_category_fk INT NOT NULL,
        id_age_group_fk INT NOT NULL,   
        FOREIGN KEY (id_category_fk) REFERENCES category_customer(id_category)
            ON DELETE NO ACTION -- Evita que se eliminen categorías si están en uso
            ON UPDATE CASCADE,   -- Actualiza el campo en caso de cambio en la tabla de categorías
        FOREIGN KEY (id_age_group_fk) REFERENCES age_group(id_age_group)
            ON DELETE NO ACTION -- Evita que se eliminen grupos de edad si están en uso
            ON UPDATE CASCADE   -- Actualiza el campo en caso de cambio en la tabla de grupos de edad
    );
    PRINT 'Tabla customer creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla customer ya existe';
END
GO

-- Crear la tabla de frequent_flyer_card
IF OBJECT_ID('dbo.frequent_flyer_card', 'U') IS NULL
BEGIN
    CREATE TABLE frequent_flyer_card (
    id_frequent_flyer INT PRIMARY KEY,  
    ffc_number VARCHAR(20) NOT NULL UNIQUE, -- Garantiza que no haya números de tarjeta duplicados
    miles INT NOT NULL CHECK (miles >= 0), -- Asegura que las millas sean mayores o iguales a 0
    meal_code VARCHAR(10) NOT NULL UNIQUE, -- Garantiza que no haya códigos de comida duplicados
    id_customer_fk INT NOT NULL,
    FOREIGN KEY (id_customer_fk) REFERENCES customer(id_customer)
        ON DELETE CASCADE -- Elimina la tarjeta de viajero frecuente si se elimina el cliente
        ON UPDATE CASCADE -- Actualiza el cliente si cambia el ID
    );
    PRINT 'Tabla frequent_flyer_card creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla frequent_flyer_card ya existe';
END
GO

-- Crear la tabla de category_ticket
IF OBJECT_ID('dbo.category_ticket', 'U') IS NULL
BEGIN
    CREATE TABLE category_ticket (
        id_category INT PRIMARY KEY,
        category_name VARCHAR(100) NOT NULL,
        description VARCHAR(100) NOT NULL,
        creation_date DATE DEFAULT CAST(GETDATE() AS DATE),
        status VARCHAR(10) NOT NULL CHECK (status IN ('Inactive', 'Active')) -- Asegura que el estado sea uno de los valores permitidos
    );
    PRINT 'Tabla category_ticket creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla category_ticket ya existe';
END
GO

-- Crear la tabla de reservation
IF OBJECT_ID('dbo.reservation', 'U') IS NULL
BEGIN
    CREATE TABLE reservation (
        id_reservation INT PRIMARY KEY,
        reservation_code VARCHAR(20) NOT NULL UNIQUE,
        reservation_date DATE NOT NULL CHECK (reservation_date >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de reserva sea mayor o igual a la fecha actual
        expiration_date DATE NOT NULL CHECK (expiration_date >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de vencimiento sea mayor o igual a la fecha actual
        cancellation_penalty DECIMAL(10,2) DEFAULT 0.00,
        status VARCHAR(20) NOT NULL CHECK (status IN ('Pendiente', 'Confirmado', 'Cancelado')), -- Asegura que el estado de la reserva sea uno de los valores permitidos
        id_customer_fk INT NOT NULL,
        FOREIGN KEY (id_customer_fk) REFERENCES customer(id_customer)
    );
    PRINT 'Tabla reservation creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla reservation ya existe';
END

-- Crear la tabla de ticket
IF OBJECT_ID('dbo.ticket', 'U') IS NULL
BEGIN
    CREATE TABLE ticket (
        id_ticket INT PRIMARY KEY,
        ticketing_code VARCHAR(10) NOT NULL UNIQUE, -- Garantiza que no haya códigos de emisión duplicados
        Number INT NOT NULL CHECK (Number > 0), -- Asegura que el número de boletos sea mayor a 0
        id_customer_fk INT NOT NULL,
        id_category_fk INT NOT NULL,
        id_reservation_fk INT NOT NULL,
        FOREIGN KEY (id_category_fk) REFERENCES category_ticket(id_category)
            ON DELETE NO ACTION -- Evita que se eliminen categorías si están en uso
            ON UPDATE CASCADE, -- Actualiza la categoría si cambia el ID
        FOREIGN KEY (id_customer_fk) REFERENCES customer(id_customer)
            ON DELETE CASCADE -- Elimina el boleto si se elimina el cliente
            ON UPDATE CASCADE, -- Actualiza el cliente si cambia el ID   
        FOREIGN KEY (id_reservation_fk) REFERENCES reservation(id_reservation)
            ON DELETE NO ACTION -- Evita que se eliminen reservas si están en uso
            ON UPDATE CASCADE -- Actualiza la reserva si cambia el ID

    );
    PRINT 'Tabla ticket creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla ticket ya existe';
END
GO

-- Crear la tabla de country
IF OBJECT_ID('dbo.country', 'U') IS NULL
BEGIN
    CREATE TABLE country (
        id_country INT PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        cod_iso char(2) NOT NULL UNIQUE, -- Garantiza que no haya códigos ISO duplicados
        capital VARCHAR(100) NOT NULL 
    );
    PRINT 'Tabla country creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla country ya existe';
END
GO

-- Crear la tabla de city
IF OBJECT_ID('dbo.city', 'U') IS NULL
BEGIN
    CREATE TABLE city(
        id_city INT PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        cod_city CHAR(3) NOT NULL UNIQUE, -- Garantiza que no haya códigos de ciudad duplicados
        id_country_fk INT NOT NULL,
        FOREIGN KEY (id_country_fk) REFERENCES country(id_country)
            ON DELETE CASCADE -- Elimina ciudades si se elimina el país
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id del país

    );
    PRINT 'Tabla city creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla city ya existe';
END
GO

-- Crear la tabla de airport
IF OBJECT_ID('dbo.airport', 'U') IS NULL
BEGIN
    CREATE TABLE airport (
        id_airport INT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        id_city_fk INT NOT NULL,
        FOREIGN KEY (id_city_fk) REFERENCES city(id_city)
            ON DELETE CASCADE -- Elimina aeropuertos si se elimina la ciudad
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id de la ciudad
    );
    PRINT 'Tabla airport creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla airport ya existe';
END
GO

-- Crear la tabla de plane_model
IF OBJECT_ID('dbo.plane_model', 'U') IS NULL
BEGIN
    CREATE TABLE plane_model (
        id_plane_model INT PRIMARY KEY,
        description VARCHAR(100) NOT NULL,
        graphic VARCHAR(10) NOT NULL
    );
    PRINT 'Tabla plane_model creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla plane_model ya existe';
END
GO

-- Crear la tabla de flight_number
IF OBJECT_ID('dbo.flight_number', 'U') IS NULL
BEGIN
    CREATE TABLE flight_number (
        id_flightnum INT PRIMARY KEY,
        departure_time time NOT NULL CHECK (departure_time >= '00:00:00' AND departure_time <= '23:59:59'), -- Asegura que la hora de salida esté en el rango correcto
        description VARCHAR(100) NOT NULL,
        type VARCHAR(50) NOT NULL CHECK (type IN ('Domestic', 'International')), -- Asegura que el tipo de vuelo sea uno de los valores permitidos
        airline VARCHAR(100) NOT NULL,
        id_start_fk INT NOT NULL,
        id_goal_fk INT NOT NULL,
        id_model_fk INT NOT NULL,
        FOREIGN KEY (id_start_fk) REFERENCES airport(id_airport),
        FOREIGN KEY (id_goal_fk) REFERENCES airport(id_airport)
            ON DELETE NO ACTION -- Impide la eliminación del aeropuerto si hay vuelos asociados
            ON UPDATE CASCADE, -- Actualiza la referencia si se actualiza el id del aeropuerto
        FOREIGN KEY (id_model_fk) REFERENCES plane_model(id_plane_model)
            ON DELETE NO ACTION -- Impide la eliminación del modelo si hay vuelos asociados
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id del modelo
    );
    PRINT 'Tabla flight_number creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla flight_number ya existe';
END
GO

-- Crear la tabla de flight
IF OBJECT_ID('dbo.flight', 'U') IS NULL
BEGIN
    CREATE TABLE flight (
        id_flight INT PRIMARY KEY,
        boarding_time TIME NOT NULL CHECK (boarding_time >= '00:00:00' AND boarding_time <= '23:59:59'), -- Asegura que la hora de abordaje esté en el rango correcto
        flight_date DATE NOT NULL CHECK (flight_date >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de vuelo sea mayor o igual a la fecha actual
        gate VARCHAR(10) NOT NULL,
        check_in_counter VARCHAR(10) NOT NULL,
        id_flightnum_fk INT NOT NULL,
        FOREIGN KEY (id_flightnum_fk) REFERENCES flight_number(id_flightnum)
            ON DELETE NO ACTION -- Impide la eliminación del número de vuelo si hay vuelos asociados
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id del número de vuelo
    );
    PRINT 'Tabla flight creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla flight ya existe';
END
GO

-- Crear la tabla de airplane
IF OBJECT_ID('dbo.airplane', 'U') IS NULL
BEGIN
    CREATE TABLE airplane (
        id_airplane INT PRIMARY KEY,
        registration_number VARCHAR(20) NOT NULL UNIQUE, -- Garantiza que no haya números de registro duplicados
        begin_of_operation DATE NOT NULL CHECK (begin_of_operation <= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de inicio de operación sea menor o igual a la fecha actual
        status VARCHAR(10) NOT NULL CHECK (status IN ('Inactive', 'Active')), -- Asegura que el estado sea uno de los valores permitidos
        id_plane_model_fk INT NOT NULL,
        FOREIGN KEY (id_plane_model_fk) REFERENCES plane_model(id_plane_model)
            ON DELETE NO ACTION -- Impide la eliminación del modelo si hay aviones asociados
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id del modelo
    );
    PRINT 'Tabla airplane creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla airplane ya existe';
END
GO

-- Crear la tabla de seat
IF OBJECT_ID('dbo.seat', 'U') IS NULL
BEGIN
    CREATE TABLE seat (
        id_seat INT PRIMARY KEY,
        size VARCHAR(20) NOT NULL CHECK (size IN ('Small', 'Medium', 'Large')), -- Asegura que el tamaño del asiento sea uno de los valores permitidos
        number VARCHAR(10) NOT NULL UNIQUE, -- Garantiza que no haya números de asiento duplicados
        location VARCHAR(20) NOT NULL CHECK (location IN ('Ventana', 'Medio', 'Pasillo')), -- Asegura que la ubicación del asiento sea una de las opciones permitidas 
        id_plane_model_fk INT NOT NULL,
        FOREIGN KEY (id_plane_model_fk) REFERENCES plane_model(id_plane_model)
            ON DELETE NO ACTION -- Impide la eliminación del modelo si hay asientos asociados
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id del modelo
    );
    PRINT 'Tabla seat creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla seat ya existe';
END
GO

-- Crear la tabla de available_seat
IF OBJECT_ID('dbo.available_seat', 'U') IS NULL
BEGIN
    CREATE TABLE available_seat (
        id_availableseat INT PRIMARY KEY,
        id_seat_fk INT NOT NULL,
        id_flight_fk INT NOT NULL,
        FOREIGN KEY (id_seat_fk) REFERENCES seat(id_seat),
        FOREIGN KEY (id_flight_fk) REFERENCES flight(id_flight)
            ON DELETE NO ACTION -- Impide la eliminación del vuelo si hay registros asociados
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id del vuelo
    );
    PRINT 'Tabla available_seat creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla available_seat ya existe';
END
GO

-- Crear la tabla de coupon
IF OBJECT_ID('dbo.coupon', 'U') IS NULL
BEGIN
    CREATE TABLE coupon (
        id_coupon INT PRIMARY KEY,
        date_of_Redemption DATE NOT NULL CHECK (date_of_Redemption >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de canje sea mayor o igual a la fecha actual
        class VARCHAR(20) NOT NULL CHECK (class IN ('Economy', 'Business', 'First')), -- Asegura que la clase del cupón sea una de las opciones permitidas
        standby CHAR(1) NOT NULL CHECK (standby IN ('Y', 'N')), -- Asegura que el estado de espera sea uno de los valores permitidos
        meal_code VARCHAR(10) NOT NULL UNIQUE, -- Garantiza que no haya códigos de comida duplicados
        id_ticket_fk INT NOT NULL,
        id_flight_fk INT NOT NULL,
        id_availableseat_fk INT NOT NULL,
        FOREIGN KEY (id_ticket_fk) REFERENCES ticket(id_ticket)
            ON DELETE NO ACTION -- Impide la eliminación del ticket si hay cupones asociados
            ON UPDATE CASCADE, -- Actualiza la referencia si se actualiza el id del ticket
        FOREIGN KEY (id_flight_fk) REFERENCES flight(id_flight),
        FOREIGN KEY (id_availableseat_fk) REFERENCES available_seat(id_availableseat)
            ON DELETE NO ACTION -- Impide la eliminación del asiento disponible si hay cupones asociados
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id del asiento disponible
    );
    PRINT 'Tabla coupon creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla coupon ya existe';
END
GO

-- Crear la tabla de pieces_of_luggage
IF OBJECT_ID('dbo.pieces_of_luggage', 'U') IS NULL
BEGIN
    CREATE TABLE pieces_of_luggage (
        id_pieces INT PRIMARY KEY,
        number VARCHAR(50) NOT NULL,
        weight DECIMAL(6,2) NOT NULL CHECK (weight >= 0), -- Asegura que el peso sea mayor o igual a 0
        id_coupon_fk INT NOT NULL,
        FOREIGN KEY (id_coupon_fk) REFERENCES coupon(id_coupon)
            ON DELETE NO ACTION -- Impide la eliminación del cupón si hay piezas de equipaje asociadas
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id del cupón
    );
    PRINT 'Tabla pieces_of_luggage creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla pieces_of_luggage ya existe';
END
GO

-- Crear la tabla de payment
IF OBJECT_ID('dbo.payment', 'U') IS NULL
BEGIN
    CREATE TABLE payment (
        id_payment INT PRIMARY KEY,
        payment_date DATE NOT NULL  CHECK (payment_date >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de pago sea mayor o igual a la fecha actual
        expiration_date DATE NOT NULL CHECK (expiration_date >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de vencimiento sea mayor o igual a la fecha actual
        amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0), -- Asegura que el monto sea mayor o igual a 0
        payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('Credit Card', 'Debit Card', 'Cash')), -- Asegura que el método de pago sea uno de los valores permitidos
        Cancellation_fee DECIMAL(10, 2) DEFAULT 0.00, -- tarifa de cancelación
        status VARCHAR(20) NOT NULL CHECK (status IN ('Pendiente', 'Pagado')), -- Asegura que el estado del pago sea uno de los valores permitidos
        id_reservation_fk INT NOT NULL,
        FOREIGN KEY (id_reservation_fk) REFERENCES reservation(id_reservation)
            ON DELETE NO ACTION -- Impide la eliminación de la reserva si hay pagos asociados
            ON UPDATE CASCADE -- Actualiza la referencia si se actualiza el id de la reserva
    );
    PRINT 'Tabla payment creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla payment ya existe';
END

-- crear la tabla boarding pass
IF OBJECT_ID('dbo.boarding_pass', 'U') IS NULL
BEGIN
    CREATE TABLE boarding_pass (
        id_boarding_pass INT PRIMARY KEY,
        issue_date DATE NOT NULL CHECK (issue_date >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de emisión sea mayor o igual a la fecha actual
        id_reservation_fk INT NOT NULL,
        FOREIGN KEY (id_reservation_fk) REFERENCES reservation(id_reservation),
        id_coupon_fk INT NOT NULL,
        FOREIGN KEY (id_coupon_fk) REFERENCES coupon(id_coupon)
            ON DELETE NO ACTION -- Impide la eliminación del cupón si hay pases de abordar asociados
            ON UPDATE CASCADE, -- Actualiza la referencia si se actualiza el id del cupón
        status VARCHAR(20) NOT NULL CHECK (status IN ('Pendiente', 'Emitido')) -- Asegura que el estado del pase de abordar sea uno de los valores permitidos
    );
    PRINT 'Tabla boarding_pass creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla boarding_pass ya existe';
END

----------------------POPULACIÓN DE DATOS----------------------
-- Poblar la tabla category_customer con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.category_customer)
BEGIN
    INSERT INTO category_customer (id_category, category_name, description, discount, status)
    VALUES 
        (1, 'Platinum', 'Clientes con mayor frecuencia de viajes, acceso a salas VIP y servicios exclusivos.', 25.00, 'Active'),
        (2, 'Gold', 'Clientes frecuentes con prioridad en check-in y embarque.', 15.00, 'Active'),
        (3, 'Silver', 'Clientes regulares con acceso a beneficios moderados.', 10.00, 'Active'),
        (4, 'Bronze', 'Clientes con menor frecuencia de viajes, acceso a beneficios básicos.', 5.00, 'Active'),
        (5, 'Inactive Member', 'Clientes que no han viajado en los últimos 12 meses.', 0.00, 'Inactive');
    PRINT 'Datos insertados en la tabla category_customer';
END
ELSE
BEGIN
    PRINT 'La tabla category_customer ya tiene datos';
END
GO

-- Poblar la tabla Age_group con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.age_group)
BEGIN
    INSERT INTO age_group (id_age_group, age_group_name)
    VALUES 
        (1, 'Bebe'),
        (2, 'Niño'),
        (3, 'Adulto'),
        (4, 'Anciano');
    PRINT 'Datos insertados en la tabla age_group';
END
ELSE    
BEGIN
    PRINT 'La tabla age_group ya tiene datos';
END

-- Poblar la tabla customer con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.customer)
BEGIN
    INSERT INTO customer (id_customer, date_of_birth, Name, id_category_fk, id_age_group_fk)
    VALUES
        (1, '1985-05-20', 'John Doe', 1, 3),    -- Adulto, Platinum
        (2, '2010-11-15', 'Jane Smith', 2, 2),  -- Niño, Gold
        (3, '1950-07-10', 'Robert Brown', 3, 4),-- Anciano, Silver
        (4, '1995-12-05', 'Emily Johnson', 4, 3),-- Adulto, Bronze
        (5, '2020-03-25', 'Baby Lee', 4, 1);    -- Bebe, Bronze
    PRINT 'Datos iniciales insertados en la tabla customer';
END
ELSE
BEGIN
    PRINT 'La tabla customer ya tiene datos';
END
GO

-- Poblar la tabla frequent_flyer_card con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.frequent_flyer_card)
BEGIN
    INSERT INTO frequent_flyer_card (id_frequent_flyer, ffc_number, miles, meal_code, id_customer_fk)
    VALUES
        (1, 'FFC123456789', 12000, 'MLC001', 1),  -- Cliente John Doe
        (2, 'FFC987654321', 5000, 'MLC002', 2),   -- Cliente Jane Smith
        (3, 'FFC567890123', 20000, 'MLC003', 3),  -- Cliente Robert Brown
        (4, 'FFC345678901', 8000, 'MLC004', 4),   -- Cliente Emily Johnson
        (5, 'FFC654321098', 0, 'MLC005', 5);      -- Cliente Baby Lee
    PRINT 'Datos iniciales insertados en la tabla frequent_flyer_card';
END
ELSE
BEGIN
    PRINT 'La tabla frequent_flyer_card ya tiene datos';
END
GO

-- Poblar la tabla category_ticket con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.category_ticket)
BEGIN
    INSERT INTO category_ticket (id_category, category_name, description, status)
    VALUES
        (1, 'Economy', 'Boleto de clase económica', 'Active'),
        (2, 'Business', 'Boleto de clase ejecutiva', 'Active'),
        (3, 'First Class', 'Boleto de primera clase', 'Active'),
        (4, 'Premium Economy', 'Boleto de clase económica premium', 'Active');
    PRINT 'Datos iniciales insertados en la tabla category_ticket';
END
ELSE
BEGIN
    PRINT 'La tabla category_ticket ya tiene datos';
END
GO

-- Poblar la tabla reservation con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.reservation)
BEGIN
        INSERT INTO reservation (id_reservation, reservation_code, reservation_date, expiration_date, cancellation_penalty, status, id_customer_fk)
        VALUES
            (1, 'RES001', '2024-09-10', '2024-09-20', 00.00, 'Confirmado', 1),  -- Reserva confirmada para el cliente 1
            (2, 'RES002', '2024-09-15', '2024-09-25', 00.00, 'Pendiente', 2),   -- Reserva pendiente para el cliente 2
            (3, 'RES003', '2024-09-12', '2024-09-22', 40.00, 'Cancelado', 3),   -- Reserva cancelada para el cliente 3
            (4, 'RES004', '2024-09-18', '2024-09-28', 00.00, 'Confirmado', 4),  -- Reserva confirmada para el cliente 4
            (5, 'RES005', '2024-09-22', '2024-10-02', 00.00, 'Pendiente', 5);   -- Reserva pendiente para el cliente 5
    PRINT 'Datos iniciales insertados en la tabla reservation';
END
ELSE
BEGIN
    PRINT 'La tabla reservation ya tiene datos';
END

-- Poblar la tabla ticket con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.ticket)
BEGIN
    INSERT INTO ticket (id_ticket, ticketing_code, Number, id_customer_fk, id_category_fk, id_reservation_fk)
    VALUES
        (1, 'TCKT0001', 1, 1, 1, 1),  -- Cliente John Doe, Boleto Economy
        (2, 'TCKT0002', 2, 2, 2, 2),  -- Cliente Jane Smith, Boleto Business
        (3, 'TCKT0003', 1, 3, 3, 3),  -- Cliente Robert Brown, Boleto First Class
        (4, 'TCKT0004', 3, 4, 4, 4),  -- Cliente Emily Johnson, Boleto Premium Economy
        (5, 'TCKT0005', 1, 5, 1, 5);  -- Cliente Baby Lee, Boleto Economy
    PRINT 'Datos iniciales insertados en la tabla ticket';
END
ELSE
BEGIN
    PRINT 'La tabla ticket ya tiene datos';
END
GO

-- Poblar la tabla country con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.country)
BEGIN
    INSERT INTO country (id_country, name, cod_iso, capital)
    VALUES
        (1, 'United States', 'US', 'Washington D.C.'),
        (2, 'United Kingdom', 'GB', 'London'),
        (3, 'France', 'FR', 'Paris'),
        (4, 'Germany', 'DE', 'Berlin'),
        (5, 'Japan', 'JP', 'Tokyo');
    PRINT 'Datos iniciales insertados en la tabla country';
END
ELSE
BEGIN
    PRINT 'La tabla country ya tiene datos';
END
GO

-- Poblar la tabla city con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.city)
BEGIN
    INSERT INTO city (id_city, name, cod_city, id_country_fk)
    VALUES
        (1, 'New York', 'NYC', 1),    -- Estados Unidos
        (2, 'Los Angeles', 'LAX', 1), -- Estados Unidos
        (3, 'London', 'LON', 2),      -- Reino Unido
        (4, 'Paris', 'PAR', 3),       -- Francia
        (5, 'Berlin', 'BER', 4),      -- Alemania
        (6, 'Tokyo', 'TYO', 5);       -- Japón
    PRINT 'Datos iniciales insertados en la tabla city';
END
ELSE
BEGIN
    PRINT 'La tabla city ya tiene datos';
END
GO

-- Poblar la tabla airport con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.airport)
BEGIN
    INSERT INTO airport (id_airport, name, id_city_fk)
    VALUES
        (1, 'John F. Kennedy International Airport', 1),  -- Nueva York
        (2, 'Los Angeles International Airport', 2),      -- Los Ángeles
        (3, 'Heathrow Airport', 3),                       -- Londres
        (4, 'Charles de Gaulle Airport', 4),              -- París
        (5, 'Berlin Brandenburg Airport', 5),             -- Berlín
        (6, 'Narita International Airport', 6);           -- Tokio
    PRINT 'Datos iniciales insertados en la tabla airport';
END
ELSE
BEGIN
    PRINT 'La tabla airport ya tiene datos';
END
GO

-- Poblar la tabla plane_model con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.plane_model)
BEGIN
    INSERT INTO plane_model (id_plane_model, description, graphic)
    VALUES
        (1, 'Boeing 737', 'B737'),
        (2, 'Airbus A320', 'A320'),
        (3, 'Boeing 777', 'B777'),
        (4, 'Airbus A380', 'A380'),
        (5, 'Boeing 787', 'B787');
    PRINT 'Datos iniciales insertados en la tabla plane_model';
END
ELSE
BEGIN
    PRINT 'La tabla plane_model ya tiene datos';
END
GO

-- Poblar la tabla flight_number con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.flight_number)
BEGIN
    INSERT INTO flight_number (id_flightnum, departure_time, description, type, airline, id_start_fk, id_goal_fk, id_model_fk)
    VALUES
        (1, '08:00:00', 'NYC to LAX Morning Flight', 'Domestic', 'American Airlines', 1, 2, 1), -- JFK to LAX, Boeing 737
        (2, '16:00:00', 'LAX to LON Evening Flight', 'International', 'British Airways', 2, 3, 3), -- LAX to Heathrow, Boeing 777
        (3, '12:30:00', 'LON to PAR Noon Flight', 'International', 'Air France', 3, 4, 2), -- Heathrow to Charles de Gaulle, Airbus A320
        (4, '10:15:00', 'BER to TYO Morning Flight', 'International', 'Lufthansa', 5, 6, 5), -- Berlin to Narita, Boeing 787
        (5, '14:45:00', 'TYO to JFK Afternoon Flight', 'International', 'Japan Airlines', 6, 1, 4); -- Narita to JFK, Airbus A380
    PRINT 'Datos iniciales insertados en la tabla flight_number';
END
ELSE
BEGIN
    PRINT 'La tabla flight_number ya tiene datos';
END
GO

-- Poblar la tabla flight con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.flight)
BEGIN
    INSERT INTO flight (id_flight, boarding_time, flight_date, gate, check_in_counter, id_flightnum_fk)
    VALUES
        (1, '07:30:00', '2024-09-10', 'A1', 'C12', 1), -- Vuelo NYC to LAX
        (2, '15:30:00', '2024-09-15', 'B5', 'D10', 2), -- Vuelo LAX to LON
        (3, '12:00:00', '2024-09-12', 'C3', 'E20', 3), -- Vuelo LON to PAR
        (4, '09:45:00', '2024-09-18', 'D8', 'F15', 4), -- Vuelo BER to TYO
        (5, '14:15:00', '2024-09-22', 'E2', 'G5', 5);  -- Vuelo TYO to JFK
    PRINT 'Datos iniciales insertados en la tabla flight';
END
ELSE
BEGIN
    PRINT 'La tabla flight ya tiene datos';
END
GO

-- Poblar la tabla airplane con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.airplane)
BEGIN
    INSERT INTO airplane (id_airplane, registration_number, begin_of_operation, status, id_plane_model_fk)
    VALUES
        (1, 'N123AA', '2010-05-15', 'Active', 1), -- Boeing 737
        (2, 'G-BA123', '2012-07-20', 'Active', 3), -- Boeing 777
        (3, 'F-AF456', '2015-11-10', 'Active', 2), -- Airbus A320
        (4, 'D-LH789', '2018-03-05', 'Active', 5), -- Boeing 787
        (5, 'JA7890', '2020-08-01', 'Active', 4); -- Airbus A380
    PRINT 'Datos iniciales insertados en la tabla airplane';
END
ELSE
BEGIN
    PRINT 'La tabla airplane ya tiene datos';
END
GO

-- Poblar la tabla seat con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.seat)
BEGIN
    INSERT INTO seat (id_seat, size, number, location, id_plane_model_fk)
    VALUES
        (1, 'Large', '1A', 'Ventana', 1),  -- Asiento 1A, Ventana, Boeing 737
        (2, 'Medium', '2B', 'Medio', 2),   -- Asiento 2B, Medio, Airbus A320
        (3, 'Small', '3C', 'Pasillo', 3),  -- Asiento 3C, Pasillo, Boeing 777
        (4, 'Large', '4D', 'Ventana', 4),  -- Asiento 4D, Ventana, Airbus A380
        (5, 'Medium', '5E', 'Medio', 5);   -- Asiento 5E, Medio, Boeing 787
    PRINT 'Datos iniciales insertados en la tabla seat';
END
ELSE
BEGIN
    PRINT 'La tabla seat ya tiene datos';
END
GO

-- Poblar la tabla available_seat con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.available_seat)
BEGIN
    INSERT INTO available_seat (id_availableseat, id_seat_fk, id_flight_fk)
    VALUES
        (1, 1, 1),  -- Asiento 1A disponible en vuelo 1 (NYC to LAX)
        (2, 2, 2),  -- Asiento 2B disponible en vuelo 2 (LAX to LON)
        (3, 3, 3),  -- Asiento 3C disponible en vuelo 3 (LON to PAR)
        (4, 4, 4),  -- Asiento 4D disponible en vuelo 4 (BER to TYO)
        (5, 5, 5);  -- Asiento 5E disponible en vuelo 5 (TYO to JFK)
    PRINT 'Datos iniciales insertados en la tabla available_seat';
END
ELSE
BEGIN
    PRINT 'La tabla available_seat ya tiene datos';
END
GO

-- Poblar la tabla coupon con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.coupon)
    BEGIN
    INSERT INTO coupon (id_coupon, date_of_Redemption, class, standby, meal_code, id_ticket_fk, id_flight_fk, id_availableseat_fk)
    VALUES
        (1, '2024-09-10', 'Economy', 'N', 'MLC001', 1, 1, 1),  -- Cupón para vuelo 1, Asiento 1A
        (2, '2024-09-15', 'Business', 'Y', 'MLC002', 2, 2, 2), -- Cupón para vuelo 2, Asiento 2B
        (3, '2024-09-12', 'Economy', 'N', 'MLC003', 3, 3, 3),  -- Cupón para vuelo 3, Asiento 3C
        (4, '2024-09-18', 'First', 'N', 'MLC004', 4, 4, 4),    -- Cupón para vuelo 4, Asiento 4D
        (5, '2024-09-22', 'Economy', 'Y', 'MLC005', 5, 5, 5);  -- Cupón para vuelo 5, Asiento 5E
    PRINT 'Datos iniciales insertados en la tabla coupon';
END
ELSE
BEGIN
    PRINT 'La tabla coupon ya tiene datos';
END
GO

-- Poblar la tabla pieces_of_luggage con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.pieces_of_luggage)
BEGIN
    INSERT INTO pieces_of_luggage (id_pieces, number, weight, id_coupon_fk)
    VALUES
        (1, 'LUGG001', 15.50, 1),  -- Equipaje para el cupón 1
        (2, 'LUGG002', 20.00, 2),  -- Equipaje para el cupón 2
        (3, 'LUGG003', 25.75, 3),  -- Equipaje para el cupón 3
        (4, 'LUGG004', 18.30, 4),  -- Equipaje para el cupón 4
        (5, 'LUGG005', 22.10, 5);  -- Equipaje para el cupón 5
    PRINT 'Datos iniciales insertados en la tabla pieces_of_luggage';
END
ELSE
BEGIN
    PRINT 'La tabla pieces_of_luggage ya tiene datos';
END
GO

-- Poblar la tabla payment con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.payment)
BEGIN
    INSERT INTO payment (id_payment, payment_date, expiration_date, amount, payment_method, Cancellation_fee, status, id_reservation_fk)
    VALUES
        (1, '2024-09-10', '2024-09-20', 500.00, 'Credit Card', 00.00, 'Pagado', 1),  -- Pago para la reserva 1
        (2, '2024-09-15', '2024-09-25', 750.00, 'Debit Card', 00.00, 'Pendiente', 2), -- Pago para la reserva 2
        (3, '2024-09-12', '2024-09-22', 1000.00, 'Cash', 40.00, 'Pagado', 3),        -- Pago para la reserva 3
        (4, '2024-09-18', '2024-09-28', 1200.00, 'Credit Card', 00.00, 'Pendiente', 4),-- Pago para la reserva 4
        (5, '2024-09-22', '2024-10-02', 800.00, 'Debit Card', 00.00, 'Pagado', 5);    -- Pago para la reserva 5
    PRINT 'Datos iniciales insertados en la tabla payment';
END
ELSE
BEGIN
    PRINT 'La tabla payment ya tiene datos';
END

-- Poblar la tabla boarding_pass con datos iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.boarding_pass)
BEGIN
    INSERT INTO boarding_pass (id_boarding_pass, issue_date, id_reservation_fk, id_coupon_fk, status)
    VALUES
        (1, '2024-09-10', 1, 1, 'Emitido'),  -- Pase de abordar para la reserva 1
        (2, '2024-09-15', 2, 2, 'Pendiente'), -- Pase de abordar para la reserva 2
        (3, '2024-09-12', 3, 3, 'Emitido'),  -- Pase de abordar para la reserva 3
        (4, '2024-09-18', 4, 4, 'Pendiente'), -- Pase de abordar para la reserva 4
        (5, '2024-09-22', 5, 5, 'Emitido');  -- Pase de abordar para la reserva 5
    PRINT 'Datos iniciales insertados en la tabla boarding_pass';
END
ELSE
BEGIN
    PRINT 'La tabla boarding_pass ya tiene datos';
END