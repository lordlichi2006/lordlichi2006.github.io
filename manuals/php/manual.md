


##  Conceptos Básicos

`<?php ... ?>`

Delimita el código PHP que será ejecutado por el servidor.

---

Puedes tambien insertar esto dentro de HTML :

```php
<h1><?php echo $titulo; ?></h1>
<h1><?=$titulo?></h1>
```



### Salida de datos

`echo` / `print`
Muestran texto o variables en la página web.

```php
echo "Hola Mundo!";
```


`printf`
Muestra texto **formateado** según un patrón.
Permite insertar variables dentro de una cadena con **marcadores de formato** (`%d`, `%s`, etc.).

```php
$nombre = "User";
$edad = 19;
printf("Hola %s, tienes %d años.", $nombre, $edad);
```
Mostrara >`Hola User, tienes 19 años.`


 **Marcadores de formato comunes:**

| Marcador | Tipo de valor                | Ejemplo de salida |
| -------- | ---------------------------- | ----------------- |
| `%s`     | Cadena (string)              | `"Hola"`          |
| `%d`     | Entero (decimal)             | `42`              |
| `%f`     | Número con decimales (float) | `3.141593`        |
| `%.2f`   | Float con 2 decimales        | `3.14`            |
| `%b`     | Binario                      | `1010`            |
| `%o`     | Octal                        | `52`              |
| `%x`     | Hexadecimal (minúsculas)     | `2a`              |
| `%X`     | Hexadecimal (mayúsculas)     | `2A`              |
| `%%`     | Muestra un `%` literal       | `%`               |

---

`printr` se usa para mostrar arrays enteros

`var_dump` volcara todos los datos de qualquier variable



### Variables `$variable`

Todas las variables comienzan con `$`.
PHP asigna el tipo automáticamente (entero, cadena, booleano, etc.).

### Comentarios

```php
// Comentario de una línea

# Otra forma de comentar

/* 
Comentario
de varias líneas 
*/
```



## Estructuras de Control

### `if / else / elseif`

```php
if ($valor > numero) {
  echo "Mayor";
} elseif ($valor == numero) {
  echo "Igual";
} else {
  echo "Menor";
}
```


### `switch`

```php
switch ($color) {
  case "rojo": 
    echo "Alto"; 
    break;

  case "verde": 
    echo "Sigue"; 
    break;

  default: 
    echo "Espera";
}
```

### Bucles

```php
for ($i=0; $i<5; $i++) {
  echo $i;
}

while ($x < 10) { 
  echo $x;
  $x++; 
}

foreach ($array as $item) {
  echo $item
};
```
`foreach` se usa principalmente para recorrer arrays.


## Funciones

### Definición

```php
function nombreFuncion($parametro,$parametro2) {
  echo $parametro2;
  return $parametro;
}
```

Define un bloque reutilizable de código.
Puede recibir parámetros y devolver un valor con `return`.

### Funciones Integradas Comunes

* `isset($var)` → Comprueba si una variable está definida.
* `empty($var)` → Devuelve `true` si está vacía o no existe.
* `count($array)` → Cuenta los elementos de un array.
* `in_array($valor, $array)` → Verifica si un valor está en el array.
* `array_push($array, $valor)` → Agrega un valor al final del array.
* `array_pop($array)` → Elimina el último elemento del array.
* `array_keys($array)` → Devuelve todas las claves del array.
* `date("Y-m-d")` → Devuelve la fecha actual.
* `time()` → Devuelve el timestamp actual (segundos desde 1970).
* `strtotime($fecha)` → Convierte una fecha en timestamp.
* `round($num, 2)` → Redondea un número a 2 decimales.
* `ceil($num)` → Redondea un número hacia arriba.
* `floor($num)` → Redondea un número hacia abajo.
* `abs($num)` → Devuelve el valor absoluto.
* `rand($min, $max)` → Genera un número aleatorio entre min y max.
* `strlen($cadena)` → Devuelve la longitud de una cadena.
* `strtoupper($cadena)` → Convierte una cadena a mayúsculas.
* `strtolower($cadena)` → Convierte una cadena a minúsculas.
* `substr($cadena, $inicio, $longitud)` → Devuelve una subcadena.
* `str_replace($buscar, $reemplazar, $cadena)` → Reemplaza texto dentro de una cadena.
* `gettype($var)` → Devuelve el tipo de una variable.
* `unset($var)` → Elimina una variable.


