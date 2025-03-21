-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 12-03-2025 a las 08:25:12
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+01:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `federacion_rugby`
--
DROP DATABASE IF EXISTS `federacion_rugby`;
CREATE DATABASE IF NOT EXISTS `federacion_rugby` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `federacion_rugby`;

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarEquipo` (`nombre` VARCHAR(50), `fchaFunc` YEAR, `DNIEntre`INT(11) )   
  BEGIN
    DECLARE existe INT;
    
    SELECT COUNT(*) INTO existe FROM equipo WHERE Nombre_equipo = nombre;
    
    IF existe = 0 THEN

        INSERT INTO equipo (Nombre_equipo, Año_fundacion, DNI_entrenador) VALUES (nombre, fchaFunc, DNIEntre);

        SELECT CONCAT('Equipo "', nombreEquipo, '" agregado correctamente.') AS Mensaje;
    ELSE
        SELECT CONCAT('El equipo "', nombreEquipo, '" ya existe.') AS Mensaje;
    END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `arbitro`
--

CREATE TABLE `arbitro` (
  `DNI_Arbitro` int(11) NOT NULL,
  `Nombre_arbitro` varchar(100) NOT NULL,
  `Certificacion` varchar(100) NOT NULL,
  `Años_experiencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `arbitro`
--

INSERT INTO `arbitro` (`DNI_Arbitro`, `Nombre_arbitro`, `Certificacion`, `Años_experiencia`) VALUES
(40001, 'Fernando Alvarez', 'Certificación Internacional', 10),
(40002, 'Pedro Sanchez', 'Certificación Nacional', 8),
(40003, 'Juan Martinez', 'Certificación Nacional', 6),
(40004, 'Javier Gomez', 'Certificación Regional', 5),
(40005, 'Alberto Ruiz', 'Certificación Internacional', 12);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entrenador`
--

CREATE TABLE `entrenador` (
  `DNI_Entrenador` int(11) NOT NULL,
  `Nombre_entrenador` varchar(100) NOT NULL,
  `Certificado` varchar(100) NOT NULL,
  `ID_Equipo` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `entrenador`
--

INSERT INTO `entrenador` (`DNI_Entrenador`, `Nombre_entrenador`, `Certificado`, `ID_Equipo`) VALUES
(30001, 'Luis Garcia', 'Certificado Oficial Nivel 3', 2),
(30002, 'Manuel Perez', 'Certificado Oficial Nivel 2', 1),
(30003, 'Carlos Morales', 'Certificado Oficial Nivel 3', 5),
(30004, 'Rafael Torres', 'Certificado Oficial Nivel 1',  3),
(30005, 'Santiago Lopez', 'Certificado Oficial Nivel 2',  6),
(30006, 'Jorge Martinez', 'Certificado Oficial Nivel 1',  4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipo`
--

