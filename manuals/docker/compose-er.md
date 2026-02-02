# Guía Completa: Docker Compose

## Tabla de Contenidos
- [Ejemplo 1: Stack LEMP (Nginx + PHP-FPM + MySQL)](#ejemplo-1-stack-lemp-nginx--php-fpm--mysql)
- [Ejemplo 2: Balanceo de Carga (Nginx + Node.js + MongoDB)](#ejemplo-2-balanceo-de-carga-nginx--nodejs--mongodb)
- [Comandos Esenciales](#comandos-esenciales)
- [Buenas Prácticas](#buenas-prácticas)

---

## Ejemplo 1: Stack LEMP (Nginx + PHP-FPM + MySQL)

###  Arquitectura

```
┌─────────────────┐
│   Navegador     │
│   :8080         │
└────────┬────────┘
         │
    ┌────▼────┐
    │  Nginx  │  ← Sirve archivos estáticos
    │  :80    │  ← Envía .php a PHP-FPM
    └────┬────┘
         │
    ┌────▼────┐
    │   PHP   │  ← Ejecuta código PHP
    │  :9000  │  ← Conecta con MySQL
    └────┬────┘
         │
    ┌────▼────┐
    │  MySQL  │  ← Base de datos
    │  :3306  │
    └─────────┘
```

###  Flujo de Peticiones

1. Usuario accede → `http://localhost:8080/index.php`
2. Nginx recibe la petición en el puerto **80**
3. Nginx detecta que es un archivo `.php`
4. Nginx reenvía la petición a PHP-FPM (puerto **9000**)
5. PHP ejecuta el código y consulta MySQL si es necesario
6. PHP devuelve el resultado a Nginx
7. Nginx envía la respuesta final al navegador

---

###  Estructura del Proyecto

```
proyecto/
├── docker-compose.yml
├── nginx/
│   └── default.conf
└── www/
    └── index.php
```

---

###  Archivos

#### `docker-compose.yml`

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./www:/var/www/html
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php
    networks:
      - lemp

  php:
    image: php:8.2-fpm
    volumes:
      - ./www:/var/www/html
    networks:
      - lemp

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: testdb
      MYSQL_USER: usuario
      MYSQL_PASSWORD: password123
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - lemp

networks:
  lemp:

volumes:
  mysql_data:
```

####  Explicación del `docker-compose.yml`

| Clave | Descripción |
|-------|-------------|
| `version: '3.8'` | Versión del formato de Docker Compose |
| `services` | Define cada contenedor |
| `image` | Imagen base de Docker Hub |
| `ports` | `"host:contenedor"` - Expone puertos |
| `volumes` | Monta archivos/carpetas del host en el contenedor |
| `depends_on` | Orden de inicio (PHP antes que Nginx) |
| `networks` | Red interna para comunicación entre contenedores |
| `environment` | Variables de entorno |

---

#### `nginx/default.conf`

```nginx
server {
    listen 80;
    server_name localhost;
    
    root /var/www/html;
    index index.php index.html;
    
    # Logs
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Archivos estáticos
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # Procesar PHP
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        
        # Enviar a PHP-FPM
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        
        # Parámetros FastCGI
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
    
    # Denegar acceso a archivos ocultos
    location ~ /\.ht {
        deny all;
    }
}
```

####  Puntos Clave

- **`fastcgi_pass php:9000`** → Envía peticiones PHP al contenedor `php` (puerto 9000)
- **`php`** es el nombre del servicio en Docker Compose (DNS interno)
- **`root /var/www/html`** → Debe coincidir con el volumen montado

---

#### `www/index.php`

```php
<!DOCTYPE html>
<html>
<head>
    <title>Test LEMP Stack</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
        }
        .success { color: green; }
        .error { color: red; }
        code { 
            background: #f4f4f4; 
            padding: 2px 6px; 
            border-radius: 3px;
        }
    </style>
</head>
<body>
    <h1>🚀 LEMP Stack Funcionando</h1>
    
    <h2>Información de PHP</h2>
    <p>Versión: <code><?php echo phpversion(); ?></code></p>
    <p>Servidor: <code><?php echo $_SERVER['SERVER_SOFTWARE']; ?></code></p>
    
    <h2>Prueba de Conexión a MySQL</h2>
    <?php
    $host = 'mysql';
    $db = 'testdb';
    $user = 'usuario';
    $pass = 'password123';

    try {
        $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
        $pdo = new PDO($dsn, $user, $pass);
        echo '<p class="success">✅ Conectado a MySQL correctamente</p>';
        echo '<p>Base de datos: <code>' . $db . '</code></p>';
        
        // Crear tabla de prueba
        $pdo->exec("CREATE TABLE IF NOT EXISTS test (
            id INT AUTO_INCREMENT PRIMARY KEY,
            mensaje VARCHAR(255),
            fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )");
        
        // Insertar datos
        $stmt = $pdo->prepare("INSERT INTO test (mensaje) VALUES (?)");
        $stmt->execute(['Conexión exitosa desde PHP']);
        
        // Leer datos
        $result = $pdo->query("SELECT * FROM test ORDER BY id DESC LIMIT 5");
        echo '<h3>Últimos registros:</h3><ul>';
        foreach ($result as $row) {
            echo '<li>' . htmlspecialchars($row['mensaje']) . ' - ' . $row['fecha'] . '</li>';
        }
        echo '</ul>';
        
    } catch (PDOException $e) {
        echo '<p class="error">❌ Error de conexión: ' . $e->getMessage() . '</p>';
    }
    ?>
    
    <h2>Información del Sistema</h2>
    <p>Hostname: <code><?php echo gethostname(); ?></code></p>
    <p>Sistema Operativo: <code><?php echo PHP_OS; ?></code></p>
    
    <hr>
    <p><a href="?phpinfo=1">Ver phpinfo()</a></p>
    
    <?php
    if (isset($_GET['phpinfo'])) {
        phpinfo();
    }
    ?>
</body>
</html>
```

---

###  Comandos para Iniciar

```bash
# Construir e iniciar todos los servicios
docker compose up -d

# Ver logs en tiempo real
docker compose logs -f

# Acceder al navegador
# http://localhost:8080
```

---

## Ejemplo 2: Balanceo de Carga (Nginx + Node.js + MongoDB)

###  Arquitectura

```
                 ┌──────────────┐
                 │  Navegador   │
                 │   :8080      │
                 └──────┬───────┘
                        │
                  ┌─────▼──────┐
                  │   Nginx    │  ← Load Balancer
                  │   :80      │
                  └─────┬──────┘
                        │
         ┌──────────────┼──────────────┐
         │              │              │
    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
    │  app1   │    │  app2   │    │  app3   │
    │  :3000  │    │  :3000  │    │  :3000  │
    └────┬────┘    └────┬────┘    └────┬────┘
         │              │              │
         └──────────────┼──────────────┘
                        │
                  ┌─────▼──────┐
                  │  MongoDB   │
                  │   :27017   │
                  └────────────┘
```

###  Qué hace

- **Nginx** distribuye el tráfico entre 3 instancias de Node.js
- Usa **Round Robin** (petición 1 → app1, petición 2 → app2, etc.)
- Todas las apps comparten la misma base de datos MongoDB

---

###  Estructura del Proyecto

```
proyecto/
├── docker-compose.yml
├── nginx/
│   └── default.conf
└── app/
    ├── Dockerfile
    ├── server.js
    └── package.json
```

---

###  Archivos

#### `nginx/default.conf`

```nginx
upstream backend {
    # Round Robin por defecto
    server app1:3000;
    server app2:3000;
    server app3:3000;
}

server {
    listen 80;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "OK";
    }
}
```

####  Algoritmos de Balanceo Disponibles

```nginx
upstream backend {
    # Round Robin (por defecto)
    server app1:3000;
    server app2:3000;
    
    # Least connections
    # least_conn;
    
    # IP Hash (misma IP → mismo servidor)
    # ip_hash;
    
    # Weighted (más peso = más peticiones)
    # server app1:3000 weight=3;
    # server app2:3000 weight=1;
}
```

---

#### `app/server.js`

```javascript
const http = require('http');
const name = process.env.APP_NAME || 'app';
const port = 3000;

let requestCount = 0;

const server = http.createServer((req, res) => {
    requestCount++;
    
    const response = {
        server: name,
        timestamp: new Date().toISOString(),
        requestNumber: requestCount,
        pid: process.pid
    };
    
    console.log(`[${name}] Request #${requestCount}`);
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(response, null, 2));
});

server.listen(port, () => {
    console.log(` ${name} listening on port ${port}`);
});
```

---

#### `app/package.json`

```json
{
  "name": "load-balanced-app",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {}
}
```

---

#### `app/Dockerfile`

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

####  Explicación
- `node:20-alpine` → Imagen ligera de Node.js
- `WORKDIR /app` → Directorio de trabajo
- Copia primero `package.json` para aprovechar caché de capas
- `EXPOSE 3000` → Documenta el puerto (no lo publica)

---

#### `docker-compose.yml`

**Estructura básica del balanceador:**

```yaml
services:
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
```

**Cómo definir múltiples instancias de la aplicación:**

```yaml
  app1:
    build: ./app
    environment:
      APP_NAME: app1
      MONGO_URL: mongodb://mongo:27017/mydb
    depends_on:
      - mongo
  
  app2:
    build: ./app
    environment:
      APP_NAME: app2
      MONGO_URL: mongodb://mongo:27017/mydb
    # ... resto igual que app1
  
  # app3 sería similar...
```

**Servicio de MongoDB:**

```yaml
  mongo:
    image: mongo:latest
    volumes:
      - mongodata:/data/db
    ports:
      - "27017:27017"
```

**Declaración de volúmenes:**

```yaml
volumes:
  mongodata:
```

####  Puntos Clave

- Cada instancia de la app usa el **mismo Dockerfile** pero diferente `APP_NAME`
- El balanceador (`nginx`) lista todos los backends en su configuración
- MongoDB usa un volumen nombrado para persistencia
- Todos los servicios están en la misma red por defecto

---

###  Comprobación

```bash
# Construir e iniciar
docker compose up --build -d

# Ver logs de todos los servicios
docker compose logs -f

# Ver solo logs de las apps
docker compose logs -f app1 app2 app3

# Hacer varias peticiones
for i in {1..10}; do
  curl http://localhost:8080
  echo ""
done
```

Verás que las respuestas alternan entre `app1`, `app2` y `app3`.

---

## Comandos Esenciales de Docker Compose

###  Gestión Básica

```bash
# Iniciar servicios en segundo plano
docker compose up -d

# Iniciar y reconstruir imágenes
docker compose up --build

# Iniciar sin caché
docker compose build --no-cache
docker compose up

# Detener servicios (mantiene volúmenes)
docker compose down

# Detener y eliminar volúmenes
docker compose down -v

# Detener y eliminar imágenes también
docker compose down --rmi all
```

###  Monitoreo

```bash
# Ver servicios en ejecución
docker compose ps

# Ver logs de todos los servicios
docker compose logs

# Seguir logs en tiempo real
docker compose logs -f

# Logs de un servicio específico
docker compose logs -f nginx

# Últimas 100 líneas
docker compose logs --tail=100

# Logs con timestamps
docker compose logs -t
```

###  Operaciones

```bash
# Ejecutar comando en un servicio
docker compose exec nginx sh
docker compose exec db mysql -u root -p

# Ejecutar sin TTY (scripts)
docker compose exec -T nginx ls -la

# Reiniciar un servicio
docker compose restart nginx

# Reiniciar todos
docker compose restart

# Ver uso de recursos
docker compose top

# Validar sintaxis de docker-compose.yml
docker compose config

# Escalar servicios (solo para servicios sin container_name)
docker compose up -d --scale app=5
```

###  Limpieza

```bash
# Eliminar contenedores parados
docker compose rm

# Eliminar contenedores parados (sin confirmación)
docker compose rm -f

# Ver volúmenes
docker volume ls

# Eliminar volúmenes huérfanos
docker volume prune

# Limpieza completa del sistema Docker
docker system prune -a --volumes
```

---

## Buenas Prácticas

1. **Usa `.env` para configuración**:
   ```env
   # .env
   MYSQL_ROOT_PASSWORD=mi_password_seguro
   APP_PORT=8080
   ```
   
   ```yaml
   # docker-compose.yml
   environment:
     MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
   ports:
     - "${APP_PORT}:80"
   ```

2. **Healthchecks** para asegurar disponibilidad:
   ```yaml
   db:
     image: mysql:8
     healthcheck:
       test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
       interval: 10s
       timeout: 5s
       retries: 5
   ```

3. **Limita recursos**:
   ```yaml
   services:
     app:
       deploy:
         resources:
           limits:
             cpus: '0.5'
             memory: 512M
   ```

4. **Usa `.dockerignore`**:
   ```
   node_modules/
   .git/
   .env
   *.log
   ```

5. **Nombres descriptivos** para contenedores y volúmenes

6. **Redes explícitas** para mejor control

7. **Volúmenes nombrados** para datos persistentes