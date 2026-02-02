# Práctica de GitHub Actions

## ¿Qué son GitHub Actions?

GitHub Actions es una plataforma de CI/CD (Integración y Despliegue Continuos) que permite automatizar tareas cuando ocurren eventos en tu repositorio.

**Conceptos fundamentales:**
- **Workflow** - Archivo YAML que define el proceso automatizado
- **Event** - Disparador que inicia el workflow (push, pull_request, etc.)
- **Job** - Conjunto de pasos que se ejecutan en el mismo runner
- **Step** - Tarea individual (ejecutar comando, usar acción, etc.)
- **Runner** - Máquina virtual donde se ejecutan los jobs

### Componentes de un workflow

```yaml
name: Nombre del workflow
on: [evento]              # Cuándo se ejecuta
jobs:                     # Trabajos a realizar
  nombre_job:
    runs-on: ubuntu-latest  # Sistema operativo
    steps:                  # Lista de pasos
      - name: Descripción
        run: comando
```

---

## Ejercicio 1 - Mostrar información

**Objetivo:** Crear un workflow que muestre información del repositorio en cada push

```yaml
name: Info del Repo        # Nombre visible en la pestaña Actions
on: [push]                 # Se ejecuta cuando se hace push

jobs:
  mostrar_info:            # ID del job
    runs-on: ubuntu-latest # Runner Ubuntu (gratis para repos públicos)
    steps:
      - name: Imprimir información
        run: |             # Ejecuta comandos de shell
          echo "Repositorio: ${{ github.repository }}"  # usuario/repo
          echo "Usuario: ${{ github.actor }}"           # Quien hizo push
          echo "Rama: ${{ github.ref }}"                # refs/heads/main
```

### Variables de contexto importantes

- `${{ github.repository }}` - Nombre completo del repo (owner/name)
- `${{ github.actor }}` - Usuario que disparó el evento
- `${{ github.ref }}` - Referencia completa (branch o tag)
- `${{ github.sha }}` - Hash del commit
- `${{ github.event_name }}` - Tipo de evento (push, pull_request...)

---

## Ejercicio 2 - Buscar archivos grandes

**Objetivo:** Prevenir que se suban archivos pesados al repositorio

```yaml
name: Comprobar archivos grandes
on: [push]

jobs:
  check_large_files:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4     # Acción oficial: clona el repositorio
      - name: Buscar archivos mayores de 1 MB
        run: find . -type f -size +1M -print  # Comando find de Linux
```

### Componentes explicados

1. **`uses: actions/checkout@v4`** - Acción reutilizable
   - Clona el código del repositorio en el runner
   - Versión @v4 garantiza estabilidad
   - NOTA: Necesario para acceder a los archivos del repo

2. **`find . -type f -size +1M`**
   - `.` - Busca desde directorio actual
   - `-type f` - Solo archivos (no directorios)
   - `-size +1M` - Mayores de 1 megabyte
   - `-print` - Muestra la ruta del archivo

### Mejora sugerida

Hacer que falle si encuentra archivos grandes:

```yaml
- name: Buscar archivos mayores de 1 MB
  run: |
    FILES=$(find . -type f -size +1M)
    if [ -n "$FILES" ]; then
      echo "Archivos grandes encontrados:"
      echo "$FILES"
      exit 1  # Falla el workflow
    fi
```

---

## Ejercicio 3 - Prettier

**Objetivo:** Verificar que el código cumple con el formato estándar de Prettier

```yaml
name: Formato Prettier
on: [push]

jobs:
  prettier:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4          # Clona el repositorio
      - uses: actions/setup-node@v4        # Instala Node.js
        with:
          node-version: 20                 # Versión específica de Node
      - run: npm install -g prettier       # Instala Prettier globalmente
      - run: prettier . --check            # Verifica formato (NO modifica)
```

### Desglose del workflow

1. **`actions/setup-node@v4`** - Acción oficial de Node.js
   - Instala Node.js y npm en el runner
   - `with:` permite pasar parámetros a la acción
   - `node-version: 20` especifica la versión LTS

2. **`npm install -g prettier`**
   - `-g` instala globalmente (disponible en todo el sistema)
   - Necesario porque el runner está "limpio"

3. **`prettier . --check`**
   - `.` revisa todos los archivos del proyecto
   - `--check` solo verifica, NO formatea
   - Si encuentra diferencias, el workflow **falla**

### Diferencia importante

- `--check` → Solo verifica (para CI/CD)
- `--write` → Formatea y guarda cambios (para desarrollo local)

### Archivos que verifica Prettier

- JavaScript, TypeScript, JSON
- HTML, CSS, Markdown
- YAML, GraphQL, y más

### Buena práctica

Añadir archivo `.prettierrc` para configuración:

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2
}
```

---

## Resumen GitHub Actions

**Ubicación de workflows:** `.github/workflows/nombre.yml`

### Eventos comunes

- `on: [push]` - Cualquier push
- `on: [pull_request]` - Al crear/actualizar PR
- `on: push: branches: [main]` - Solo en rama main
- `on: schedule: - cron: '0 0 * * *'` - Diariamente a medianoche

### Acciones útiles

- `actions/checkout@v4` - Clonar repositorio
- `actions/setup-node@v4` - Instalar Node.js
- `actions/setup-python@v4` - Instalar Python
- `docker/build-push-action@v5` - Construir y subir imágenes Docker
