# Docker Compose

## 1) Estructura básica de docker-compose.yml

### Definición de servicios

1. **Usando una imagen existente** (bases de datos o servidores estándar):

```yaml
services:
  nginx:
    image: nginx:latest
  db:
    image: mysql:8
```

2. **Construyendo desde un Dockerfile** (cuando empaquetas tu app):

```yaml
services:
  app1:
    build: ./app # Busca el Dockerfile en ./app
```

### Mapeo de puertos (ports)

Formato: `"PUERTO_HOST:PUERTO_CONTENEDOR"`.

```yaml
ports:
  - "8080:80" # localhost:8080 -> contenedor:80
```

### Dependencias (depends_on)

Define el orden de arranque de los servicios:

```yaml
services:
  nginx:
    depends_on:
      - php
  php:
    depends_on:
      - db
```

---

## 2) Gestión de volúmenes

### A) Volúmenes físicos (bind mounts)

**Uso:** Inyectar código o configuración del host al contenedor.

```yaml
volumes:
  - ./src:/var/www/html
  - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
```

### B) Volúmenes lógicos (named volumes)

**Uso:** Persistencia de datos (si borras el contenedor, el volumen sobrevive).

Ejemplo MySQL:

```yaml
services:
  db:
    volumes:
      - dbdata:/var/lib/mysql

volumes:
  dbdata:
```

Ejemplo Mongo:

```yaml
services:
  db:
    volumes:
      - mongodata:/data/db

volumes:
  mongodata:
```

---

## 3) Variables de entorno (environment)

Configuran el comportamiento interno del contenedor al arrancar.

```yaml
environment:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_DATABASE: appdb
  APP_NAME: app1
```

---

## 4) Conectividad y redes (service discovery)

Dentro de la red de Docker, el **nombre del servicio** es el hostname. **No uses** `localhost` ni IPs.

**PHP conectando a MySQL:**

```php
$mysqli = new mysqli("db", "root", "root", "appdb");
// "db" es el nombre del servicio en el yml
```

**Nginx conectando a PHP (FastCGI):**

```nginx
fastcgi_pass php:9000;
```

**Red personalizada:**

```yaml
services:
  nginx:
    image: nginx
    networks:
      - mi-red

networks:
  mi-red:
    driver: bridge
```

**Nginx conectando a Node (balanceo):**

```nginx
server app1:3000;
// "app1" es el servicio
```

---

## 5) Configuraciones clave (archivos extra)

### Dockerfile (Node.js)

```dockerfile
FROM node:20
WORKDIR /app
COPY . .
CMD ["node", "server.js"]
```

### Nginx: proxy para PHP (default.conf)

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
```

### Nginx: balanceador de carga (default.conf)

```nginx
upstream backend {
    server app1:3000;
    server app2:3000;
    server app3:3000;
}
server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

---

## 6) Resumen rápido de sintaxis

| Concepto | Sintaxis YML | Ejemplo |
| --- | --- | --- |
| Servicio | `services:` | `nginx:`, `php:`, `db:` |
| Imagen | `image:` | `image: php:8.2-fpm` |
| Construir | `build:` | `build: ./app` |
| Puertos | `ports:` | `- "8080:80"` |
| Volumen host | `volumes:` | `- ./src:/var/www/html` |
| Volumen datos | `volumes:` | `- dbdata:/var/lib/mysql` |
| Variables | `environment:` | `MYSQL_ROOT_PASSWORD: root` |

---

## 7) Comandos útiles

### Levantar el entorno

- Modo normal: `docker-compose up`
- Segundo plano: `docker-compose up -d`
- Forzar rebuild: `docker-compose up --build`

### Parar y limpiar

- Detener contenedores: `docker-compose stop`
- Detener y borrar todo: `docker-compose down` (añade `-v` para borrar volúmenes lógicos)

### Monitorización

- Listar servicios activos: `docker-compose ps`
- Logs en tiempo real: `docker-compose logs -f`
- Logs de un servicio: `docker-compose logs nginx`

### Entrar en un contenedor

```bash
docker exec -it <nombre_contenedor> bash
```

Ejemplo:
```bash
docker exec -it proyecto-php-1 bash
```