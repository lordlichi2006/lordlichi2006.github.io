# Volumenes

#### Crear Volumen

```bash
docker volume create [nombre_volumen]
```

#### Ver volumenes creados

```bash
docker volume ls
```

#### Poner volumen en contenedor

```bash
docker run --name [nombre_contenedor] -v [nombre_volumen]:[path_en_container] [nombre_imagen]
```

#### Ejemplo

```bash
docker run -it --name testVolumen2 -v volumen:/test debian bash
```