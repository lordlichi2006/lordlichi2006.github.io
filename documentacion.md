# DOCUMENTACION BASES DE DATOS G5

**Archivo SQL de la base de datos :**
[federacion_rugby_v3.sql](federacion_rugby_v3.sql)

## Gestion De Usuarios y Vistas

### Creación De Usuarios

Gestor no puede iniciar temporadas
Árbitro solo puede modificar los resultados de los partidos
Usuario normal solo puede ver la temporada iniciada

```sql
CREATE USER 'Alfredo'@'rugby.com' IDENTIFIED BY 'alfredo1'; -- (Árbitro)

CREATE USER 'Ander'@'rugby.com' IDENTIFIED BY 'Ander1'; -- (Gestor)

CREATE USER 'Diego'@'rugby.com' IDENTIFIED BY 'Diego1'; --  (Usuario lector)

CREATE USER 'Sandra'@'rugby.com' IDENTIFIED BY 'Ander1'; -- (Insertador)
```
![](img1.png)

Vamos a crear un usuario llamado Antonio y lo vamos a eliminar seguido.

```sql 
CREATE USER 'Antonio'@'rugby.com' IDENTIFIED BY 'Antonio123'; 
```

![](img2.png)
```sql
DROP USER 'Antonio'@'rugby.com';
```
![](img3.png)

Vamos a restablecer la contraseña al usuario “Gestor”.
```sql
SET PASSWORD FOR 'Ander'@'rugby.com' = PASSWORD('Ander12');
```

### Creación de Roles y Asignación de Privilegios:

```sql
CREATE ROLE 'Arbitro';

GRANT 'Arbitro' TO 'Alfredo'@'rugby.com';

CREATE ROLE 'Gestor';

GRANT 'Gestor' TO 'Ander'@'rugby.com';

CREATE ROLE 'Usuario_Lector';

GRANT 'Usuario_Lector' TO 'Diego'@'rugby.com';

CREATE ROLE 'Insertador';

GRANT 'Insertador' TO 'Sandra'@'rugby.com';
```
Le damos permisos al árbitro para que pueda modificar los goles del equipo local y del visitante.

```sql
GRANT UPDATE (Goles_Local, Goles_Visitante) ON partido TO 'Arbitro';
```

Le damos permisos al gestor para que solo pueda entrar en la tabla de temporadas para iniciarla o finalizarla.

```sql
GRANT UPDATE federacion_rugby.* TO 'Insertador';
```

Le damos permisos al Insertador para que pueda insertar datos en todas las tablas de la base de datos.

```sql
GRANT INSERT ON (Estado) ON temporada TO 'Gestor';
```

Creamos unas VISTAS para limitar el acceso a Usuario_Lector a la temporada iniciada:

Esta vista permitirá ver los Equipos de la Temporada Iniciada→


```sql
-- Tini = Temporada Iniciada
CREATE VIEW equipos_Tini AS

SELECT *

FROM equipos e

JOIN temporadas t ON t.id = e.temporada_id

WHERE t.estado = 'En Curso';
```


Una vez creada esa vista, le asignaremos los permisos.

```sql
GRANT SELECT ON equipos_Tini TO 'Usuario_Lector';
```

Con este comando: SHOW GRANTS FOR ‘Usuario_Lector’ podemos ver los permisos que tienen los usuarios, por ejemplo vamos a mostrar los permisos que tiene el Usuario Lector. Debería de tener acceso a la vista creada y a las tablas Equipo, Partido y Jugador.


Ahora, vamos a retirarle el permiso de inserción de datos en tablas a Usuario_Lector.

```sql
REVOKE INSERT ON *.* FROM 'Usuario_Lector';
```

## Creación de Procedimientos

### 2 PROCEDURES CON ESTRUCTURA ALTERNATIVA DOBLE:

1:
Este procedimiento inserta un equipo si no existe en la base de datos.
```sql
CREATE PROCEDURE InsertarEquipo(nombreEquipo VARCHAR(50), añoFundacion INT, dniPresidente VARCHAR(20))

BEGIN
    DECLARE existe INT;

    -- Verifico si el equipo existe
    SELECT COUNT(*) INTO existe 
    FROM equipos 
    WHERE nombre = nombreEquipo;

    -- Si no existe, lo inserto
    IF existe = 0 THEN
        INSERT INTO equipos (Nombre_equipo, Año_fundacion, DNI_entrenador)
        VALUES (nombreEquipo, añoFundacion, dniPresidente);

        SELECT CONCAT(
            'Equipo ', nombreEquipo, 
            ' con año de fundación ', añoFundacion, 
            ' y DNI del entrenador ', dniPresidente, 
            ' agregado correctamente.'
        ) AS Mensaje;
    ELSE
        SELECT CONCAT(
            'Equipo ', nombreEquipo, 
            ' con año de fundación ', añoFundacion, 
            ' y DNI del entrenador ', dniPresidente, 
            ' ya existe.'
        ) AS Mensaje;
    END IF;
END;
```

---

2:
Este procedimiento modifica el nombre de un equipo, el año de fundación y el dni del presidente si el nombre del equipo EXISTE en la base de datos.
```sql
CREATE PROCEDURE ModificarEquipo(nombreEquipoActual VARCHAR(50), nuevoNombreEquipo VARCHAR(50), nuevoAñoFundacion INT, nuevoDniEntrenador VARCHAR(20))
BEGIN
    DECLARE existe INT;

    -- Verifico si ya existe el nombre del equipo
    SELECT COUNT(*) INTO existe 
    FROM equipo 
    WHERE Nombre_equipo = nombreEquipoActual;

    -- Si existe
    IF existe > 0 THEN
        -- Modifico el nombre, el año de fundación y el DNI del entrenador
        UPDATE equipo
        SET Nombre_equipo = nuevoNombreEquipo,
            Año_fundacion = nuevoAñoFundacion,
            DNI_Entrenador = nuevoDniEntrenador
        WHERE Nombre_equipo = nombreEquipoActual;

        SELECT CONCAT('Equipo ', nombreEquipoActual, ' actualizado a: ', nuevoNombreEquipo, ' - ', nuevoAñoFundacion, ' - ', nuevoDniEntrenador) AS Mensaje;
    END IF;
END;
```

