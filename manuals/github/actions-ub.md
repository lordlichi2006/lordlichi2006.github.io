# Apuntes de GitHub Actions

Guía rápida con ejemplos y notas para recordar los conceptos clave.

---

## 1) Información del repositorio

**Objetivo:** Aprender a usar variables de entorno predefinidas y entender la estructura básica de un workflow.

```yaml
# Define el nombre del flujo de trabajo que aparecerá en la pestaña "Actions" de GitHub.
name: Info del Repo

# Define el evento que dispara el flujo. En este caso, se activa con cualquier push al repositorio.
on: [push]

# Un workflow se compone de uno o más 'jobs' que pueden ejecutarse en paralelo o en serie.
jobs:
  mostrar_info:
    # Especifica el sistema operativo de la máquina virtual donde se ejecutará el código.
    runs-on: ubuntu-latest

    # Lista de tareas individuales que componen el trabajo.
    steps:
      - name: Imprimir información
        # El comando 'run' ejecuta instrucciones directamente en el terminal de la máquina.
        # Usamos la sintaxis ${{ }} para acceder al contexto global de GitHub.
        run: |
          echo "Repositorio: ${{ github.repository }}" # Nombre completo (usuario/repo)
          echo "Usuario: ${{ github.actor }}"           # Usuario que inició la acción
          echo "Rama: ${{ github.ref }}"                # Rama o etiqueta que disparó el evento
```

---

## 2) Comandos básicos y filtrado por rutas

**Objetivo:** Ejecutar tareas solo cuando cambian archivos específicos y usar acciones de la comunidad.

```yaml
name: Comandos básicos

on:
  push:
    # Filtro de rutas: el workflow solo se dispara si los archivos modificados están en 'scripts/'.
    paths:
      - "scripts/**"

jobs:
  comandos:
    # Sistema operativo del runner donde se ejecutará el job.
    runs-on: ubuntu-latest
    steps:
      # 'uses' llama a una acción predefinida. 'checkout' copia tu código a la máquina virtual.
      - uses: actions/checkout@v4

      - name: Listar archivos
        # Comando estándar de Linux para ver archivos, incluyendo ocultos y detalles.
        run: ls -la

      - name: Versión de Linux
        # Muestra información del kernel y del sistema operativo.
        run: uname -a

      - name: Fecha actual
        # Imprime la fecha y hora del sistema en el log de la ejecución.
        run: date
```

---

## 3) Verificación de archivos grandes

**Objetivo:** Implementar lógica de control de calidad en el repositorio mediante comandos de consola.



```yaml
name: Comprobar archivos grandes
# Se ejecuta en cada push para validar el tamaño de archivos.
on: [push]

jobs:
  check_large_files:
    # Nombre lógico del job; aparecerá en la interfaz de Actions.
    # Runner donde se ejecuta el job.
    runs-on: ubuntu-latest
    steps:
      # Descarga el repositorio en el runner para poder inspeccionar archivos.
      - uses: actions/checkout@v4

      - name: Buscar archivos mayores de 1 MB
        # Ejecuta un script de shell con varios comandos.
        run: |
          echo "Buscando archivos grandes..."
          # 'find .' busca en el directorio actual.
          # '-type f' busca solo archivos; '-size +1M' filtra los que superan 1 megabyte.
          # '|| echo' evita fallos si no se encuentran resultados.
          find . -type f -size +1M -print || echo "No se encontraron archivos grandes."
```

---

## 4) Automatización de formato (Prettier)

**Objetivo:** Configurar un entorno de desarrollo (Node.js) y asegurar la consistencia del código.



```yaml
name: Formato Prettier
# Se activa en cada push para verificar formato.
on: [push]

jobs:
  prettier:
    # Runner donde se ejecuta el job.
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Instalar Node.js
        # Acción oficial para preparar el entorno de Node.js.
        uses: actions/setup-node@v4
        with:
          # Especificamos la versión 20 para garantizar compatibilidad del proyecto.
          node-version: 20

      - name: Instalar Prettier
        # Instalamos de forma global la herramienta de formateo mediante npm.
        run: npm install -g prettier

      - name: Comprobar formato
        # '--check' verifica el formato sin sobreescribir archivos.
        run: prettier . --check
```

---

## Conceptos de repaso

- **Contextos (${{ }})**: Variables que GitHub Actions ofrece para obtener metadatos de la ejecución.
- **Runner (runs-on)**: Servidor donde se ejecutan los pasos; `ubuntu-latest` es el más común.