## Arrays

### Array Indexado

```php
$array = ["valor", "value"];
echo $array[0];
```
Lista de valores con índices numéricos.

Mostrara > `valor`


### Array Asociativo

```php
$array = ["nombre"=>"Mikel Resa", "edad"=>4];
echo $array["nombre"];
```

Array con claves personalizadas.

Mostrara > `Mikel Resa`

### Array Multidimensional

```php
$peliculas = [
  ["titulo"=>"Inception", "año"=>2010],
  ["titulo"=>"Matrix", "año"=>1999]
echo $peliculas[1]["titulo"];
];
```

Arrays dentro de arrays (estructura tipo tabla).

Mostrara > `Matrix`

---

## Inclusión de Archivos

### `include 'archivo.php';` / `require 'archivo.php';`

Inserta otro archivo PHP.
`require` detiene la ejecución si el archivo no existe; `include` solo lanza una advertencia.

---

## Formularios y Superglobales

### `$_GET` / `$_POST`

```php
$nombre = $_POST['nombre'];
```
 Contienen los datos enviados desde un formulario por los métodos GET o POST.

### `$_FILES`

```php
move_uploaded_file($_FILES['archivo']['tmp_name'], 'uploads/' . $_FILES['archivo']['name']);
```
Maneja archivos subidos.
### HTML 

```html
<!-- Formulario POST (datos en $_POST) -->
<form action="procesar.php" method="post">
  <input type="text" name="nombre" placeholder="Nombre">
  <button type="submit">Enviar</button>
</form>

<!-- Formulario GET (datos en $_GET, visibles en URL) -->
<form action="buscar.php" method="get">
  <input type="text" name="q" placeholder="Buscar...">
  <button type="submit">Buscar</button>
</form>

<!-- Subida de archivos (requiere enctype, datos en $_FILES) -->
<form action="subir.php" method="post" enctype="multipart/form-data">
  <input type="file" name="archivo">
  <button type="submit">Subir</button>
</form>
```

**Notas clave:**
- `method="post"` → $_POST (oculto).  
- `method="get"` → $_GET (en URL).  
- `enctype="multipart/form-data"` → obligatorio para $_FILES.  
- `name="clave"` → clave en superglobal PHP.  

Usa `<?php var_dump($_POST); ?>` o `<?php var_dump($_GET); ?>` para ver lo recibido.

### `$_SERVER`

Contiene información del servidor y la petición:

* `$_SERVER['REQUEST_METHOD']` → método HTTP.
* `$_SERVER['PHP_SELF']` → nombre del script actual.

---

##  Base de Datos (PDO)

### Conexión

```php
$pdo = new PDO("mysql:host=localhost;dbname=peliculas", "usuario", "clave");
```
Crea una conexión segura a MySQL mediante PDO.

### Consulta

```php
$stmt = $pdo->query("SELECT * FROM peliculas");
$peliculas = $stmt->fetchAll(PDO::FETCH_ASSOC);
```
Ejecuta una consulta SQL y devuelve los resultados como arrays asociativos.

### Consulta Preparada

```php
$stmt = $pdo->prepare("INSERT INTO peliculas (titulo, año) VALUES (:titulo, :año)");
$stmt->bindParam(':titulo', $titulo, PDO::PARAM_STR);
$stmt->bindParam(':año', $año, PDO::PARAM_INT);
$stmt->execute();
```
Evita inyecciones SQL al separar datos y consulta.

