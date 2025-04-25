DROP DATABASE IF EXISTS `fdr`;
CREATE DATABASE IF NOT EXISTS `fdr` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
USE `fdr`;

-- Procedures
DELIMITER $$
CREATE PROCEDURE Clasificacion(IN p_TEM_ID INT)
BEGIN
    DECLARE noHayDatos INT DEFAULT 0;
    DECLARE fin boolean DEFAULT 0;
    DECLARE equipoID INT;

    -- Variables de la clasificacion
    DECLARE foto Varchar(255);
    DECLARE equipo Varchar(255);
    DECLARE pts_total INT;
    DECLARE par_ganados INT DEFAULT 0;
    DECLARE par_perdidos INT DEFAULT 0;
    DECLARE par_empatados INT DEFAULT 0;
    DECLARE par_jugados INT DEFAULT 0;

    DECLARE c CURSOR FOR
        SELECT DISTINCT EQU_ID FROM incluyeEquipo WHERE TEM_ID = p_TEM_ID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;

    -- Excepcion 
    SELECT COUNT(*) INTO noHayDatos FROM partido WHERE TEM_ID = p_TEM_ID;
    IF noHayDatos = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Temporada Invalida';
    END IF;

    -- Crear tabla temporal para sacar todos los datos de una 
    CREATE TEMPORARY TABLE tablatemporal (
        foto VARCHAR(255),
        equipo VARCHAR(255),
        pts_total INT,
        par_jugados INT,
        par_ganados INT,
        par_perdidos INT,
        par_empatados INT
    );

    -- Cursor
    OPEN c;
    -- Cojer primeros datos si hay alguno
    FETCH c INTO equipoID;
    WHILE fin = 0 DO
        -- reseteo valores por si acaso
        SET par_ganados = 0;
        SET par_perdidos = 0;
        SET par_empatados = 0;
        SET pts_total = 0;

        -- seleccionar imagen de equipo
        SELECT e.EQU_Foto INTO foto FROM incluyeEquipo e WHERE e.EQU_ID = equipoID AND e.TEM_ID = p_TEM_ID;

        -- seleccionar nombres
        SELECT e.EQU_Nombre INTO equipo FROM equipo e WHERE e.EQU_ID = equipoID;

        -- calcular si equipo ha ganado perdido o empatado
        -- gana
        SELECT SUM(CASE WHEN (EQU_ID_Loc = equipoID AND EQU_Gol_Loc > EQU_Gol_Vis) OR (EQU_ID_Vis = equipoID AND EQU_Gol_Vis > EQU_Gol_Loc) THEN 1 ELSE 0 END) INTO par_ganados
        FROM partido WHERE TEM_ID = p_TEM_ID AND (EQU_ID_Loc = equipoID OR EQU_ID_Vis = equipoID);

        -- pierde
        SELECT SUM(CASE WHEN (EQU_ID_Loc = equipoID AND EQU_Gol_Loc < EQU_Gol_Vis)OR (EQU_ID_Vis = equipoID AND EQU_Gol_Vis < EQU_Gol_Loc)THEN 1 ELSE 0 END) INTO par_perdidos
        FROM partido WHERE TEM_ID = p_TEM_ID AND (EQU_ID_Loc = equipoID OR EQU_ID_Vis = equipoID);

        -- empata
        SELECT SUM(CASE WHEN EQU_Gol_Loc = EQU_Gol_Vis THEN 1 ELSE 0 END) INTO par_empatados
        FROM partido WHERE TEM_ID = p_TEM_ID AND (EQU_ID_Loc = equipoID OR EQU_ID_Vis = equipoID);

        -- total jugados
        SET pts_total = (par_ganados * 4) + (par_empatados * 2) + (par_perdidos * 1);      -- total jugados
        SET par_jugados = par_ganados + par_perdidos + par_empatados;

        -- Insert results into temporary table
        INSERT INTO tablatemporal (foto, equipo, pts_total, par_jugados, par_ganados, par_perdidos, par_empatados)
        VALUES (foto, equipo, pts_total, par_jugados, par_ganados, par_perdidos, par_empatados);

        FETCH c INTO equipoID;
    END WHILE;

    CLOSE c;

    -- Return all results in a single select
    SELECT * FROM tablatemporal;

    -- Drop temporary table after use
    DROP TEMPORARY TABLE IF EXISTS tablatemporal;
