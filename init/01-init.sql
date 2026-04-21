CREATE DATABASE devdb;
GO

USE devdb;
GO

CREATE LOGIN testuser WITH PASSWORD = 'TestPass123!';
CREATE USER testuser FOR LOGIN testuser;
ALTER ROLE db_owner ADD MEMBER testuser;
GO

CREATE TABLE testowa (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nazwa NVARCHAR(255) NOT NULL,
    opis NVARCHAR(MAX),
    utworzono DATETIME DEFAULT CURRENT_TIMESTAMP
);
GO

INSERT INTO testowa (nazwa, opis) VALUES
    ('rekord 1', 'Pierwszy rekord testowy'),
    ('rekord 2', 'Drugi rekord testowy'),
    ('rekord 3', 'Trzeci rekord testowy');
GO