---

##  Sesiones y Cookies

### Sesiones
```php
session_start();                    
$_SESSION['usuario'] = 'Usuario';   
```
Los datos en `$_SESSION` se guardaran en un `$array = ["tipo"=>"Asociativo"];`

Si el valor usuario no esta guardado, el usuario no estara iniciado sesion, por eso lo reridijimos (no permite acceso a pagina sin logearse)
```php
session_start();
if (!isset($_SESSION['usuario'])) {
    header("Location: login.php");  
    exit;
}
```

Para cerrar sesion :
```php
session_start();
session_unset();
session_destroy();                  
setcookie('PHPSESSID', '', time()-3600, '/'); //opcional
```

**Notas clave:**
- `session_start()` **debe ir antes de cualquier salida HTML**.
- Datos en `$_SESSION` persisten mientras el navegador tenga la cookie `PHPSESSID`.
- Usa `isset()` para verificar si una variable de sesión existe.
- `session_destroy()` no elimina `$_SESSION` inmediatamente; vacíalo con `session_unset()`.

### Cookies

```php
setcookie("tema", "oscuro", time() + 86400, "/", "", false, true);
```
Parámetros: `name, value, expire, path, domain, secure (HTTPS), httponly (no JS)`.

`time() + 86400` es el tiempo actual + 1 dia (en segundos!)

para leer la cookie usamos :
```php
if (isset($_COOKIE['tema'])) {
    echo $_COOKIE['tema'];  
}
```
Mostrara > `oscuro`

Para borrar la cookie, le ponemos el tiempo de expiracion en el pasado para que expire automaticamente.
```php
setcookie("tema", "", time() - 3600, "/");
```

**Notas clave:**
- `setcookie()` **antes de cualquier salida HTML**.
- `$_COOKIE['nombre']` → accede al valor.
- Para borrar: mismo `path`, valor vacío, `expire` en el pasado.
- **Nunca para datos sensibles** (usa sesiones para eso).

## Manejo de Archivos

Crear archivo si no existe, sobreescribe si existe.
```php
file_put_contents("datos.txt", "Hola mundo\n");  
```
Añade datos al final de el archivo si ya existe.
```php
file_put_contents("log.txt", date('Y-m-d H:i:s') . " - Acceso\n", FILE_APPEND);
```

para leer el archivo :
```php
$contenido = file_get_contents("datos.txt");  // Devuelve string
$lineas    = file("datos.txt");               // Array de líneas

foreach ($lineas as $linea) {
    echo rtrim($linea) . "<br>"; 
}
```
`rtrim()` quita el `\n` (salto de linea)


Usando fopen, ideal para archivos grandes

`r` leer, `w` escribir, `a` añadir

```php
$handle = fopen("archivo.txt", "r"); 
if ($handle) {
    while (($linea = fgets($handle)) !== false) {
        echo trim($linea) . "<br>";
    }
    fclose($handle);
}
```

Crear directorio si no existe
```php
if (!is_dir("uploads")) {
    mkdir("uploads", 0755, true);
}
```
recuerda como funcionan los permisos de linux!


**Notas clave:**
- `file("archivo.txt")` → devuelve **array de líneas** (con `\n`).
- `rtrim($linea)` → quita salto de línea al final (más preciso que `trim`).
- `file_get_contents()` → todo en un string.

## Manejo de Errores

### `try / catch`

```php
try {
  $pdo = new PDO(...);
} catch (PDOException $e) {
  echo "Error BD: " . $e->getMessage();
}
```
Captura errores sin detener el programa.


## Varios

* `header("Location: pagina.php");` → Redirige a otra página.
* `exit;` → Finaliza el script.
* `isset($_POST['nombreBtn'])` → Verifica si se envió un formulario.
* `require_once` → Evita incluir el mismo archivo más de una vez.
* `htmlspecialchars($entrada);` → Evita ataques XSS.