END $$;


DELIMITER ;
CREATE TABLE `partido` (
  `PAR_ID` INT(10) NOT NULL,
  `TEM_ID` INT(10) NOT NULL,
  `ARB_DNI` INT(10) NOT NULL,
  `EQU_ID_Loc` INT(10) NOT NULL,	
  `EQU_ID_Vis` INT(10) NOT NULL,
  `EQU_Gol_Loc` INT(2),	
  `EQU_Gol_Vis` INT(2),
  `PAR_Jugado` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`PAR_ID`, `TEM_ID`)
);
INSERT INTO `partido` (`PAR_ID`, `TEM_ID`, `ARB_DNI`, `EQU_ID_Loc`, `EQU_ID_Vis`, `EQU_Gol_Loc`, `EQU_Gol_Vis`, `PAR_Jugado`) 
VALUES
-- 30 partidos temporada 1 (2 draws added)
(1, 1, 300001, 1, 3, 3, 2, TRUE), (2, 1, 300002, 2, 4, 1, 1, TRUE), (3, 1, 300003, 5, 6, 4, 2, TRUE), 
(4, 1, 300004, 3, 5, 2, 3, TRUE), (5, 1, 300005, 1, 6, 3, 1, TRUE), (6, 1, 300006, 4, 2, 2, 2, TRUE),
(7, 1, 300001, 6, 3, 1, 4, TRUE), (8, 1, 300002, 5, 1, 2, 3, TRUE), (9, 1, 300003, 2, 4, 1, 1, TRUE),
(10, 1, 300004, 3, 6, 3, 2, TRUE), (11, 1, 300005, 4, 5, 2, 4, TRUE), (12, 1, 300006, 1, 2, 1, 3, TRUE),
(13, 1, 300001, 5, 3, 4, 2, TRUE), (14, 1, 300002, 6, 4, 2, 2, TRUE), (15, 1, 300003, 1, 2, 3, 1, TRUE),
(16, 1, 300004, 3, 5, 2, 3, TRUE), (17, 1, 300005, 4, 6, 1, 4, TRUE), (18, 1, 300006, 2, 1, 2, 3, TRUE),
(19, 1, 300001, 6, 5, 3, 3, TRUE), (20, 1, 300002, 4, 3, 2, 1, TRUE), (21, 1, 300003, 2, 6, 1, 2, TRUE),
(22, 1, 300004, 5, 1, 4, 3, TRUE), (23, 1, 300005, 3, 4, 2, 2, TRUE), (24, 1, 300006, 1, 2, 3, 1, TRUE),
(25, 1, 300001, 4, 6, 2, 3, TRUE), (26, 1, 300002, 5, 2, 3, 1, TRUE), (27, 1, 300003, 3, 1, 1, 4, TRUE),
(28, 1, 300004, 6, 4, 2, 2, TRUE), (29, 1, 300005, 2, 5, 3, 3, TRUE), (30, 1, 300006, 1, 3, 2, 1, TRUE),