---

### Creación de procedimientos con la estructura de control alternativa múltiple.

Este procedimiento gestiona las temporadas. Hay 3 acciones, insertar temporada, actualizarla o borrarla
```sql

CREATE PROCEDURE GestionarTemporada(operacion VARCHAR(10), id_temporada INT, estado_nuevo VARCHAR(20), año VARCHAR(4))

BEGIN
    IF operacion = 'INSERTAR' THEN
        INSERT INTO temporada (ID_Temporada, Estado, Año)
        VALUES (id_temporada, 'Sin Iniciar', año);

        SELECT 'Temporada insertada correctamente' AS Mensaje;

    ELSEIF operacion = 'ACTUALIZAR' THEN
        UPDATE temporada
        SET Estado = estado_nuevo
        WHERE ID_Temporada = id_temporada;

        SELECT CONCAT('Estado de la temporada ', id_temporada, ' actualizado a ', estado_nuevo) AS Mensaje;

    ELSEIF operacion = 'ELIMINAR' THEN
        DELETE FROM equipo 
        WHERE ID_Temporada = id_temporada;

        DELETE FROM temporada 
        WHERE ID_Temporada = id_temporada;

        SELECT 'Temporada eliminada correctamente' AS Mensaje;

    ELSE
        SELECT 'Operación no válida. Use INSERTAR, ACTUALIZAR o ELIMINAR' AS Mensaje;
    END IF;
END;

```

---

### Se crean 2 procedimientos correctos con la estructura de control CASE de comprobación. En ellos se realiza al menos una inserción, modificación o borrado y se informa al usuario, se incluye un par de llamadas correctas a cada procedimiento con indicación del resultado obtenido.

1:
Este procedimiento inserta un equipo si no existe previamente o si existe, lo modifica.

```sql
CREATE PROCEDURE InsertarOActualizarEquipo(nuevoID INT, nuevoNombre VARCHAR(100))
BEGIN
    DECLARE existe INT;

    -- Verificamos si el equipo existe
    SELECT COUNT(*) INTO existe 
    FROM equipo 
    WHERE id_equipo = nuevoID;

    -- Evaluamos la existencia del equipo
    IF existe > 0 THEN
        -- Si existe, lo actualiza
        UPDATE equipo
        SET nombre_equipo = nuevoNombre
        WHERE id_equipo = nuevoID;

        SELECT CONCAT('Equipo actualizado: ', nuevoNombre) AS Mensaje;
    ELSE
        -- Si no existe, lo inserta
        INSERT INTO equipo (id_equipo, nombre_equipo)
        VALUES (nuevoID, nuevoNombre);

        SELECT CONCAT('Equipo insertado: ', nuevoNombre) AS Mensaje;
    END IF;
END;

```

---

2:
Este procedimiento elimina jugadores y el equipo si ese equipo tiene jugadores, si no tiene jugadores elimina directamente el equipo solo ya que no tiene jugadores que eliminar.
```sql
CREATE PROCEDURE BorrarEquipoCase(EquipoID INT)
BEGIN
    DECLARE NUMJugadores INT DEFAULT 0;

    -- Verificar cuántos jugadores tiene el equipo
    SELECT COUNT(*) INTO NUMJugadores 
    FROM jugadores 
    WHERE id_equipo = EquipoID;

    -- Evaluar la cantidad de jugadores
    IF NUMJugadores > 0 THEN
        -- Si el equipo tiene jugadores, eliminamos primero los jugadores y luego el equipo
        DELETE FROM jugadores WHERE id_equipo = EquipoID;
        DELETE FROM equipos WHERE id_equipo = EquipoID;

        SELECT CONCAT('Se eliminaron ', NUMJugadores, ' jugadores y el equipo con ID ', EquipoID) AS Mensaje;
    ELSE
        -- Si el equipo no tiene jugadores, eliminamos solo el equipo
        DELETE FROM equipos WHERE id_equipo = EquipoID;

        SELECT CONCAT('Equipo con ID ', EquipoID, ' eliminado.') AS Mensaje;
    END IF;
END;

```

---

### En 12 procedimientos o funciones se utilizan excepciones. 1 con inserción, 1 con borrado, 1 con modificación y por lo menos en dos de ellas más de una excepción. Mostrar mensajes en cada caso.

1:
Este procedimiento busca el nombre del equipo, si no lo encuentra sale un mensaje de error. Si existe, mostrará el escudo de ese equipo.
```sql
CREATE PROCEDURE MostrarEscudoEquipo(nombreEscudo VARCHAR(50))
BEGIN
    DECLARE encontrado BOOL DEFAULT TRUE;
    DECLARE escudo VARCHAR(255);

    -- Manejador de error para capturar cuando no se encuentra un resultado
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET encontrado = FALSE;

    -- Buscar el escudo del equipo mediante el nombre
    SELECT Escudo INTO escudo 
    FROM equipo 
    WHERE Nombre_equipo = nombreEscudo;

    -- Si no se encuentra el equipo, mostrar mensaje de error
    IF encontrado = FALSE THEN
        SELECT CONCAT('No existe ningún equipo con el nombre ', nombreEscudo) AS ERROR;
    ELSE
        -- Si lo encuentra, mostrar el escudo
        SELECT escudo AS Escudo;
    END IF;
END;

```

---

2: