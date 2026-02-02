# Práctica de Docker Compose

## ¿Qué es Docker Compose?

Docker Compose es una herramienta que permite definir y ejecutar aplicaciones multi-contenedor. En lugar de ejecutar múltiples comandos `docker run`, se define toda la infraestructura en un archivo YAML.

**Ventajas principales:**
- Configuración declarativa y versionable
- Levanta todos los servicios con un solo comando: `docker-compose up`
- Gestiona automáticamente las redes entre contenedores
- Maneja volúmenes persistentes de forma sencilla

---

## Ejercicio 1 - Nginx + PHP + MySQL

**Objetivo:** Crear un entorno con:
- Nginx en puerto 8080
- PHP-FPM
- MySQL con base de datos appdb
- Volúmenes compartidos entre Nginx y PHP

### index.php

```php
<?php
$mysqli = new mysqli("db", "root", "root", "appdb");

if ($mysqli->connect_errno) {
    echo "Error: " . $mysqli->connect_error;
} else {
    echo "Conexión a MySQL correcta";
}
?>
```

### default.conf

```nginx
server {
    listen 80;
    root /var/www/html;

    index index.php index.html;

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass php:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

### docker-compose.yml

**Explicación de los componentes:**

```yaml
services:
  # Servicio 1: Servidor web Nginx
  nginx:
    image: nginx:latest              # Usa la imagen oficial de Nginx
    ports:
      - "8080:80"                    # Mapea puerto 8080 del host → 80 del contenedor
    volumes:
      - ./src:/var/www/html          # Comparte código PHP con el contenedor
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf  # Configuración personalizada
    depends_on:
      - php                          # Espera a que PHP esté listo antes de iniciar

  # Servicio 2: Intérprete PHP-FPM
  php:
    image: php:8.2-fpm               # PHP FastCGI Process Manager
    volumes:
      - ./src:/var/www/html          # MISMO volumen que Nginx (importante!)
    depends_on:
      - db                           # Espera a que MySQL esté listo

  # Servicio 3: Base de datos MySQL
  db:
    image: mysql:8                   # MySQL versión 8
    environment:                     # Variables de entorno para configurar MySQL
      MYSQL_ROOT_PASSWORD: root      # Contraseña del usuario root
      MYSQL_DATABASE: appdb          # Crea la base de datos al iniciar
    volumes:
      - dbdata:/var/lib/mysql        # Volumen nombrado para persistencia

# Volúmenes nombrados (persisten incluso si se eliminan los contenedores)
volumes:
  dbdata:                            # Almacena los datos de MySQL
```

### Conceptos clave de este compose

1. **`services:`** - Define cada contenedor que formará parte de la aplicación
   - Cada servicio es independiente pero pueden comunicarse entre sí

2. **`image:`** - Especifica qué imagen de Docker Hub usar
   - No requiere Dockerfile si usamos imágenes oficiales

3. **`ports:`** - Mapeo de puertos (formato: `"host:contenedor"`)
   - Permite acceder al servicio desde fuera del contenedor

4. **`volumes:`** - Dos tipos:
   - **Bind mounts** (`./src:/var/www/html`) - Carpeta local → contenedor
   - **Named volumes** (`dbdata:`) - Gestionados por Docker, persisten datos

5. **`depends_on:`** - Orden de inicio de contenedores
   - NOTA: Solo espera a que el contenedor inicie, NO a que el servicio esté listo

6. **`environment:`** - Variables de entorno para configurar el contenedor
   - Fundamental para bases de datos, credenciales, etc.

7. **Red automática** - Docker Compose crea una red privada donde:
   - Los servicios se comunican usando su nombre (ej: `php`, `db`)
   - En el código PHP: `mysqli("db", ...)` funciona automáticamente

### Estructura de carpetas necesaria

```
proyecto/
├── docker-compose.yml
├── src/
│   └── index.php
└── nginx/
    └── default.conf
```

---

## Ejercicio 2 - Balanceo con Node.js

**Objetivo:** Crear un sistema de balanceo de carga con Nginx distribuyendo peticiones entre 3 instancias de Node.js

### server.js

**Este script crea un servidor HTTP simple que responde con el nombre del contenedor:**

```javascript
const http = require('http');
const name = process.env.APP_NAME;  // Lee variable de entorno

http.createServer((req, res) => {
    res.end("Hola desde " + name);  // Responde con el nombre del servidor
}).listen(3000);
```

### Dockerfile

**Construye la imagen personalizada para la aplicación Node.js:**

```dockerfile
FROM node:20              # Imagen base con Node.js versión 20
WORKDIR /app              # Directorio de trabajo dentro del contenedor
COPY . .                  # Copia todos los archivos del proyecto
CMD ["node", "server.js"] # Comando que se ejecuta al iniciar el contenedor
```

### default.conf de Nginx

**Configuración de Nginx como balanceador de carga:**

```nginx
# Define el grupo de servidores backend
upstream backend {
    server app1:3000;     # Servidor Node.js #1
    server app2:3000;     # Servidor Node.js #2
    server app3:3000;     # Servidor Node.js #3
    # Por defecto usa round-robin (rotación circular)
}

server {
    listen 80;            # Nginx escucha en puerto 80
    location / {
        proxy_pass http://backend;  # Redirige peticiones al upstream
    }
}
```

### docker-compose.yml (Ejemplo completo)

```yaml
services:
  # Balanceador de carga Nginx
  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app1
      - app2
      - app3

  # Primera instancia de la aplicación
  app1:
    build: .                        # Construye desde el Dockerfile local
    environment:
      APP_NAME: "Servidor 1"        # Variable única para identificar

  # Segunda instancia (escalado horizontal)
  app2:
    build: .
    environment:
      APP_NAME: "Servidor 2"

  # Tercera instancia
  app3:
    build: .
    environment:
      APP_NAME: "Servidor 3"
```

### Componentes importantes de este ejercicio

1. **`build: .`** - En lugar de `image:`, construye desde Dockerfile
   - Permite personalizar la imagen con tu código

2. **`upstream`** en Nginx - Agrupa múltiples servidores backend
   - Distribuye carga automáticamente entre ellos
   - Algoritmo por defecto: round-robin (equitativo)

3. **Variables de entorno únicas** - Cada contenedor tiene su identidad
   - Permite diferenciar qué servidor respondió

4. **Escalado horizontal** - Múltiples instancias del mismo servicio
   - Aumenta disponibilidad y capacidad de procesamiento

### Comandos útiles

```bash
docker-compose up --build    # Construye y levanta los servicios
docker-compose scale app=5   # Escala dinámicamente a 5 instancias
curl localhost:8080          # Probar el balanceo (responderá diferente servidor)
```

---

## Resumen de comandos Docker Compose

```bash
# Iniciar servicios
docker-compose up              # Modo normal
docker-compose up -d           # Modo detached (segundo plano)
docker-compose up --build      # Reconstruir imágenes

# Gestión de servicios
docker-compose down            # Detener y eliminar contenedores
docker-compose down -v         # También elimina volúmenes
docker-compose ps              # Ver estado de servicios
docker-compose logs -f         # Ver logs en tiempo real

# Escalado
docker-compose scale app=5     # Crear 5 instancias de 'app'

# Ejecución de comandos
docker-compose exec nginx bash # Entrar al contenedor nginx
```