-- 30 partidos temporada 2 (2 draws added)
(1, 2, 300001, 2, 5, 3, 1, TRUE), (2, 2, 300002, 7, 4, 2, 2, TRUE), (3, 2, 300003, 1, 3, 4, 2, TRUE), 
(4, 2, 300004, 5, 2, 2, 3, TRUE), (5, 2, 300005, 4, 7, 1, 4, TRUE), (6, 2, 300006, 3, 1, 3, 2, TRUE),
(7, 2, 300001, 2, 7, 2, 2, TRUE), (8, 2, 300002, 5, 4, 3, 1, TRUE), (9, 2, 300003, 1, 2, 2, 3, TRUE),
(10, 2, 300004, 7, 3, 1, 4, TRUE), (11, 2, 300005, 4, 5, 2, 2, TRUE), (12, 2, 300006, 3, 7, 3, 1, TRUE),
(13, 2, 300001, 1, 4, 2, 3, TRUE), (14, 2, 300002, 2, 5, 3, 1, TRUE), (15, 2, 300003, 7, 3, 1, 4, TRUE),
(16, 2, 300004, 4, 2, 2, 2, TRUE), (17, 2, 300005, 5, 1, 3, 3, TRUE), (18, 2, 300006, 3, 4, 1, 2, TRUE),
(19, 2, 300001, 7, 2, 2, 3, TRUE), (20, 2, 300002, 1, 5, 3, 1, TRUE), (21, 2, 300003, 4, 3, 2, 2, TRUE),
(22, 2, 300004, 5, 7, 1, 4, TRUE), (23, 2, 300005, 2, 1, 3, 2, TRUE), (24, 2, 300006, 3, 5, 2, 3, TRUE),
(25, 2, 300001, 4, 7, 1, 4, TRUE), (26, 2, 300002, 2, 3, 3, 1, TRUE), (27, 2, 300003, 5, 4, 2, 2, TRUE),
(28, 2, 300004, 7, 1, 3, 3, TRUE), (29, 2, 300005, 3, 2, 1, 4, TRUE), (30, 2, 300006, 4, 5, 2, 2, TRUE),

-- 30 partidos temporada 3 (2 draws added)
(1, 3, 300001, 3, 8, 2, 1, TRUE), (2, 3, 300002, 4, 7, 3, 3, TRUE), (3, 3, 300003, 1, 2, 4, 2, TRUE), 
(4, 3, 300004, 8, 3, 1, 4, TRUE), (5, 3, 300005, 7, 4, 2, 2, TRUE), (6, 3, 300006, 2, 1, 3, 3, TRUE),
(7, 3, 300001, 4, 8, 1, 4, TRUE), (8, 3, 300002, 3, 7, 2, 3, TRUE), (9, 3, 300003, 1, 4, 3, 1, TRUE),
(10, 3, 300004, 8, 2, 2, 2, TRUE), (11, 3, 300005, 7, 3, 1, 4, TRUE), (12, 3, 300006, 2, 8, 3, 2, TRUE),
(13, 3, 300001, 4, 1, NULL, NULL, FALSE), (14, 3, 300002, 7, 2, NULL, NULL, FALSE), (15, 3, 300003, 8, 4, NULL, NULL, FALSE),
(16, 3, 300004, 3, 7, NULL, NULL, FALSE), (17, 3, 300005, 1, 8, NULL, NULL, FALSE), (18, 3, 300006, 2, 4, NULL, NULL, FALSE),
(19, 3, 300001, 7, 3, NULL, NULL, FALSE), (20, 3, 300002, 8, 1, NULL, NULL, FALSE), (21, 3, 300003, 4, 2, NULL, NULL, FALSE),
(22, 3, 300004, 3, 8, NULL, NULL, FALSE), (23, 3, 300005, 1, 7, NULL, NULL, FALSE), (24, 3, 300006, 2, 3, NULL, NULL, FALSE),
(25, 3, 300001, 8, 4, NULL, NULL, FALSE), (26, 3, 300002, 7, 1, NULL, NULL, FALSE), (27, 3, 300003, 3, 2, NULL, NULL, FALSE),
(28, 3, 300004, 4, 8, NULL, NULL, FALSE), (29, 3, 300005, 2, 7, NULL, NULL, FALSE), (30, 3, 300006, 1, 3, NULL, NULL, FALSE);


CREATE TABLE `arbitro` (
  `ARB_DNI` int(10) NOT NULL PRIMARY KEY,
  `ARB_Nombre` varchar(255) NOT NULL,
  `ARB_Certificacion` varchar(255) NOT NULL
);
INSERT INTO `arbitro` (`ARB_DNI`, `ARB_Nombre`, `ARB_Certificacion`) VALUES
(300001, 'Álvaro Martínez', 'Certificación Nacional de Arbitraje'),
(300002, 'Beatriz Sánchez', 'Certificación Internacional de Arbitraje'),
(300003, 'Carlos López', 'Curso Avanzado de Reglas de Juego'),
(300004, 'Diana Torres', 'Especialización en Arbitraje de Rugby'),
(300005, 'Eduardo Fernández', 'Certificación en Análisis de Juego'),
(300006, 'Fátima Gómez', 'Certificación de Alto Nivel en Rugby');

