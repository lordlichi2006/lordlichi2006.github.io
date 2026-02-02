# Guía Completa: GitHub Actions - Workflows

## Tabla de Contenidos
- [Estructura de Archivos](#estructura-de-archivos)
- [Anatomía de un Workflow](#anatomía-de-un-workflow)
- [Workflows de Ejemplo](#workflows-de-ejemplo)
- [Buenas Prácticas](#buenas-prácticas)

---

## Estructura de Archivos

Los workflows de GitHub Actions **SIEMPRE** se crean en esta ruta exacta:

```powershell
.github/
└── workflows/
    ├── info-repo.yml
    ├── comandos-basicos.yml
    ├── check-archivos-grandes.yml
    └── prettier.yml
```

###  Puntos Importantes

-  Son archivos `.yml` o `.yaml`
-  Se pueden crear en local o directamente en GitHub
-  GitHub los detecta automáticamente
-  **No se ejecutan** si no están en esa carpeta específica
-  El directorio `.github/workflows/` debe estar en la raíz del repositorio

### Flujo Típico

1. Creas los archivos en local
2. Haces commit y push a GitHub
3. GitHub los ejecuta automáticamente según el evento configurado

---

## Anatomía de un Workflow

Todos los workflows siguen este patrón básico:

```yaml
name: Nombre del workflow

on: evento

jobs:
  nombre_job:
    runs-on: ubuntu-latest
    steps:
      - name: Paso 1
        run: comando
```

### Componentes Explicados

| Componente | Descripción |
|------------|-------------|
| `name` | Nombre visible en GitHub → pestaña Actions |
| `on` | Define cuándo se ejecuta el workflow |
| `jobs` | Conjunto de tareas que se ejecutan (normalmente 1 job) |
| `runs-on` | Sistema operativo de la máquina virtual de GitHub |
| `steps` | Pasos que se ejecutan **en orden** |

### Tipos de Steps

```yaml
# Usando una acción predefinida
- uses: actions/checkout@v4

# Ejecutando comandos directamente
- name: Listar archivos
  run: ls -la

# Comando multilínea
- name: Varios comandos
  run: |
    echo "Comando 1"
    echo "Comando 2"
```

---

## Workflows de Ejemplo

### 1. Información del Repositorio

**Archivo:** `.github/workflows/info-repo.yml`

```yaml
name: Info del Repo

on: [push]

jobs:
  mostrar_info:
    runs-on: ubuntu-latest
    steps:
      - name: Imprimir información
        run: |
          echo "Repositorio: ${{ github.repository }}"
          echo "Usuario: ${{ github.actor }}"
          echo "Rama: ${{ github.ref }}"
          echo "SHA del commit: ${{ github.sha }}"
          echo "Evento: ${{ github.event_name }}"
```

####  Qué hace
- Se ejecuta en cada `push`
- Usa **variables predefinidas de GitHub** (`${{ github.* }}`)
- Imprime información útil del contexto en la consola

####  Variables de GitHub Disponibles
- `github.repository` - Nombre del repo (ej: `usuario/mi-repo`)
- `github.actor` - Usuario que disparó el workflow
- `github.ref` - Referencia completa (ej: `refs/heads/main`)
- `github.sha` - SHA del commit
- `github.event_name` - Tipo de evento (`push`, `pull_request`, etc.)

---

### 2. Comandos Básicos de Linux

**Archivo:** `.github/workflows/comandos-basicos.yml`

```yaml
name: Comandos básicos

on:
  push:
    paths:
      - "scripts/**"

jobs:
  comandos:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Listar archivos
        run: ls -la
      
      - name: Versión de Linux
        run: uname -a
      
      - name: Fecha actual
        run: date
      
      - name: Espacio en disco
        run: df -h
```

####  Claves

- **`actions/checkout@v4`** → Clona el repositorio en la máquina virtual
- **`paths`** → Solo se ejecuta si cambia algo en `scripts/`
- **Sin checkout, no hay código** disponible en la VM

####  Eventos Comunes

```yaml
# En cada push
on: [push]

# En push y pull request
on: [push, pull_request]

# Solo en rama específica
on:
  push:
    branches:
      - main
      - develop

# Solo para ciertos archivos
on:
  push:
    paths:
      - "src/**"
      - "*.js"

# Excluir archivos
on:
  push:
    paths-ignore:
      - "docs/**"
      - "*.md"

# Programado (cron)
on:
  schedule:
    - cron: '0 0 * * *'  # Diario a medianoche
```

---

### 3. Buscar Archivos Grandes

**Archivo:** `.github/workflows/check-archivos-grandes.yml`

```yaml
name: Comprobar archivos grandes

on: [push]

jobs:
  check_large_files:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Buscar archivos mayores de 1 MB
        run: |
          echo " Buscando archivos grandes..."
          find . -type f -size +1M -print || echo " No se encontraron archivos grandes."
      
      - name: Buscar archivos mayores de 10 MB
        run: |
          echo " Buscando archivos muy grandes (>10MB)..."
          find . -type f -size +10M -exec ls -lh {} \; || echo " OK"
```

####  Explicación del comando `find`

```bash
find .           # Desde el directorio actual
  -type f        # Solo archivos (no directorios)
  -size +1M      # Mayores de 1 MB
  -print         # Mostrarlos en pantalla
```

####  Variaciones Útiles

```bash
# Buscar por extensión
find . -name "*.log" -size +100k

# Contar archivos grandes
find . -type f -size +1M | wc -l

# Eliminar archivos grandes (¡cuidado!)
find . -type f -size +100M -delete
```

---

### 4. Formatear Código con Prettier

**Archivo:** `.github/workflows/prettier.yml`

```yaml
name: Formato Prettier

on: [push]

jobs:
  prettier:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Instalar Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Instalar Prettier
        run: npm install -g prettier
      
      - name: Comprobar formato
        run: prettier . --check
      
      - name: Mostrar archivos con errores
        if: failure()
        run: prettier . --list-different
```

####  Claves

- **`setup-node`** instala Node.js
- **`npm install -g`** instala globalmente
- **`--check`** NO modifica archivos, solo verifica
- **`--list-different`** muestra qué archivos necesitan formato

####  Configuración de Prettier

Crea un archivo `.prettierrc` en la raíz:

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 80
}
```

Y un `.prettierignore`:

```
node_modules/
dist/
build/
*.min.js
*.md
```

---

### 5. Tests Automatizados (EXTRA)

**Archivo:** `.github/workflows/tests.yml`

```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18, 20]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Usar Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      
      - name: Instalar dependencias
        run: npm ci
      
      - name: Ejecutar tests
        run: npm test
      
      - name: Generar coverage
        run: npm run coverage
      
      - name: Subir coverage a Codecov
        uses: codecov/codecov-action@v3
```

---

## Resumen de GitHub Actions

| Concepto | Descripción |
|----------|-------------|
| **Ubicación** | `.github/workflows/*.yml` |
| **Ejecución** | En runners de GitHub (VMs Ubuntu) |
| **`checkout`** | Clona el repositorio |
| **`run`** | Ejecuta comandos de shell |
| **`uses`** | Usa acciones predefinidas |
| **`on`** | Define cuándo se ejecuta |
| **`jobs`** | Tareas independientes (pueden ejecutarse en paralelo) |

---

## Buenas Prácticas

1. **Usa `actions/checkout@v4`** siempre como primer paso

2. **Cachea dependencias** para acelerar workflows:
   ```yaml
   - uses: actions/cache@v3
     with:
       path: ~/.npm
       key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
   ```

3. **Usa secrets** para datos sensibles (Settings → Secrets):
   ```yaml
   env:
     API_KEY: ${{ secrets.API_KEY }}
   ```

4. **Limita ejecuciones** innecesarias con `paths`, `branches`

5. **Usa matrices** para probar múltiples versiones

6. **Configura timeouts**:
   ```yaml
   jobs:
     test:
       timeout-minutes: 10
   ```
