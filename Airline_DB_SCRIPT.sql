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
        id_category INT PRIMARY KEY IDENTITY (1,1),
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

-- Crear la tabla de customer
IF OBJECT_ID('dbo.customer', 'U') IS NULL
BEGIN
    CREATE TABLE customer (
        id_customer INT PRIMARY KEY IDENTITY(1,1),
        date_of_birth DATE NOT NULL CHECK (date_of_birth <= CAST(GETDATE() AS DATE)), 
        [Name] VARCHAR(100) NOT NULL,
        id_category_fk INT NOT NULL,
        FOREIGN KEY (id_category_fk) REFERENCES category_customer(id_category)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla customer creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla customer ya existe';
END
GO

--  Crear el índice idx_customer_category en la tabla customer
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.customer') 
      AND name = 'idx_customer_category'
)
BEGIN
    CREATE INDEX idx_customer_category 
    ON customer(id_category_fk);
    PRINT 'Índice idx_customer_category creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_customer_category ya ha sido creado'; 
END
GO


-- Crear la tabla de frequent_flyer_card
IF OBJECT_ID('dbo.frequent_flyer_card', 'U') IS NULL
BEGIN
    CREATE TABLE frequent_flyer_card (
        id_frequent_flyer INT PRIMARY KEY IDENTITY(1,1),  
        ffc_number VARCHAR(20) NOT NULL UNIQUE, 
        miles INT NOT NULL CHECK (miles >= 0),
        meal_code VARCHAR(10) NOT NULL UNIQUE,
        id_customer_fk INT NOT NULL,
        FOREIGN KEY (id_customer_fk) REFERENCES customer(id_customer)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla frequent_flyer_card creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla frequent_flyer_card ya existe';
END
GO

-- Crear el índice idx_frequent_flyer_customer en la tabla frequent_flyer_card
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.frequent_flyer_card') 
      AND name = 'idx_frequent_flyer_customer'
)
BEGIN
    CREATE INDEX idx_frequent_flyer_customer 
    ON frequent_flyer_card(id_customer_fk);
    PRINT 'Índice idx_frequent_flyer_customer creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_frequent_flyer_customer ya ha sido creado'; 
END
GO

-- Crear la tabla de category_ticket
IF OBJECT_ID('dbo.category_ticket', 'U') IS NULL
BEGIN
    CREATE TABLE category_ticket (
        id_category INT PRIMARY KEY IDENTITY (1,1),
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
        id_reservation INT PRIMARY KEY IDENTITY(1,1),
        reservation_code VARCHAR(20) NOT NULL UNIQUE,
        reservation_date DATE NOT NULL CHECK (reservation_date >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de reserva sea mayor o igual a la fecha actual
        expiration_date DATE NOT NULL CHECK (expiration_date >= CAST(GETDATE() AS DATE)), -- Asegura que la fecha de vencimiento sea mayor o igual a la fecha actual
        status VARCHAR(20) NOT NULL CHECK (status IN ('Pendiente', 'Confirmado', 'Cancelado')), -- Asegura que el estado de la reserva sea uno de los valores permitidos
        id_customer_fk INT NOT NULL,
        FOREIGN KEY (id_customer_fk) REFERENCES customer(id_customer)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla reservation creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla reservation ya existe';
END

-- Crear el índice idx_reservation_customer en la tabla reservation
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.reservation') 
      AND name = 'idx_reservation_customer'
)
BEGIN
    CREATE INDEX idx_reservation_customer 
    ON reservation(id_customer_fk);
    PRINT 'Índice idx_reservation_customer creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_reservation_customer ya ha sido creado'; 
END
GO

-- crear la tabla de payment
IF OBJECT_ID('dbo.payment', 'U') IS NULL    
BEGIN
    CREATE TABLE payment (
        payment_id INT PRIMARY KEY IDENTITY(1,1),  -- Clave primaria con auto incremento
        amount FLOAT NOT NULL                      -- Monto total del pago
    );
    PRINT 'Tabla payment creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla payment ya existe';
END

-- crar la tabla cash
IF OBJECT_ID('dbo.cash', 'U') IS NULL
BEGIN
    CREATE TABLE cash (
        payment_id INT PRIMARY KEY,                -- Clave primaria y clave foránea de payment
        cash_tendered FLOAT NOT NULL,               -- Monto en efectivo entregado
        FOREIGN KEY (payment_id) REFERENCES payment(payment_id)  -- Relación de herencia
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla cash creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla cash ya existe';
END

-- crear la tabla check
IF OBJECT_ID('dbo.check', 'U') IS NULL
BEGIN
    CREATE TABLE [check] (
        payment_id INT PRIMARY KEY,                -- Clave primaria y clave foránea de payment
        [name] VARCHAR(100) NOT NULL,                -- Nombre del titular del cheque
        bankID VARCHAR(50) NOT NULL,               -- ID del banco
        FOREIGN KEY (payment_id) REFERENCES payment(payment_id)  -- Relación de herencia
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla check creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla check ya existe';
END

-- crear la tabla credit
IF OBJECT_ID('dbo.credit', 'U') IS NULL
BEGIN
    CREATE TABLE Credit (
        payment_id INT PRIMARY KEY,                -- Clave primaria y clave foránea de payment
        [name] VARCHAR(100) NOT NULL,                -- Nombre del titular de la tarjeta
        [type] VARCHAR(50) NOT NULL,                 -- Tipo de tarjeta (ej. Visa, MasterCard)
        expDate DATE NOT NULL,                     -- Fecha de vencimiento de la tarjeta
        FOREIGN KEY (payment_id) REFERENCES payment(payment_id)  -- Relación de herencia
            ON DELETE CASCADE
            ON UPDATE CASCADE 
    );
    PRINT 'Tabla credit creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla credit ya existe';
END

-- crear la tabla passenger
IF OBJECT_ID('dbo.passenger', 'U') IS NULL
BEGIN
    CREATE TABLE passenger (
        id_passenger INT PRIMARY KEY IDENTITY(1,1),
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        date_of_birth DATE NOT NULL CHECK (date_of_birth <= CAST(GETDATE() AS DATE)), 
        id_reservation_fk INT NOT NULL,
        FOREIGN KEY (id_reservation_fk) REFERENCES reservation(id_reservation)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla passenger creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla passenger ya existe';
END
-- Crear el índice idx_passenger_reservation en la tabla passenger
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.passenger') 
      AND name = 'idx_passenger_reservation'
)
BEGIN
    CREATE INDEX idx_passenger_reservation 
    ON passenger(id_reservation_fk);
    PRINT 'Índice idx_passenger_reservation creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_passenger_reservation ya ha sido creado'; 
END
GO

-- Crear la tabla de document passenger
IF OBJECT_ID('dbo.document_passenger', 'U') IS NULL
BEGIN
    CREATE TABLE document_passenger (
        id_document INT PRIMARY KEY IDENTITY(1,1),
        document_number VARCHAR(20) NOT NULL UNIQUE, 
        document_type VARCHAR(20) NOT NULL CHECK (document_type IN ('DNI', 'Passport', 'Carnet de Extranjería')), 
        expiration_date DATE NOT NULL CHECK (expiration_date >= CAST(GETDATE() AS DATE)), 
        id_passenger_fk INT NOT NULL,
        FOREIGN KEY (id_passenger_fk) REFERENCES passenger(id_passenger)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla document_passenger creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla document_passenger ya existe';
END

-- Crear el índice idx_document_passenger en la tabla document_passenger
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.document_passenger') 
      AND name = 'idx_document_passenger'
)
BEGIN
    CREATE INDEX idx_document_passenger 
    ON document_passenger(id_passenger_fk);
    PRINT 'Índice idx_document_passenger creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_document_passenger ya ha sido creado'; 
END
GO

-- Crear la tabla de ticket
IF OBJECT_ID('dbo.ticket', 'U') IS NULL
BEGIN
    CREATE TABLE ticket (
        id_ticket INT PRIMARY KEY IDENTITY(1,1),
        ticketing_code VARCHAR(10) NOT NULL UNIQUE,
        [Number] INT NOT NULL CHECK (Number > 0), 
        id_category_fk INT NOT NULL,
        FOREIGN KEY (id_category_fk) REFERENCES category_ticket(id_category),
        id_reservation_fk INT NOT NULL,
        FOREIGN KEY (id_reservation_fk) REFERENCES reservation(id_reservation)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla ticket creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla ticket ya existe';
END
GO

-- Crear el índice idx_ticket_reservation en la tabla ticket
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.ticket') 
      AND name = 'idx_ticket_reservation'
)
BEGIN
    CREATE INDEX idx_ticket_reservation 
    ON ticket(id_reservation_fk);
    PRINT 'Índice idx_ticket_reservation creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_ticket_reservation ya ha sido creado'; 
END
GO

-- crear la tabla de check_in
IF OBJECT_ID('dbo.check_in', 'U') IS NULL
BEGIN
    CREATE TABLE check_in (
        id_checkin INT PRIMARY KEY IDENTITY(1,1),
        time_checkin TIME NOT NULL,
        id_passenger_fk INT NOT NULL,
        FOREIGN KEY (id_passenger_fk) REFERENCES passenger(id_passenger),
        id_ticket_fk INT NOT NULL,
        FOREIGN KEY (id_ticket_fk) REFERENCES ticket(id_ticket)
    );
    PRINT 'Tabla check_in creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla check_in ya existe';
END

-- Verificar y crear el índice idx_checkin_passenger si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.check_in') 
      AND name = 'idx_checkin_passenger'
)
BEGIN
    CREATE INDEX idx_checkin_passenger 
    ON check_in(id_passenger_fk);
    PRINT 'Índice idx_checkin_passenger creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_checkin_passenger ya ha sido creado'; 
END
GO

-- Verificar y crear el índice idx_checkin_ticket si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.check_in') 
      AND name = 'idx_checkin_ticket'
)
BEGIN
    CREATE INDEX idx_checkin_ticket 
    ON check_in(id_ticket_fk);
    PRINT 'Índice idx_checkin_ticket creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_checkin_ticket ya ha sido creado'; 
END
GO

-- Crear la tabla de baggage
IF OBJECT_ID('dbo.baggage', 'U') IS NULL
BEGIN
    CREATE TABLE baggage (
        id_baggage INT PRIMARY KEY IDENTITY(1,1),
        baggage_number VARCHAR(20) NOT NULL UNIQUE,
        [weight] DECIMAL(6,2) NOT NULL CHECK (weight >= 0), 
        [size] VARCHAR(20) NOT NULL CHECK (size IN ('Small', 'Medium', 'Large')), 
        status VARCHAR(20) NOT NULL CHECK (status IN ('Registrado', 'Entregado', 'Perdido')),
        id_checkin_fk INT NOT NULL,
        FOREIGN KEY (id_checkin_fk) REFERENCES check_in(id_checkin)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla baggage creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla baggage ya existe';
END

-- Verificar y crear el índice idx_baggage_checkin si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.baggage') 
      AND name = 'idx_baggage_checkin'
)
BEGIN
    CREATE INDEX idx_baggage_checkin 
    ON baggage(id_checkin_fk);
    PRINT 'Índice idx_baggage_checkin creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_baggage_checkin ya ha sido creado'; 
END
GO

-- crear la tabla de boarding_pass
IF OBJECT_ID('dbo.boarding_pass', 'U') IS NULL
BEGIN
    CREATE TABLE boarding_pass (
        id_boarding INT PRIMARY KEY IDENTITY(1,1),
        boarding_time TIME NOT NULL,
        gate VARCHAR(10) NOT NULL, 
        id_ticket_fk INT NOT NULL,  
        FOREIGN KEY (id_ticket_fk) REFERENCES ticket(id_ticket)
            ON DELETE CASCADE  
            ON UPDATE CASCADE
    );
    PRINT 'Tabla boarding_pass creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla boarding_pass ya existe';
END

-- Verificar y crear el índice idx_boarding_pass_ticket si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.boarding_pass') 
      AND name = 'idx_boarding_pass_ticket'
)
BEGIN
    CREATE INDEX idx_boarding_pass_ticket 
    ON boarding_pass(id_ticket_fk);
    PRINT 'Índice idx_boarding_pass_ticket creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_boarding_pass_ticket ya ha sido creado'; 