CREATE TABLE `jugador` (
  `JUG_DNI` int(10) NOT NULL PRIMARY KEY,
  `JUG_Nombre` varchar(255) NOT NULL,
  `JUG_FchaNacimiento` date NOT NULL,
  `JUG_Peso` decimal(5,2) DEFAULT NULL,
  `JUG_Altura` decimal(3,2) DEFAULT NULL
);

INSERT INTO `jugador` (`JUG_DNI`, `JUG_Nombre`, `JUG_FchaNacimiento`, `JUG_Peso`, `JUG_Altura`) VALUES
(100001, 'Juan Pérez', '1995-06-15', 85.50, 1.80),
(100002, 'Carlos Gómez', '1997-03-22', 78.20, 1.75),
(100003, 'Diego Fernández', '1994-09-10', 90.00, 1.85),
(100004, 'Andrés Ramírez', '1996-12-05', 82.30, 1.78),
(100005, 'Luis González', '1993-07-19', 88.40, 1.82),
(100006, 'Pedro Sánchez', '1998-02-14', 76.50, 1.74),
(100007, 'José Torres', '1992-11-30', 92.10, 1.87),
(100008, 'Manuel Díaz', '1999-05-23', 80.00, 1.76),
(100009, 'Antonio Herrera', '1991-08-07', 85.00, 1.81),
(100010, 'Francisco Ruiz', '1990-10-29', 89.50, 1.84),
(100011, 'Hugo López', '1996-01-17', 77.80, 1.73),
(100012, 'Ricardo Castro', '1994-04-09', 86.20, 1.79),
(100013, 'Alejandro Ortega', '1993-06-25', 91.00, 1.86),
(100014, 'Sebastián Rojas', '1997-08-31', 79.50, 1.77),
(100015, 'Matías Jiménez', '1995-12-12', 83.40, 1.80),
(100016, 'Felipe Morales', '1992-02-03', 87.60, 1.83),
(100017, 'Javier Soto', '1998-07-21', 75.90, 1.72),
(100018, 'Rodrigo Vega', '1999-09-14', 81.70, 1.78),
(100019, 'Sergio Navarro', '1991-03-27', 88.00, 1.85),
(100020, 'Gabriel Castillo', '1994-11-05', 84.30, 1.80),
(100021, 'Emilio Romero', '1995-04-16', 79.00, 1.76),
(100022, 'Daniel Méndez', '1996-06-08', 82.50, 1.79),
(100023, 'Óscar Flores', '1993-05-12', 90.20, 1.86),
(100024, 'Tomás Aguilar', '1997-07-15', 78.40, 1.74),
(100025, 'Esteban Salazar', '1990-01-30', 92.50, 1.88),
(100026, 'Cristian Paredes', '1992-10-10', 85.70, 1.81),
(100027, 'Miguel Vázquez', '1994-03-18', 80.90, 1.77),
(100028, 'Pablo Carrasco', '1998-09-29', 76.80, 1.73),
(100029, 'Héctor Fuentes', '1991-12-07', 89.00, 1.84),
(100030, 'Eduardo Campos', '1999-06-04', 78.00, 1.75),
(100031, 'Raúl Escobar', '1995-08-22', 83.00, 1.79),
(100032, 'Marcos Valenzuela', '1997-02-11', 87.20, 1.82),
(100033, 'Iván Araya', '1993-04-05', 90.50, 1.85),
(100034, 'Vicente Espinoza', '1996-09-17', 79.30, 1.77),
(100035, 'Fernando Orellana', '1992-11-20', 88.70, 1.83),
(100036, 'Bruno Sepúlveda', '1990-07-13', 91.40, 1.86);

