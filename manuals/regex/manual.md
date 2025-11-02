# Manual de Regex

## Sintaxis Básica

| Símbolo | Significado                                 | Ejemplo   |  Coincide con      |  No coincide con |
| ------- | ------------------------------------------- | --------- | ------------------- | ------------------ |
| `.`     | Cualquier carácter (excepto salto de línea) | `a.c`     | `abc`, `axc`        | `ac`, `abbc`       |
| `^`     | Inicio de línea                             | `^Hola`   | `Hola mundo`        | `Adiós Hola`       |
| `$`     | Fin de línea                                | `mundo$`  | `Hola mundo`        | `mundo feliz`      |
| `*`     | 0 o más repeticiones                        | `ab*c`    | `ac`, `abc`, `abbc` | `abdc`             |
| `+`     | 1 o más repeticiones                        | `ab+c`    | `abc`, `abbc`       | `ac`               |
| `?`     | 0 o 1 repetición (opcional)                 | `colou?r` | `color`, `colour`   | `colouur`          |
| `{n}`   | Exactamente `n` repeticiones                | `a{3}`    | `aaa`               | `aa`, `aaaa`       |
| `{n,}`  | Al menos `n` repeticiones                   | `a{2,}`   | `aa`, `aaa`         | `a`                |
| `{n,m}` | Entre `n` y `m` repeticiones                | `a{2,4}`  | `aa`, `aaa`, `aaaa` | `a`, `aaaaa`       |



## Clases de Caracteres

| Clase          | Significado                          | Ejemplo       |  Coincide con |  No coincide con |
| -------------- | ------------------------------------ | ------------- | -------------- | ------------------ |
| `[abc]`        | Cualquiera de `a`, `b` o `c`         | `[ch]ola`     | `cola`, `hola` | `rola`             |
| `[^abc]`       | Cualquiera excepto `a`, `b`, `c`     | `[^0-9]`      | `x`, `A`       | `3`                |
| `[a-z]`        | Letras minúsculas de la `a` a la `z` | `[a-z]+`      | `hola`         | `HOLA`, `123`      |
| `[A-Z]`        | Letras mayúsculas                    | `[A-Z][a-z]+` | `Hola`         | `hola`, `HOLA`     |
| `[0-9]`        | Dígitos del 0 al 9                   | `[0-9]{3}`    | `123`          | `abc`              |
| `[A-Za-z0-9_]` | Letras, números y guion bajo         | `\w+`         | `user_01`      | `user-01`          |



## Metacaracteres Comunes

| Secuencia | Significado          | Ejemplo    |  Coincide con |  No coincide con |
| --------- | -------------------- | ---------- | -------------- | ------------------ |
| `\d`      | Dígito               | `\d{2,4}`  | `2025`, `12`   | `AB`               |
| `\D`      | No dígito            | `\D+`      | `abc!`         | `123`              |
| `\w`      | Alfanumérico o `_`   | `\w+`      | `hola123`      | `hola-123`         |
| `\W`      | No alfanumérico      | `\W+`      | `!?@`          | `Hola`             |
| `\s`      | Espacio en blanco    | `\s+`      | `"   "`        | `abc`              |
| `\S`      | No espacio en blanco | `\S+`      | `texto`        | `"   "`            |
| `\b`      | Límite de palabra    | `\bword\b` | `word`         | `password`         |
| `\B`      | No límite de palabra | `\Bword\B` | `passwords`    | `word`             |



## Agrupación y Alternativas

| Símbolo          | Significado       | Ejemplo        |  Coincide con  |  No coincide con |
| ---------------- | ----------------- | -------------- | --------------- | ------------------ |
| `(abc)`          | Grupo de captura  | `(ab)+`        | `abab`          | `aabb`             |
| `(?:abc)`        | Grupo sin captura | `(?:ab)+`      | `abab`          | `aabb`             |
| `a\|b`           | Alternativa (OR)  | `perro\|gato`  | `perro`, `gato` | `conejo`           |
| `(?<nombre>abc)` | Grupo nombrado    | `(?<user>\w+)` | `usuario`       | `user-name`        |