END
GO


-- Crear la tabla de country
IF OBJECT_ID('dbo.country', 'U') IS NULL
BEGIN
    CREATE TABLE country (
        id_country INT PRIMARY KEY IDENTITY(1,1),
        [name] VARCHAR(50) NOT NULL,
        cod_iso char(2) NOT NULL UNIQUE, 
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
        id_city INT PRIMARY KEY IDENTITY(1,1),
        [name] VARCHAR(50) NOT NULL,
        cod_city CHAR(3) NOT NULL UNIQUE,
        id_country_fk INT NOT NULL,
        FOREIGN KEY (id_country_fk) REFERENCES country(id_country)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla city creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla city ya existe';
END
GO
-- Crear el índice idx_city_country en la tabla city
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.city') 
      AND name = 'idx_city_country'
)
BEGIN
    CREATE INDEX idx_city_country 
    ON city(id_country_fk);
    PRINT 'Índice idx_city_country creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_city_country ya ha sido creado'; 
END
GO

-- Crear la tabla de airport
IF OBJECT_ID('dbo.airport', 'U') IS NULL
BEGIN
    CREATE TABLE airport (
        id_airport INT PRIMARY KEY IDENTITY(1,1),
        [name] VARCHAR(100) NOT NULL,
        id_city_fk INT NOT NULL,
        FOREIGN KEY (id_city_fk) REFERENCES city(id_city)
    );
    PRINT 'Tabla airport creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla airport ya existe';