CREATE TABLE `equipo` (
  `EQU_ID` int(10) NOT NULL PRIMARY KEY,
  `EQU_Nombre` varchar(50) NOT NULL,
  `EQU_FchaFundacion` year(4) NOT NULL,
  `ENT_DNI` int(10) NOT NULL
  
);
INSERT INTO equipo (EQU_ID, EQU_Nombre, EQU_FchaFundacion, ENT_DNI) VALUES
(1,'Leones Rojos', 1985, 200001),
(2,'Toros Negros', 1990, 200002),
(3,'Águilas Doradas', 1978, 200003),
(4,'Pumas Salvajes', 2002, 200004),
(5,'Tiburones Azules', 1995, 200005),
(6,'Dragones Verdes', 1983, 200006),
(7,'Cóndores Blancos', 1975, 200007),
(8,'Jaguares de Fuego', 1988, 200008);


CREATE TABLE `entrenador` (
  `ENT_DNI` int(10) NOT NULL PRIMARY KEY,
  `ENT_Nombre` varchar(255) NOT NULL,
  `ENT_Certificacion` varchar(255) NOT NULL
); 
INSERT INTO entrenador (ENT_DNI, ENT_Nombre, ENT_Certificacion) VALUES
(200001, 'Mikel Resa', 'Licencia Internacional de Rugby'),
(200002, 'Txema Turrones', 'Certificación de Alto Rendimiento'),
(200003, 'Asier Allerdo', 'Entrenador Nivel 3 World Rugby'),
(200004, 'Danel Muñon', 'Especialización en Tácticas Defensivas'),
(200005, 'Ekaitz Rios', 'Curso Avanzado de Estrategias de Juego'),
(200006, 'David Agarra', 'Certificación en Preparación Física'),
(200007, 'Alain Duque', 'Máster en Gestión Deportiva'),
(200008, 'Unai Sapo', 'Certificación en Análisis de Juego');

CREATE TABLE `temporada` (
  `TEM_ID` int(10) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `TEM_Estado` enum('enCurso','finalizado',"noIniciado") NOT NULL,
  `TEM_Nombre` varchar(255) NOT NULL
);
INSERT INTO temporada ( TEM_Estado, TEM_Nombre) VALUES
('enCurso', 'Temporada 2024-2025'),
('finalizado', 'Temporada 2023-2024'),
('noIniciado', 'Temporada 2025-2026');


CREATE TABLE `incluyeJugador` (
  `EQU_TEM_ID` int(10) NOT NULL,
  `JUG_DNI` int(10) NOT NULL,
  `JUG_Posicion` varchar(1000) NOT NULL,
  `JUG_Dorsal` int(2) DEFAULT NULL,
  `JUG_Foto` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`EQU_TEM_ID`, `JUG_DNI`)
);

INSERT INTO incluyeJugador (EQU_TEM_ID, JUG_DNI, JUG_Posicion, JUG_Dorsal, JUG_Foto) VALUES
-- TEMPORADA 1
(1, 100001, 'Delantero', 2, 'A2'),
(1, 100002, 'Delantero', 4, 'A4'),
(1, 100003, 'Delantero', 6, 'A6'),
(1, 100004, 'Delantero', 8, 'A8'),
(1, 100005, 'Delantero', 10, 'A0'),
(1, 100006, 'Delantero', 12, 'A12'),

(2, 100007, 'Delantero', 2, 'B2'),
(2, 100008, 'Delantero', 4, 'B4'),
(2, 100009, 'Delantero', 6, 'B6'),
(2, 100010, 'Delantero', 8, 'B8'),
(2, 100011, 'Delantero', 10, 'B10'),
(2, 100012, 'Delantero', 12, 'B12'),

(3, 100013, 'Delantero', 2, 'C2'),
(3, 100014, 'Delantero', 4, 'C4'),
(3, 100015, 'Delantero', 6, 'C6'),
(3, 100016, 'Delantero', 8, 'C8'),
(3, 100017, 'Delantero', 10, 'C10'),
(3, 100018, 'Delantero', 12, 'C12'),