CREATE TABLE `equipo` (
  `Nombre_equipo` varchar(50) NOT NULL,
  `Año_fundacion` year(4) NOT NULL,
  `DNI_entrenador` int(11) NOT NULL,
  `ID_Temporada` int(11) DEFAULT NULL,
  `ID_Equipo` int(11) DEFAULT NULL,
  `Escudo` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `equipo`
--

INSERT INTO `equipo` (`Nombre_equipo`, `Año_fundacion`, `DNI_entrenador`, `ID_Temporada`, `ID_Equipo`, `Escudo`) VALUES
('Barca Rugby', '1924', 30002, 1, 1, 'EQ1'),
('Cisneros', '1943', 30001, 1, 2, 'EQ2'),
('Club Polideportivo Las Abelles', '1971', 30004, 2, 3, 'EQ3'),
('CRC Pozuelo', '1963', 30006, 2, 4, 'EQ4'),
('Labiana Real Rugby Club', '2000', 30003, 3, 5, 'EQ5'),
('Unio Esportiva Santboiana', '1921', 30005, 3, 6, 'EQ6');
-- --------------------------------------------------------


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jugador`
--

CREATE TABLE `jugador` (
  `DNI_jugador` int(11) NOT NULL,
  `Nombre_jugador` varchar(100) NOT NULL,
  `Fecha_nacimiento` date NOT NULL,
  `ID_Equipo` int(11) DEFAULT NULL,
  `Posición` varchar(50) DEFAULT NULL,
  `Altura` decimal(4,2) DEFAULT NULL,
  `Peso` decimal(5,2) DEFAULT NULL,
  `Dorsal` int(11) DEFAULT NULL,
  `Imágen` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `jugador`
--

INSERT INTO `jugador` (`DNI_jugador`, `Nombre_jugador`, `Fecha_nacimiento`, `ID_Equipo`, `Posición`, `Altura`, `Peso`, `Dorsal`, `Imágen`) VALUES
(10567891, 'Carlos Gómez', '1997-05-12', 1, 'Delantero', 1.75, 70.50, 9, 'A1'),
(10374568, 'Manuel López', '1996-08-23', 1, 'Defensa', 1.80, 75.30, 4, 'A3'),
(10892346, 'Javier Pérez', '1998-03-17', 1, 'Delantero', 1.75, 72.50, 9, 'A5'),
(10321099, 'Alejandro Ruiz', '1999-11-30', 1, 'Defensa', 1.82, 78.00, 4, 'A7'),
(10789013, 'Sergio Fernández', '2000-07-05', 1, 'Centrocampista', 1.78, 73.50, 11, 'A9'),
(10654322, 'David Martínez', '1997-01-20', 1, 'Centrocampista', 1.77, 71.00, 10, 'A11'),
(10678902, 'Miguel Sánchez', '1999-11-12', 2, 'Centrocampista', 1.80, 74.50, 7, 'B2'),
(10456790, 'Daniel Ramírez', '1995-01-11', 2, 'Delantero', 1.79, 72.00, 3, 'B4'),
(10012346, 'Jesús Herrera', '1997-02-25', 2, 'Defensa', 1.83, 78.10, 5, 'B6'),
(10874562, 'Francisco Torres', '1994-09-15', 2, 'Centrocampista', 1.80, 74.00, 9, 'B8'),
(10165795, 'Antonio Castro', '1996-04-07', 2, 'Defensa', 1.85, 79.30, 1, 'B10'),
(10987313, 'Juan Moreno', '1999-06-10', 2, 'Delantero', 1.80, 73.20, 13, 'B12'),
(10273655, 'Pedro Ortiz', '1998-07-17', 2, 'Delantero', 1.79, 72.20, 11, 'C1'),
(10328411, 'Rubén Jiménez', '1997-11-30', 3, 'Defensa', 1.83, 80.10, 5, 'C3'),
(10682160, 'Hugo Navarro', '1995-12-20', 3, 'Delantero', 1.80, 74.50, 7, 'C5'),
(10957322, 'Raúl Domínguez', '1996-03-01', 3, 'Defensa', 1.85, 79.00, 9, 'C7'),
(10285962, 'Iván Castillo', '1998-10-19', 3, 'Centrocampista', 1.78, 72.30, 3, 'C9'),
(10316575, 'Adrián Vega', '1999-05-25', 3, 'Centrocampista', 1.80, 74.00, 13, 'C11'),
(10398766, 'Fernando León', '2000-01-14', 3, 'Delantero', 1.77, 70.50, 11, 'C12'),
(10493211, 'Óscar Cano', '1997-08-09', 4, 'Defensa', 1.84, 79.50, 6, 'D1'),
(10681935, 'Luis Maldonado', '1996-04-25', 4, 'Centrocampista', 1.79, 73.20, 7, 'D3'),
(10876421, 'Mario Rojas', '1998-12-15', 4, 'Delantero', 1.81, 75.00, 9, 'D5'),
(10316576, 'Adrián Vega', '1999-05-25', 4, 'Centrocampista', 1.80, 74.00, 13, 'D7'),
(10398767, 'Fernando León', '2000-01-14', 4, 'Delantero', 1.77, 70.50, 11, 'D9'),
(10316578, 'Carlos Pérez', '1997-06-15', 4, 'Centrocampista', 1.78, 72.40, 8, 'D11'),
(10493212, 'Óscar Cano', '1997-08-09', 5, 'Defensa', 1.84, 79.50, 6, 'E1'),
(10681936, 'Luis Maldonado', '1996-04-25', 5, 'Centrocampista', 1.79, 73.20, 7, 'E3'),
(10876422, 'Mario Rojas', '1998-12-15', 5, 'Delantero', 1.81, 75.00, 9, 'E5'),
(10957323, 'Raúl Domínguez', '1996-03-01', 5, 'Defensa', 1.85, 79.00, 9, 'E7'),
(10285963, 'Iván Castillo', '1998-10-19', 5, 'Centrocampista', 1.78, 72.30, 3, 'E9'),
(12413545, 'Txema Miguel', '1976-10-19', 5, 'Centrocampista', 1.8, 72.30, 3, 'E11'),
(10316577, 'Adrián Vega', '1999-05-25', 6, 'Centrocampista', 1.80, 74.00, 13, 'F1'),
(10398768, 'Fernando León', '2000-01-14', 6, 'Delantero', 1.77, 70.50, 11, 'F3'),
(10493213, 'Óscar Cano', '1997-08-09', 6, 'Defensa', 1.84, 79.50, 6, 'F5'),
(10681937, 'Luis Maldonado', '1996-04-25', 6, 'Centrocampista', 1.79, 73.20, 7, 'F7'),
(10876423, 'Mario Rojas', '1998-12-15', 6, 'Delantero', 1.81, 75.00, 9, 'F9'),
(69696969, 'Mikel Resa', '2006-8-2', 6, 'Centrocampista', 1.72, 2.30, 3, 'a');



-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `participa`
--

CREATE TABLE `participa` (
  `ID_Partido` int(11) NOT NULL,
  `DNI_jugador` int(11) NOT NULL,
  `Num_minutos_jugados` int(11) NOT NULL,
  `Num_tarjetas_rojas` int(11) DEFAULT 0,
  `Num_tarjetas_amarillas` int(11) DEFAULT 0,
  `Pts_anotados` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `participa`
--

INSERT INTO `participa` (`ID_Partido`, `DNI_jugador`, `Num_minutos_jugados`, `Num_tarjetas_rojas`, `Num_tarjetas_amarillas`, `Pts_anotados`) VALUES 
(1, 10567891, 60, 0, 1, 5),
(1, 10374568, 70, 0, 0, 7),
(1, 10892346, 55, 0, 0, 3),
(1, 10321099, 50, 1, 0, 0),
(1, 10789013, 65, 0, 1, 10),
(2, 10654322, 80, 0, 0, 8),
(2, 10678902, 75, 0, 1, 4),
(2, 10456790, 78, 0, 0, 3),
(2, 10012346, 72, 0, 1, 6),
(2, 10874562, 65, 0, 0, 1),
(3, 10165795, 68, 0, 0, 5),
(3, 10987313, 74, 0, 0, 8),
(3, 10273655, 70, 0, 1, 4),
(3, 10328411, 50, 1, 0, 0),
(3, 10682160, 60, 0, 1, 3),
(4, 10957322, 80, 0, 0, 10),
(4, 10285962, 70, 0, 1, 6),
(4, 10316575, 68, 0, 0, 4),
(4, 10398766, 65, 1, 0, 0),
(4, 10493211, 72, 0, 0, 2),
(5, 10681935, 75, 0, 1, 7),
(5, 10876421, 80, 0, 0, 12),
(5, 10957323, 78, 0, 0, 8),
(5, 10316576, 50, 0, 1, 3),
(5, 10316578, 70, 0, 0, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partido`
--

CREATE TABLE `partido` (
  `ID_Partido` INT(11) NOT NULL,
  `ID_Temporada` INT(11) NOT NULL,
  `DNI_Arbitro` INT(11),
  `ID_Equipo_loc` INT(11) NOT NULL,
  `ID_Equipo_vis` INT(11) NOT NULL,
  `Puntos_loc` TINYINT,  
  `Puntos_vis` TINYINT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcado de datos para la tabla `partido`
--

INSERT INTO `partido` (`ID_Partido`, `ID_Temporada`, `DNI_Arbitro`, `ID_Equipo_loc`, `ID_Equipo_vis`, `Puntos_loc`, `Puntos_vis`) VALUES
(1, 1, 40001, 1, 2, 12, 31),
(2, 1, 40002, 2, 1, 33, 21),
(3, 1, 40003, 3, 4, 12, 31),
(4, 1, 40004, 4, 3, 33, 21),
(5, 1, 40005, 6, 5, 12, 31),
(6, 2, 40001, 1, 2, 33, 21),
(7, 2, 40002, 2, 1, 12, 31),
(8, 2, 40003, 3, 4, 33, 21),
(9, 2, 40004, 4, 3, 12, 31),
(10, 2, 40005, 6, 5, 33, 21);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `temporada`
--

CREATE TABLE `temporada` (
  `ID_Temporada` int(11) NOT NULL,
  `Estado` enum('En Curso','Finalizada',"Sin Iniciar") NOT NULL,
  `Año` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `temporada`
--

INSERT INTO `temporada` (`ID_Temporada`, `Estado`, `Año`) VALUES
(1, 'En Curso', '2024'),
(2, 'Finalizada', '2023'),
(3, 'Sin Iniciar','2025');

CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(100),
    message TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER modificacionTemporada
  AFTER UPDATE OF Estado ON temporada
  FOR EACH ROW
BEGIN
    INSERT INTO update_logs ( usuario, message)
    VALUES (CURRENT_USER,'El Estado de una temporada ha sido actualizado');
END;
--
-- Índices para tablas volcadas
--

-- Indices de la tabla `arbitro`
--
ALTER TABLE `arbitro`
  ADD PRIMARY KEY (`DNI_Arbitro`);

--
-- Indices de la tabla `entrenador`
--
ALTER TABLE `entrenador`
  ADD PRIMARY KEY (`DNI_Entrenador`),
  ADD KEY `ID_Equipo` (`ID_Equipo`);

--
-- Indices de la tabla `equipo`
--
ALTER TABLE `equipo`
  ADD PRIMARY KEY (`ID_Equipo`),
  ADD KEY `DNI_entrenador` (`DNI_entrenador`),
  ADD KEY `FK_temporada` (`ID_Temporada`);


--
-- Indices de la tabla `jugador`
--
ALTER TABLE `jugador`
  ADD PRIMARY KEY (`DNI_jugador`),
  ADD KEY `ID_Equipo` (`ID_Equipo`);

--
-- Indices de la tabla `participa`
--
ALTER TABLE `participa`
  ADD PRIMARY KEY (`ID_Partido`,`DNI_jugador`),
  ADD KEY `DNI_jugador` (`DNI_jugador`);

--
-- Indices de la tabla `partido`
--
ALTER TABLE `partido`
  ADD PRIMARY KEY (`ID_Partido`),
  ADD KEY `ID_Temporada` (`ID_Temporada`);

--
-- Indices de la tabla `temporada`
--
ALTER TABLE `temporada`
  ADD PRIMARY KEY (`ID_Temporada`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `partido`
--
ALTER TABLE `partido`
  MODIFY `ID_Partido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `temporada`
--
ALTER TABLE `temporada`
  MODIFY `ID_Temporada` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--


-- Filtros para la tabla `entrenador`
--
ALTER TABLE `entrenador`
  ADD CONSTRAINT `entrenador_ibfk_1` FOREIGN KEY (`ID_Equipo`) REFERENCES `equipo` (`ID_Equipo`);

--
-- Filtros para la tabla `equipo`
--
ALTER TABLE `equipo`
  ADD CONSTRAINT `FK_temporada` FOREIGN KEY (`ID_Temporada`) REFERENCES `temporada` (`ID_Temporada`),
  ADD CONSTRAINT `equipo_ibfk_1` FOREIGN KEY (`DNI_entrenador`) REFERENCES `entrenador` (`DNI_entrenador`);

--
-- Filtros para la tabla `jugador`
--
ALTER TABLE `jugador`
  ADD CONSTRAINT `jugador_ibfk_1` FOREIGN KEY (`ID_Equipo`) REFERENCES `equipo` (`ID_Equipo`);

--
-- Filtros para la tabla `participa`
--
ALTER TABLE `participa`
  ADD CONSTRAINT `participa_ibfk_1` FOREIGN KEY (`ID_Partido`) REFERENCES `partido` (`ID_Partido`),
  ADD CONSTRAINT `participa_ibfk_2` FOREIGN KEY (`DNI_jugador`) REFERENCES `jugador` (`DNI_jugador`);

--
-- Filtros para la tabla `partido`
--
ALTER TABLE `partido`
  ADD CONSTRAINT `partido_ibfk_1` FOREIGN KEY (`ID_Temporada`) REFERENCES `temporada` (`ID_Temporada`),
  ADD CONSTRAINT `partido_ibfk_2` FOREIGN KEY (`ID_Equipo_loc`) REFERENCES `equipo` (`ID_Equipo`),
  ADD CONSTRAINT `partido_ibfk_3` FOREIGN KEY (`ID_Equipo_vis`) REFERENCES `equipo` (`ID_Equipo`);


COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