## Modificadores (Flags)

| Bandera | Descripción                             | Ejemplo     |  Coincide con                  |  No coincide con         |
| ------- | --------------------------------------- | ----------- | ------------------------------- | -------------------------- |
| `i`     | Ignora mayúsculas/minúsculas            | `/abc/i`    | `ABC`, `abc`                    | `ab d`                     |
| `g`     | Búsqueda global                         | `/\d+/g`    | `123`, `45` (en el mismo texto) | texto sin números          |
| `m`     | Multilínea (`^` y `$` por línea)        | `/^hola/m`  | `hola` en varias líneas         | si no hay `hola` al inicio |
| `s`     | Permite que `.` incluya saltos de línea | `/a.*b/s`   | `a\nb`                          | `b...a`                    |
| `u`     | Soporte Unicode                         | `/\p{L}+/u` | `ñandú`, `éxito`                | `123!`                     |



## Lookahead y Lookbehind

| Expresión  | Descripción         | Ejemplo     |  Coincide con |  No coincide con |
| ---------- | ------------------- | ----------- | -------------- | ------------------ |
| `(?=...)`  | Lookahead positivo  | `\d(?=€)`   | `5€` → `5`     | `5$`               |
| `(?!...)`  | Lookahead negativo  | `\d(?!€)`   | `5$`           | `5€`               |
| `(?<=...)` | Lookbehind positivo | `(?<=€)\d+` | `€50` → `50`   | `$50`              |
| `(?<!...)` | Lookbehind negativo | `(?<!€)\d+` | `$50` → `50`   | `€50`              |



## Ejemplos Comunes

| Propósito              | Regex                                      |  Coincide con        |  No coincide con          |
| ---------------------- | ------------------------------------------ | --------------------- | --------------------------- |
| Email                  | `^[\w.-]+@[\w.-]+\.\w+$`                   | `test@mail.com`       | `test@mail`, `@mail.com`    |
| Teléfono (España)      | `^(\+34)?\s?\d{9}$`                        | `+34 612345678`       | `12345678`, `+346123456789` |
| Código postal (España) | `^[0-5][0-9]{4}$`                          | `28001`               | `68001`, `123`              |
| URL                    | `^https?:\/\/[\w.-]+(\.[\w.-]+)+[/#?]?.*$` | `https://example.com` | `example.com`, `ftp://site` |
| Solo letras            | `^[A-Za-zÁÉÍÓÚáéíóúñÑ]+$`                  | `Hola`                | `Hola123`, `Hola!`          |
| Número decimal         | `^\d+(\.\d+)?$`                            | `3.14`, `42`          | `.14`, `3,14`               |

---

## Ejemplos de uso en código

### JavaScript

```js
const texto = "Email: user@example.com";
const regex = /\w+@\w+\.\w+/;
console.log(regex.test(texto)); // true
```

### PHP

```php
<?php
$texto = "Usuario: Ekaitz, Año: 2025";

// Buscar todos los números en el texto
if (preg_match_all("/\d+/", $texto, $coincidencias)) {
    print_r($coincidencias[0]); // ['2025']
}

// Validar un correo electrónico
$email = "user@example.com";
if (preg_match("/^[\w.-]+@[\w.-]+\.\w+$/", $email)) {
    echo "Correo válido\n";
} else {
    echo "Correo inválido\n";
}
?>
```

---

##Referencias útiles

* [regex101.com](https://regex101.com) — Probador interactivo de expresiones regulares.
* [regexr.com](https://regexr.com) — Explicaciones visuales de patrones.
* [MDN: Regular Expressions](https://developer.mozilla.org/es/docs/Web/JavaScript/Guide/Regular_expressions)
