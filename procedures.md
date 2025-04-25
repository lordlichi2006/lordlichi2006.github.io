[Volver](index.md)

# DOCUMENTACION PROCEDURES

## Índice

- [Procedure usada para generar clasificacion](#procedure-usada-para-generar-clasificacion)
- [Procedures con Estructura alternativa](#2-procedures-con-estructura-alternativa)
- [Procedures con Estructura de control alternativa múltiple](#creación-de-procedimientos-con-la-estructura-de-control-alternativa-múltiple)
- [Procedures con Excepciones](#12-procedimientos-con-excepciones)
- [Procedures con Cursores](#4-procedures-con-cursores-2-con-consulta-compleja)
- [Procedures con Case](#2-procedimientos-que-usen-case)



## Procedure usada para generar clasificacion
```sql
DELIMITER //
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
END //
```

## 2 PROCEDURES CON ESTRUCTURA ALTERNATIVA:

1. Este procedimiento inserta un equipo si no existe en la base de datos.
```sql

DROP PROCEDURE IF EXISTS InsertarEquipo; -- Hacer el drop por separado + Delimitador con ;

DELIMITER //

CREATE PROCEDURE InsertarEquipo(p_nombre VARCHAR(255), p_fechaFundacion YEAR,p_dniEntrenador INT)
BEGIN
    DECLARE equipo_existe INT;
    DECLARE entrenador_existe INT;

    -- Verificar si el equipo ya existe
    SELECT COUNT(*) INTO equipo_existe
    FROM equipo
    WHERE EQU_Nombre = p_nombre;

    IF equipo_existe > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El equipo ya existe';
    ELSE
        -- Verificar si el entrenador ya existe
        SELECT COUNT(*) INTO entrenador_existe
        FROM entrenador
        WHERE ENT_DNI = p_dniEntrenador;

        -- Si el entrenador no existe, insertarlo
        IF entrenador_existe = 0 THEN
            INSERT INTO entrenador (ENT_DNI)
            VALUES (p_dniEntrenador);
        END IF;

        -- Insertar el equipo
        INSERT INTO equipo (EQU_Nombre, EQU_FchaFundacion, ENT_DNI)
        VALUES (p_nombre, p_fechaFundacion, p_dniEntrenador);
    END IF;
END//

```
---


2. Este procedimiento modifica el nombre de un equipo, el año de fundación y el dni del presidente si el nombre del equipo EXISTE en la base de datos.
```sql

DROP PROCEDURE IF EXISTS ModificarEquipo;
DELIMITER //

CREATE PROCEDURE ModificarEquipo(
    IN nombreEquipoActual VARCHAR(50), 
    IN nuevoNombreEquipo VARCHAR(50), 
    IN nuevoAñoFundacion INT, 
    IN nuevoDniEntrenador VARCHAR(20)
)
BEGIN
    DECLARE existe INT;
    DECLARE nombreDuplicado INT;
    DECLARE dniValido INT;

    -- Verifico si el equipo existe
    SELECT COUNT(*) INTO existe 
    FROM equipo 
    WHERE EQU_Nombre = nombreEquipoActual;

    -- Verifico si el nuevo nombre ya existe en otro equipo
    SELECT COUNT(*) INTO nombreDuplicado 
    FROM equipo 
    WHERE EQU_Nombre = nuevoNombreEquipo AND EQU_Nombre <> nombreEquipoActual;

    -- Verifico si el DNI del entrenador existe en la tabla entrenador
    SELECT COUNT(*) INTO dniValido 
    FROM entrenador 
    WHERE ENT_DNI = nuevoDniEntrenador;

    -- Si el equipo existe
    IF existe > 0 THEN
        -- Si el nuevo nombre no está duplicado
        IF nombreDuplicado = 0 THEN
            -- Si el DNI del entrenador es válido
            IF dniValido > 0 THEN
                -- Actualizo el equipo
                UPDATE equipo
                SET EQU_Nombre = nuevoNombreEquipo,
                    EQU_FchaFundacion = nuevoAñoFundacion,
                    ENT_DNI = nuevoDniEntrenador
                WHERE EQU_Nombre = nombreEquipoActual;

                SELECT CONCAT('Equipo ', nombreEquipoActual, ' actualizado a: ', nuevoNombreEquipo, ' - ', nuevoAñoFundacion, ' - ', nuevoDniEntrenador) AS Mensaje;
            ELSE
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Error: El DNI del entrenador no existe en la base de datos';
            END IF;
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El nuevo nombre del equipo ya existe en la base de datos';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El equipo no existe en la base de datos';
    END IF;
END //

DELIMITER ;


```

---

## Creación de procedimientos con la estructura de control alternativa múltiple.

1. Este procedimiento gestiona las temporadas. Hay 3 acciones, insertar temporada, actualizarla o borrarla

```sql

DROP PROCEDURE IF EXISTS GestionarTemporada; -- Hacer el drop por separado + Delimitador con ;

DELIMITER //

CREATE PROCEDURE GestionarTemporada(operacion VARCHAR(10), id_temporada INT, estado_nuevo VARCHAR(20), nombre_temporada VARCHAR(50))  
BEGIN
    IF operacion = 'INSERTAR' THEN
        INSERT INTO temporada (TEM_ID, TEM_Estado, TEM_Nombre)  
        VALUES (id_temporada, 'Sin Iniciar', nombre_temporada);  

        SELECT 'Temporada insertada correctamente' AS Mensaje;

    ELSEIF operacion = 'ACTUALIZAR' THEN
        UPDATE temporada
        SET TEM_Estado = estado_nuevo  
        WHERE TEM_ID = id_temporada;  

        SELECT CONCAT('Estado de la temporada ', id_temporada, ' actualizado a ', estado_nuevo) AS Mensaje;

    ELSEIF operacion = 'ELIMINAR' THEN
        DELETE FROM equipo  
        WHERE TEM_ID = id_temporada;  

        DELETE FROM temporada  
        WHERE TEM_ID = id_temporada;

        SELECT 'Temporada eliminada correctamente' AS Mensaje;

    ELSE
        SELECT 'Operación no válida. Use INSERTAR, ACTUALIZAR o ELIMINAR' AS Mensaje;
    END IF;
END //

-- // en el Delimitador

```


---

## 12 Procedimientos Con Excepciones

1. Este procedimiento busca el nombre del equipo, si no lo encuentra sale un mensaje de error. Si existe, mostrará el escudo de ese equipo.
```sql
DROP PROCEDURE IF EXISTS MostrarEscudoEquipo; -- Hacer el drop por separado + Delimitador con ;

DELIMITER //

CREATE PROCEDURE MostrarEscudoEquipo(nombreEscudo VARCHAR(50))
BEGIN
    DECLARE encontrado BOOL DEFAULT TRUE;
    DECLARE escudo VARCHAR(255);

    -- Manejador de error para capturar cuando no se encuentra un resultado
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET encontrado = FALSE;

    -- Buscar el escudo del equipo mediante el nombre
    SELECT Escudo INTO escudo 
    FROM equipo 
    WHERE EQU_Nombre = nombreEscudo;

    -- Si no se encuentra el equipo, mostrar mensaje de error
    IF encontrado = FALSE THEN
        SELECT CONCAT('No existe ningún equipo con el nombre ', nombreEscudo) AS ERROR;
    ELSE
        -- Si lo encuentra, mostrar el escudo
        SELECT escudo AS Escudo;
    END IF;
END//

-- // en el Delimitador

```



2. Este procedimiento inserta un árbitro, pero lanza errores si el DNI ya existe o si el nombre está vacío.

```sql

DROP PROCEDURE IF EXISTS InsertarArbitroSeguro;

DELIMITER //

CREATE PROCEDURE InsertarArbitroSeguro(
    dni_arbitro INT,
    nombre_arbitro VARCHAR(100))
BEGIN
    DECLARE existe INT;

    IF nombre_arbitro IS NULL OR nombre_arbitro = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El nombre del árbitro no puede estar vacío.';
    END IF;

    SELECT COUNT(*) INTO existe
    FROM arbitro
    WHERE ARB_DNI = dni_arbitro;

    IF existe > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El árbitro ya está registrado con ese DNI.';
    ELSE
        INSERT INTO arbitro (ARB_DNI, ARB_Nombre)
        VALUES (dni_arbitro, nombre_arbitro);
        
        SELECT 'Árbitro insertado correctamente' AS Mensaje;
    END IF;
END//

DELIMITER ;

```

3. Este procedimiento elimina un jugador si existe. Si no existe, lanza un error.

```sql

DROP PROCEDURE IF EXISTS BorrarJugador;

DELIMITER //
CREATE PROCEDURE BorrarJugador(jugadorID INT)
BEGIN
    DECLARE existe INT;

    SELECT COUNT(*) INTO existe
    FROM jugador
    WHERE JUG_DNI = jugadorID;

    IF existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No existe un jugador con ese ID.';
    ELSE
        DELETE FROM jugador 
        WHERE JUG_DNI = jugadorID;
        
        SELECT CONCAT('Jugador con ID ', jugadorID, ' eliminado correctamente') AS Mensaje;
    END IF;
END//
DELIMITER ;

```

4.  Este procedimiento actualiza el nombre de un entrenador. Si no existe el DNI o el nuevo nombre es inválido, lanza errores.

```sql

DROP PROCEDURE IF EXISTS ActualizarNombreEntrenador;
DELIMITER //
CREATE PROCEDURE ActualizarNombreEntrenador(dni INT, nuevoNombre VARCHAR(100))
BEGIN
    DECLARE existe INT;

    IF nuevoNombre IS NULL OR LENGTH(TRIM(nuevoNombre)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El nuevo nombre no puede estar vacío.';
    END IF;

    SELECT COUNT(*) INTO existe
    FROM entrenador
    WHERE ENT_DNI = dni;

    IF existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No existe un entrenador con ese DNI.';
    ELSE
        UPDATE entrenador
        SET ENT_Nombre = nuevoNombre
        WHERE ENT_DNI = dni;
        SELECT 'Nombre del entrenador actualizado correctamente' AS Mensaje;
    END IF;
END//


```

5. Este procedimiento inserta un jugador solo si el equipo al que se asocia existe y tiene menos de 15 jugadores.

```sql
DROP PROCEDURE IF EXISTS InsertarJugadorConLimite;

DELIMITER //

CREATE PROCEDURE InsertarJugadorConLimite(jugadorID INT, nombreJugador VARCHAR(100), equipoID INT)
BEGIN
    DECLARE existeEquipo INT;
    DECLARE numJugadores INT;

    SELECT COUNT(*) INTO existeEquipo FROM equipo WHERE EQU_ID = equipoID;
    IF existeEquipo = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El equipo no existe.';
    END IF;

    SELECT COUNT(*) INTO numJugadores
    FROM incluyejugador
    WHERE EQU_TEM_ID = equipoID;

    IF numJugadores >= 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El equipo ya tiene el número máximo de jugadores.';
    END IF;

    INSERT INTO jugador (JUG_ID, JUG_Nombre)
    VALUES (jugadorID, nombreJugador);

    INSERT INTO incluyejugador (JUG_ID, EQU_TEM_ID)
    VALUES (jugadorID, equipoID);

    SELECT 'Jugador insertado correctamente' AS Mensaje;
END//
```

6. Verifica que ambos equipos existen y que no sean el mismo antes de insertar un partido.

```sql
DROP PROCEDURE IF EXISTS InsertarPartidoSeguro;

DELIMITER //


CREATE PROCEDURE InsertarPartidoSeguro(idPartido INT, idEquipoLocal INT, idEquipoVisitante INT, fecha DATE)

BEGIN
    DECLARE existeLocal INT;
    DECLARE existeVisitante INT;

    IF idEquipoLocal = idEquipoVisitante THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Un equipo no puede jugar contra sí mismo.';
    END IF;

    SELECT COUNT(*) INTO existeLocal FROM equipo WHERE EQU_ID = idEquipoLocal;
    SELECT COUNT(*) INTO existeVisitante FROM equipo WHERE EQU_ID = idEquipoVisitante;

    IF existeLocal = 0 OR existeVisitante = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Uno o ambos equipos no existen.';
    END IF;

    INSERT INTO partido (PAR_ID, EQU_Local, EQU_Visitante, PAR_Fecha)
    VALUES (idPartido, idEquipoLocal, idEquipoVisitante, fecha);

    SELECT 'Partido insertado correctamente' AS Mensaje;
END//

```
7. Mostrar cuantos equipos tiene una temporada
```sql

DELIMITER //

CREATE PROCEDURE ContarEquiposPorTemporada(IN p_TEM_ID INT)
BEGIN
    DECLARE numEquipos INT;
    DECLARE errMsg VARCHAR(255);

    -- Manejador de errores: Si no se encuentra la temporada, muestra un mensaje de error
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET errMsg = 'Error: La temporada especificada no existe o hubo un problema con la consulta.';
        SELECT errMsg AS MensajeDeError;
    END;

    -- Intentamos contar los equipos para la temporada especificada
    SELECT COUNT(*) INTO numEquipos
    FROM incluyeEquipo
    WHERE TEM_ID = p_TEM_ID;

    -- Si numEquipos es nulo (por ejemplo, si no hay equipos asociados a esa temporada), mostramos un mensaje adecuado
    IF numEquipos IS NULL THEN
        SELECT 'No hay equipos para esta temporada.' AS Mensaje;
    ELSE
        SELECT CONCAT('Número de equipos en la temporada ', p_TEM_ID, ': ', numEquipos) AS Resultado;
    END IF;
END //

DELIMITER ;
```


## 4 Procedures con cursores, 2 con consulta compleja

1. Recorrer jugadores y mostrar sus nombres
```sql
DELIMITER //

CREATE PROCEDURE MostrarNombresJugadores()
BEGIN
    DECLARE fin INT DEFAULT 0;
    DECLARE jugadorID INT;
    DECLARE jugadorNombre VARCHAR(255);
    DECLARE c CURSOR FOR 
        SELECT JUG_DNI, JUG_Nombre FROM jugador;
    
    -- Handler para manejar el fin de los datos
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;

    OPEN c;
    FETCH c INTO jugadorID, jugadorNombre;

    WHILE fin = 0 DO
        -- Mostrar el nombre del jugador
        SELECT jugadorNombre AS NombreJugador;
        FETCH c INTO jugadorID, jugadorNombre;
    END WHILE;

    CLOSE c;
END //

DELIMITER ;

```

2. Mostrar los entrenadores de todos los equipos
```sql
DELIMITER //

CREATE PROCEDURE MostrarEntrenadores()

BEGIN

    DECLARE fin INT DEFAULT 0;
    DECLARE entrenadorDNI INT;
    DECLARE nombreEntrenador VARCHAR(255);
    DECLARE nombreEquipo VARCHAR(50);


    DECLARE c CURSOR FOR 
        SELECT ENT_DNI, ENT_Nombre FROM entrenador;

    -- Handler para manejar el fin de los datos
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;

    OPEN c;
    FETCH c INTO entrenadorDNI, nombreEntrenador;

    WHILE fin = 0 DO
        -- nombre de qeuipo
        SELECT EQU_Nombre INTO nombreEquipo 
        FROM equipo 
        WHERE ENT_DNI = entrenadorDNI;

        -- Mostrar entrenador y el equipo
        SELECT nombreEntrenador AS Entrenador, nombreEquipo AS Equipo;

        FETCH c INTO entrenadorDNI, nombreEntrenador;
    END WHILE;

    CLOSE c;
END //

DELIMITER ;
```

3. Mostrar Cuantos jugadores tiene cada equipo

```sql

DELIMITER //

CREATE PROCEDURE ContarJugadoresPorEquipo()

BEGIN
    DECLARE fin INT DEFAULT 0;
    DECLARE equipoID INT;
    DECLARE equipoNombre VARCHAR(50);
    DECLARE cuentaJugadores INT;

    DECLARE c CURSOR FOR 
        SELECT EQU_ID FROM equipo;

    -- Handler para manejar el fin de los datos
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;

    OPEN c;
    FETCH c INTO equipoID;

    WHILE fin = 0 DO
        -- cojer nombre de equiop
        SELECT EQU_Nombre INTO equipoNombre 
        FROM equipo 
        WHERE EQU_ID = equipoID;
        
        -- contar jugadores
        SELECT COUNT(*) INTO cuentaJugadores 
        FROM incluyeJugador 
        WHERE EQU_TEM_ID = equipoID;
        
        -- Mostrar el nombre del equipo y n de jugadores
        SELECT equipoNombre AS NombreEquipo, cuentaJugadores AS Jugadores;

        FETCH c INTO equipoID;
    END WHILE;

    CLOSE c;
END //

DELIMITER ;
```

## 2 Procedimientos que usen CASE

1. Mostrar todos los jugadores y clasificarlos dependiendo de altura

```sql
DELIMITER //

CREATE PROCEDURE ClasificarPorAlturaJugador()
BEGIN
    -- Clasificación de todos los jugadores por su altura
    SELECT 
        JUG_Nombre AS NombreJugador,
        CASE
            WHEN JUG_Altura < 1.60 THEN 'Bajo'
            WHEN JUG_Altura BETWEEN 1.60 AND 1.75 THEN 'Altura Normal'
            WHEN JUG_Altura BETWEEN 1.76 AND 1.90 THEN 'Alto'
            WHEN JUG_Altura > 1.90 THEN 'Muy Alto'
            ELSE 'Desconocido'
        END AS CategoriaAltura
    FROM jugador;
END //

DELIMITER ;
```
2. Mostrar todos los jugadores y clasificarlos dependiendo de su peso

```sql
DELIMITER //

CREATE PROCEDURE ClasificarPorPesoJugador()
BEGIN
    -- Clasificación de todos los jugadores por su peso
    SELECT 
        JUG_Nombre AS NombreJugador,
        CASE
            WHEN JUG_Peso < 60 THEN 'Bajo Peso'
            WHEN JUG_Peso BETWEEN 60 AND 80 THEN 'Peso Normal'
            WHEN JUG_Peso BETWEEN 81 AND 100 THEN 'Sobrepeso'
            WHEN JUG_Peso > 100 THEN 'Obeso'
            ELSE 'Desconocido'
        END AS CategoriaPeso
    FROM jugador;
END //

DELIMITER ;

```