(4, 100019, 'Delantero', 2, 'D2'),
(4, 100020, 'Delantero', 4, 'D4'),
(4, 100021, 'Delantero', 6, 'D6'),
(4, 100022, 'Delantero', 8, 'D8'),
(4, 100023, 'Delantero', 10, 'D10'),
(4, 100024, 'Delantero', 12, 'D12'),

(5, 100025, 'Delantero', 2, 'E2'),
(5, 100026, 'Delantero', 4, 'E4'),
(5, 100027, 'Delantero', 6, 'E6'),
(5, 100028, 'Delantero', 8, 'E8'),
(5, 100029, 'Delantero', 10, 'E10'),
(5, 100030, 'Delantero', 12, 'E12'),

(6, 100031, 'Delantero', 2, 'F2'),
(6, 100032, 'Delantero', 4, 'F4'),
(6, 100033, 'Delantero', 6, 'F6'),
(6, 100034, 'Delantero', 8, 'F8'),
(6, 100035, 'Delantero', 10, 'F10'),
(6, 100036, 'Delantero', 12, 'F12'),

-- 2nda Temporada
(7, 100001, 'Delantero', 2, 'A2'),
(7, 100002, 'Delantero', 4, 'A4'),
(7, 100003, 'Delantero', 6, 'A6'),
(7, 100004, 'Delantero', 8, 'A8'),
(7, 100005, 'Delantero', 10, 'A10'),
(7, 100006, 'Delantero', 12, 'A12'),

(8, 100007, 'Delantero', 2, 'B2'),
(8, 100008, 'Delantero', 4, 'B4'),
(8, 100009, 'Delantero', 6, 'B6'),
(8, 100010, 'Delantero', 8, 'B8'),
(8, 100011, 'Delantero', 10, 'B10'),
(8, 100012, 'Delantero', 12, 'B12'),

(9, 100013, 'Delantero', 2, 'C2'),
(9, 100014, 'Delantero', 4, 'C4'),
(9, 100015, 'Delantero', 6, 'C6'),
(9, 100016, 'Delantero', 8, 'C8'),
(9, 100017, 'Delantero', 10, 'C10'),
(9, 100018, 'Delantero', 12, 'C12'),

(10, 100019, 'Delantero', 2, 'D2'),
(10, 100020, 'Delantero', 4, 'D4'),
(10, 100021, 'Delantero', 6, 'D6'),
(10, 100022, 'Delantero', 8, 'D8'),
(10, 100023, 'Delantero', 10, 'D10'),
(10, 100024, 'Delantero', 12, 'D12'),

(11, 100025, 'Delantero', 2, 'E2'),
(11, 100026, 'Delantero', 4, 'E4'),
(11, 100027, 'Delantero', 6, 'E6'),
(11, 100028, 'Delantero', 8, 'E8'),
(11, 100029, 'Delantero', 10, 'E10'),
(11, 100030, 'Delantero', 12, 'E12'),

(12, 100031, 'Delantero', 2, 'F2'),
(12, 100032, 'Delantero', 4, 'F4'),
(12, 100033, 'Delantero', 6, 'F6'),
(12, 100034, 'Delantero', 8, 'F8'),
(12, 100035, 'Delantero', 10, 'F10'),
(12, 100036, 'Delantero', 12, 'F12'),

-- 3era temporada
(13, 100001, 'Delantero', 1, 'A1'),
(13, 100002, 'Delantero', 3, 'A3'),
(13, 100003, 'Delantero', 5, 'A5'),
(13, 100004, 'Delantero', 7, 'A7'),
(13, 100005, 'Delantero', 9, 'A9'),
(13, 100006, 'Delantero', 11, 'A11'),

(14, 100007, 'Delantero', 1, 'B1'),
(14, 100008, 'Delantero', 3, 'B3'),
(14, 100009, 'Delantero', 5, 'B5'),
(14, 100010, 'Delantero', 7, 'B7'),
(14, 100011, 'Delantero', 9, 'B9'),
(14, 100012, 'Delantero', 11, 'B11'),

