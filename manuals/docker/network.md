# Redes en docker

#### Crear red
```bash
docker network create [mi_red]
```
#### Listar todas las redes
```bash
docker network ls
```
#### Crear contenedor con red (se necesitan 2)
```bash
docker run --name [nombre] --network [mi_red] [imagen]
``` 
#### Abrir una shell dentro de un contenedor en ejecución

```bash
docker exec -it [nombre_contenedor] sh
```
si bash esta instalado :

```bash
docker exec -it [nombre_contenedor] bash
```

#### Instalar ping/actualizar container

```bash
apt update && apt install -y iputils-ping
```

#### Pingear otra maquina 
```bash
ping [nombre_otra_maquina]
```

si funciona, mostrara algo parecido a esto:
```bash

] ping maquina1

PING maquina1 (172.18.0.2) 56(84) bytes of data.
64 bytes from maquina1.test (172.18.0.2): icmp_seq=1 ttl=64 time=3.96 ms
64 bytes from maquina1.test (172.18.0.2): icmp_seq=2 ttl=64 time=0.079 ms
^C
--- maquina1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.079/2.018/3.957/1.939 ms
```
usa ```Ctrl+C``` para salir del ping y ```exit``` para salir del bash