END
GO

-- Crear el índice idx_airport_city en la tabla airport
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.airport') 
      AND name = 'idx_airport_city'
)
BEGIN
    CREATE INDEX idx_airport_city 
    ON airport(id_city_fk);
    PRINT 'Índice idx_airport_city creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_airport_city ya ha sido creado'; 
END
GO


-- Crear la tabla de plane_model
IF OBJECT_ID('dbo.plane_model', 'U') IS NULL
BEGIN
    CREATE TABLE plane_model (
        id_plane_model INT PRIMARY KEY IDENTITY(1,1),
        [description] VARCHAR(100) NOT NULL,
        graphic VARCHAR(10) NOT NULL
    );
    PRINT 'Tabla plane_model creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla plane_model ya existe';
END
GO

-- crear la tabla de airline
IF OBJECT_ID('dbo.airline', 'U') IS NULL
BEGIN
    CREATE TABLE airline (
        id_airline INT PRIMARY KEY IDENTITY(1,1),
        [name] VARCHAR(100) NOT NULL,
        code_IATA CHAR(3) NOT NULL UNIQUE
    );
    PRINT 'Tabla airline creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla airline ya existe';
END


-- Crear la tabla de flight_number
IF OBJECT_ID('dbo.flight_number', 'U') IS NULL
BEGIN
    CREATE TABLE flight_number (
        id_flightnum INT PRIMARY KEY IDENTITY(1,1),
        departure_time TIME NOT NULL, 
        [description] VARCHAR(100) NOT NULL,
        [type] VARCHAR(50) NOT NULL CHECK (type IN ('Domestic', 'International')),
        airline VARCHAR(100) NOT NULL,
        id_start_fk INT NOT NULL,
        id_goal_fk INT NOT NULL,
        id_model_fk INT NOT NULL,
        id_airline_fk INT NOT NULL,
        FOREIGN KEY (id_start_fk) REFERENCES airport(id_airport)
            ON DELETE NO ACTION,
        FOREIGN KEY (id_goal_fk) REFERENCES airport(id_airport)
            ON DELETE NO ACTION,
        FOREIGN KEY (id_model_fk) REFERENCES plane_model(id_plane_model),
        FOREIGN KEY (id_airline_fk) REFERENCES airline(id_airline)
    );
    PRINT 'Tabla flight_number creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla flight_number ya existe';
END
GO

-- Verificar y crear el índice idx_flight_start si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.flight_number') 
      AND name = 'idx_flight_start'
)
BEGIN
    CREATE INDEX idx_flight_start 
    ON flight_number(id_start_fk);
    PRINT 'Índice idx_flight_start creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_flight_start ya ha sido creado'; 
END
GO

-- Verificar y crear el índice idx_flight_goal si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.flight_number') 
      AND name = 'idx_flight_goal'
)
BEGIN
    CREATE INDEX idx_flight_goal 
    ON flight_number(id_goal_fk);
    PRINT 'Índice idx_flight_goal creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_flight_goal ya ha sido creado'; 
