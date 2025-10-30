# Manual docker


## Comandos Generales

#### Mostrar ayuda general de Docker

```bash
docker --help
```

#### Mostrar ayuda de un comando específico

```bash
docker [comando] --help
```

#### Mostrar información del sistema Docker

```bash
docker info
```

---

## Comandos de Imágenes

#### Buscar imagenes 
```bash
docker search [nombre]
```
#### 


#### Crear una imagen con un Dockerfile

```bash
docker build -t [nombre_imagen] .
```

#### Listar imágenes locales

```bash
docker images
```

#### Borrar una imagen

```bash
docker rmi [nombre_imagen]
```

#### Purgar imágenes no utilizadas

```bash
docker image prune
```

## Comandos de Containers

#### Crear y ejecutar un contenedor desde una imagen (con un nombre personalizado)

```bash
docker run --name [nombre_contenedor] [nombre_imagen]
```

#### Crear y ejecutar un contenedor y redirigir los puertos

```bash
docker run -p [puerto_host]:[puerto_contenedor] [nombre_imagen]
```
ejemplo : 
```bash
docker run -p 3306:5000 libretranslate
```
libretranslate internamente usara puerto 5000, pero en tu maquina se accedera desde [http://localhost:3306](http://localhost:3306)

#### Iniciar o detener un contenedor existente

```bash
docker start|stop [nombre_contenedor]  # o [id_contenedor]
```
*recuerda que puedes usar solo los 3 primeros characteres de la ID en vez de la ID entera

#### Eliminar un contenedor detenido

```bash
docker rm [nombre_contenedor]
```

#### Abrir una shell dentro de un contenedor en ejecución

```bash
docker exec -it [nombre_contenedor] sh
```
si bash esta instalado :

```bash
docker exec -it [nombre_contenedor] bash
```
*el ```-it``` es necesario para que sea **i**n**t**eractivo

#### Obtener y seguir los registros  de un contenedor

```bash
docker logs -f [nombre_contenedor]
```

#### Inspeccionar un contenedor en ejecución

```bash
docker inspect [nombre_contenedor]  # o [id_contenedor]
```

#### Listar los contenedores actualmente en ejecución

```bash
docker ps
```

#### Listar todos los contenedores (en ejecución y detenidos)

```bash
docker ps --all
```
o
```bash
docker ps -a
```

#### Ver estadísticas de uso de recursos

```bash
docker container stats
```