(15, 100013, 'Delantero', 1, 'C1'),
(15, 100014, 'Delantero', 3, 'C3'),
(15, 100015, 'Delantero', 5, 'C5'),
(15, 100016, 'Delantero', 7, 'C7'),
(15, 100017, 'Delantero', 9, 'C9'),
(15, 100018, 'Delantero', 11, 'C11'),

(16, 100019, 'Delantero', 1, 'D1'),
(16, 100020, 'Delantero', 3, 'D3'),
(16, 100021, 'Delantero', 5, 'D5'),
(16, 100022, 'Delantero', 7, 'D7'),
(16, 100023, 'Delantero', 9, 'D9'),
(16, 100024, 'Delantero', 11, 'D11'),

(17, 100025, 'Delantero', 1, 'E1'),
(17, 100026, 'Delantero', 3, 'E3'),
(17, 100027, 'Delantero', 5, 'E5'),
(17, 100028, 'Delantero', 7, 'E7'),
(17, 100029, 'Delantero', 9, 'E9'),
(17, 100030, 'Delantero', 11, 'E11'),

(18, 100031, 'Delantero', 1, 'F1'),
(18, 100032, 'Delantero', 3, 'F3'),
(18, 100033, 'Delantero', 5, 'F5'),
(18, 100034, 'Delantero', 7, 'F7'),
(18, 100035, 'Delantero', 9, 'F9'),
(18, 100036, 'Delantero', 11, 'F11');

CREATE TABLE `incluyeEquipo` (
  `EQU_ID` int(10) DEFAULT NULL,
  `TEM_ID` int(10) DEFAULT NULL,
  `EQU_Foto` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`EQU_ID`,`TEM_ID`)
);

INSERT INTO incluyeEquipo (EQU_ID, TEM_ID, EQU_Foto) VALUES
(1, 1, 'EQ1'),
(2, 1, 'EQ2'),
(3, 1, 'EQ3'),
(4, 1, 'EQ4'),
(5, 1, 'EQ5'),
(6, 1, 'EQ6'),

(1, 2, 'EQ1'),
(2, 2, 'EQ2'),
(3, 2, 'EQ3'),
(4, 2, 'EQ4'),
(5, 2, 'EQ5'),
(7, 2, 'EQ7'),

(1, 3, 'EQ1'),
(2, 3, 'EQ2'),
(3, 3, 'EQ3'),
(4, 3, 'EQ4'),
(7, 3, 'EQ7'),
(8, 3, 'EQ8');


CREATE TABLE `logs` (
    `LOG_ID` SERIAL PRIMARY KEY,
    `LOG_Usuario` VARCHAR(1000),
    `LOG_Msg` TEXT,
    `LOG_Fcha` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER `modificacionTemporada`
  AFTER UPDATE ON `temporada` 
    FOR EACH ROW
BEGIN
    INSERT INTO logs ( `LOG_Usuario`, `LOG_Msg`)
    VALUES (CURRENT_USER,'El Estado de una temporada ha sido actualizado');
END$$

DELIMITER ;


ALTER TABLE `partido`
  ADD CONSTRAINT `fk_temporada_partido` FOREIGN KEY (`TEM_ID`) REFERENCES `temporada` (`TEM_ID`),
  ADD CONSTRAINT `fk_arbitro_partido` FOREIGN KEY (`ARB_DNI`) REFERENCES `arbitro` (`ARB_DNI`);

ALTER TABLE `equipo`
  ADD CONSTRAINT `fk_entrenador_equipo` FOREIGN KEY (`ENT_DNI`) REFERENCES `entrenador` (`ENT_DNI`);

ALTER TABLE `incluyeEquipo`
  ADD CONSTRAINT `fk_equipo_incluyeEquipo` FOREIGN KEY (`EQU_ID`) REFERENCES `equipo` (`EQU_ID`),
  ADD CONSTRAINT `fk_temporada_incluyeEquipo` FOREIGN KEY (`TEM_ID`) REFERENCES `temporada` (`TEM_ID`);


COMMIT;