END
GO

-- Verificar y crear el índice idx_flight_model si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.flight_number') 
      AND name = 'idx_flight_model'
)
BEGIN
    CREATE INDEX idx_flight_model 
    ON flight_number(id_model_fk);
    PRINT 'Índice idx_flight_model creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_flight_model ya ha sido creado'; 
END
GO

-- Verificar y crear el índice idx_flight_airline si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.flight_number') 
      AND name = 'idx_flight_airline'
)
BEGIN
    CREATE INDEX idx_flight_airline 
    ON flight_number(id_airline_fk);
    PRINT 'Índice idx_flight_airline creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_flight_airline ya ha sido creado'; 
END
GO

-- crear la tabla de scale
IF OBJECT_ID('dbo.scale', 'U') IS NULL
BEGIN
    CREATE TABLE scale (
        id_scale INT PRIMARY KEY IDENTITY(1,1),
        arrival_time TIME NOT NULL,
        departure_time TIME NOT NULL,
        [description] VARCHAR(100) NOT NULL,
        id_airport_fk INT NOT NULL,
        id_flightnum_fk INT NOT NULL,
        FOREIGN KEY (id_airport_fk) REFERENCES airport(id_airport),
        FOREIGN KEY (id_flightnum_fk) REFERENCES flight_number(id_flightnum)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla scale creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla scale ya existe';
END

-- Verificar y crear el índice idx_scale_airport si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.scale') 
      AND name = 'idx_scale_airport'
)
BEGIN
    CREATE INDEX idx_scale_airport 
    ON scale(id_airport_fk);
    PRINT 'Índice idx_scale_airport creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_scale_airport ya ha sido creado'; 
END
GO

-- Verificar y crear el índice idx_scale_flightnum si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.scale') 
      AND name = 'idx_scale_flightnum'
)
BEGIN
    CREATE INDEX idx_scale_flightnum 
    ON scale(id_flightnum_fk);
    PRINT 'Índice idx_scale_flightnum creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_scale_flightnum ya ha sido creado'; 
END
GO

-- Crear la tabla de flight
IF OBJECT_ID('dbo.flight', 'U') IS NULL
BEGIN
    CREATE TABLE flight (
        id_flight INT PRIMARY KEY IDENTITY(1,1),
        boarding_time TIME NOT NULL,
        flight_date DATE NOT NULL CHECK (flight_date >= CAST(GETDATE() AS DATE)), 
        gate VARCHAR(10) NOT NULL, 
        check_in_counter VARCHAR(10) NOT NULL,
        id_flightnum_fk INT NOT NULL,
        FOREIGN KEY (id_flightnum_fk) REFERENCES flight_number(id_flightnum)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla flight creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla flight ya existe';
END
GO

-- Verificar y crear el índice idx_flight_number si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.flight') 
      AND name = 'idx_flight_number'
)
BEGIN
    CREATE INDEX idx_flight_number 
    ON flight(id_flightnum_fk);
    PRINT 'Índice idx_flight_number creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_flight_number ya ha sido creado'; 
END
GO

-- crear la tabla de flight_crew
IF OBJECT_ID('dbo.flight_crew', 'U') IS NULL
BEGIN
    CREATE TABLE fligh_crew (
        id_crew INT PRIMARY KEY IDENTITY(1,1),
        [name] VARCHAR(100) NOT NULL,
        [position] VARCHAR(50) NOT NULL CHECK ([position] IN ('Pilot', 'Co-Pilot', 'Flight Attendant', 'Flight Engineer')),
        id_flight_fk INT NOT NULL,
        FOREIGN KEY (id_flight_fk) REFERENCES flight(id_flight)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla flight_crew creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla flight_crew ya existe';
END

-- Verificar y crear el índice idx_flight_crew si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.flight_crew') 
      AND name = 'idx_flight_crew'
)
BEGIN
    CREATE INDEX idx_flight_crew 
    ON flight_crew(id_flight_fk);
    PRINT 'Índice idx_flight_crew creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_flight_crew ya ha sido creado'; 
END
GO

