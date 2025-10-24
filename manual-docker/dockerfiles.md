# Manual de Comandos para Dockerfiles

#### FROM
Especifica la imagen base desde la cual se construye el contenedor.

#### RUN
Ejecuta comandos en una nueva capa de la imagen durante la construcción.

#### CMD
Define el comando predeterminado que se ejecuta al iniciar el contenedor.

#### EXPOSE
Indica los puertos en los que el contenedor escucha en tiempo de ejecución.

#### ENV
Establece variables de entorno dentro del contenedor.

#### COPY
Copia archivos o directorios desde el sistema de archivos local al contenedor.

#### ADD
Similar a COPY, pero también descomprime archivos tar y permite URLs como origen.

#### WORKDIR
Establece el directorio de trabajo para los comandos posteriores.

#### USER
Define el usuario que ejecutará los comandos en el contenedor.

#### VOLUME
Crea un punto de montaje para volúmenes persistentes.

#### ENTRYPOINT
Configura el ejecutable principal del contenedor, que no se sobrescribe con CMD.

#### LABEL
Añade metadatos a la imagen, como autor o versión.

#### ARG
Define variables que se pueden pasar en tiempo de construcción.

#### HEALTHCHECK
Especifica un comando para verificar la salud del contenedor.

#### ONBUILD
Define instrucciones que se ejecutan cuando la imagen se usa como base para otra.

## Ejemplo de Estructura Dockerfile

```dockerfile
# Imagen base desde la cual se construirá el contenedor
FROM <imagen_base>

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR <directorio_de_trabajo>

# Copiar archivos necesarios al contenedor
COPY <origen> <destino>

# Ejecutar comandos para instalar dependencias o preparar el entorno
RUN <comando_para_instalar_o_configurar>

# Copiar el resto de los archivos del proyecto (si aplica)
COPY <origen> <destino>

# Especificar variables de entorno (opcional)
ENV <nombre_variable>=<valor>

# Exponer el puerto que utilizará el contenedor (opcional)
EXPOSE <puerto>

# Definir el comando o proceso principal que se ejecutará al iniciar el contenedor
CMD [<comando_principal>]

# O definir una instrucción alternativa de ejecución (opcional)
ENTRYPOINT [<comando_entrypoint>]
```