-- crear la tabla de cancellation_flight
IF OBJECT_ID('dbo.cancellation_flight', 'U') IS NULL
BEGIN
    CREATE TABLE cancellation_flight (
        id_cancellation INT PRIMARY KEY IDENTITY(1,1),
        cancellation_date DATE NOT NULL CHECK (cancellation_date >= CAST(GETDATE() AS DATE)), 
        cancellation_time TIME NOT NULL,
        reason VARCHAR(100) NOT NULL CHECK (reason IN ('Weather', 'Technical', 'Operational', 'Other')),
        id_flight_fk INT NOT NULL,
        FOREIGN KEY (id_flight_fk) REFERENCES flight(id_flight)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla cancellation_flight creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla cancellation_flight ya existe';
END

-- Verificar y crear el índice idx_cancellation_flight si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.cancellation_flight') 
      AND name = 'idx_cancellation_flight'
)
BEGIN
    CREATE INDEX idx_cancellation_flight 
    ON cancellation_flight(id_flight_fk);
    PRINT 'Índice idx_cancellation_flight creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_cancellation_flight ya ha sido creado'; 
END
GO

-- crear la tabla de flight_delay
IF OBJECT_ID('dbo.flight_delay', 'U') IS NULL
BEGIN
    CREATE TABLE flight_delay (
        id_delay INT PRIMARY KEY IDENTITY(1,1),
        delay_duration TIME NOT NULL,
        delay_start TIME NOT NULL,
        delay_end TIME NOT NULL,
        reason VARCHAR(100) NOT NULL CHECK (reason IN ('Weather', 'Technical', 'Operational', 'Other')),
        id_flight_fk INT NOT NULL,
        FOREIGN KEY (id_flight_fk) REFERENCES flight(id_flight)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla flight_delay creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla flight_delay ya existe';
END

-- Verificar y crear el índice idx_flight_delay si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.flight_delay') 
      AND name = 'idx_flight_delay'
)
BEGIN
    CREATE INDEX idx_flight_delay 
    ON flight_delay(id_flight_fk);
    PRINT 'Índice idx_flight_delay creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_flight_delay ya ha sido creado'; 
END
GO

-- Crear la tabla de airplane
IF OBJECT_ID('dbo.airplane', 'U') IS NULL
BEGIN
    CREATE TABLE airplane (
        id_airplane INT PRIMARY KEY IDENTITY(1,1),
        registration_number VARCHAR(20) NOT NULL UNIQUE, 
        begin_of_operation DATE NOT NULL CHECK (begin_of_operation <= CAST(GETDATE() AS DATE)), 
        [status] VARCHAR(10) NOT NULL CHECK (status IN ('Inactive', 'Active')), 
        id_plane_model_fk INT NOT NULL,
        FOREIGN KEY (id_plane_model_fk) REFERENCES plane_model(id_plane_model)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla airplane creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla airplane ya existe';
END
GO

-- Verificar y crear el índice idx_airplane_model si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.airplane') 
      AND name = 'idx_airplane_model'
)
BEGIN
    CREATE INDEX idx_airplane_model 
    ON airplane(id_plane_model_fk);
    PRINT 'Índice idx_airplane_model creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_airplane_model ya ha sido creado'; 
END
GO


-- Crear la tabla de seat
IF OBJECT_ID('dbo.seat', 'U') IS NULL
BEGIN
    CREATE TABLE seat (
        id_seat INT PRIMARY KEY IDENTITY(1,1),
        [size] VARCHAR(20) NOT NULL CHECK (size IN ('Small', 'Medium', 'Large')), 
        [number] VARCHAR(10) NOT NULL UNIQUE, 
        [location] VARCHAR(20) NOT NULL CHECK (location IN ('Ventana', 'Medio', 'Pasillo')),  
        id_plane_model_fk INT NOT NULL,
        FOREIGN KEY (id_plane_model_fk) REFERENCES plane_model(id_plane_model)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla seat creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla seat ya existe';
END
GO

-- Verificar y crear el índice idx_seat_plane_model si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.seat') 
      AND name = 'idx_seat_plane_model'
)
BEGIN
    CREATE INDEX idx_seat_plane_model 
    ON seat(id_plane_model_fk);
    PRINT 'Índice idx_seat_plane_model creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_seat_plane_model ya ha sido creado'; 
END
GO

-- Crear la tabla de coupon
IF OBJECT_ID('dbo.coupon', 'U') IS NULL
BEGIN
    CREATE TABLE coupon (
        id_coupon INT PRIMARY KEY IDENTITY(1,1),
        date_of_Redemption DATE NOT NULL CHECK (date_of_Redemption >= CAST(GETDATE() AS DATE)), 
        class VARCHAR(20) NOT NULL CHECK (class IN ('Economy', 'Business', 'First')), 
        [standby] CHAR(1) NOT NULL CHECK (standby IN ('Y', 'N')), 
        meal_code VARCHAR(10) NOT NULL UNIQUE, 
        id_ticket_fk INT NOT NULL,
        id_flight_fk INT NOT NULL,
        FOREIGN KEY (id_ticket_fk) REFERENCES ticket(id_ticket)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
        FOREIGN KEY (id_flight_fk) REFERENCES flight(id_flight)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla coupon creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla coupon ya existe';
END
GO

-- Verificar y crear el índice idx_coupon_ticket si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.coupon') 
      AND name = 'idx_coupon_ticket'
)
BEGIN
    CREATE INDEX idx_coupon_ticket 
    ON coupon(id_ticket_fk);
    PRINT 'Índice idx_coupon_ticket creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_coupon_ticket ya ha sido creado'; 
END
GO

-- Verificar y crear el índice idx_coupon_flight si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.coupon') 
      AND name = 'idx_coupon_flight'
)
BEGIN
    CREATE INDEX idx_coupon_flight 
    ON coupon(id_flight_fk);
    PRINT 'Índice idx_coupon_flight creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_coupon_flight ya ha sido creado'; 
END
GO


-- Crear la tabla de available_seat
IF OBJECT_ID('dbo.available_seat', 'U') IS NULL
BEGIN
    CREATE TABLE available_seat (
        id_availableseat INT PRIMARY KEY IDENTITY(1,1),
        id_seat_fk INT NOT NULL,
        id_flight_fk INT NOT NULL,
        id_coupon_fk INT NOT NULL,
        FOREIGN KEY (id_seat_fk) REFERENCES seat(id_seat)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
        FOREIGN KEY (id_flight_fk) REFERENCES flight(id_flight)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
        FOREIGN KEY (id_coupon_fk) REFERENCES coupon(id_coupon)
    );
    PRINT 'Tabla available_seat creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla available_seat ya existe';
END
GO

-- Verificar y crear el índice idx_available_seat_seat si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.available_seat') 
      AND name = 'idx_available_seat_seat'
)
BEGIN
    CREATE INDEX idx_available_seat_seat 
    ON available_seat(id_seat_fk);
    PRINT 'Índice idx_available_seat_seat creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_available_seat_seat ya ha sido creado'; 
END
GO

-- Verificar y crear el índice idx_available_seat_flight si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.available_seat') 
      AND name = 'idx_available_seat_flight'
)
BEGIN
    CREATE INDEX idx_available_seat_flight 
    ON available_seat(id_flight_fk);
    PRINT 'Índice idx_available_seat_flight creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_available_seat_flight ya ha sido creado'; 
END
GO

-- Crear la tabla de pieces_of_luggage
IF OBJECT_ID('dbo.pieces_of_luggage', 'U') IS NULL
BEGIN
    CREATE TABLE pieces_of_luggage (
        id_pieces INT PRIMARY KEY IDENTITY(1,1),
        [number] VARCHAR(50) NOT NULL,
        [weight] DECIMAL(6,2) NOT NULL CHECK (weight >= 0), 
        id_coupon_fk INT NOT NULL,
        FOREIGN KEY (id_coupon_fk) REFERENCES coupon(id_coupon)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Tabla pieces_of_luggage creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla pieces_of_luggage ya existe';
END
GO

-- Verificar y crear el índice idx_pieces_of_luggage_coupon si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.pieces_of_luggage') 
      AND name = 'idx_pieces_of_luggage_coupon'
)
BEGIN
    CREATE INDEX idx_pieces_of_luggage_coupon 
    ON pieces_of_luggage(id_coupon_fk);
    PRINT 'Índice idx_pieces_of_luggage_coupon creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El índice idx_pieces_of_luggage_coupon ya ha sido creado'; 
END
GO

----------------------POPULACIÓN DE DATOS----------------------
