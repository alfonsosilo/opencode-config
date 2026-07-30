# Uso de Herramientas

Reglas que gobiernan que herramientas usar, como combinarlas y como NO usarlas.

---

## Principio de paralelizacion

**Todo lo independiente se ejecuta en paralelo.** No serialices lo que puede correr simultaneamente.

```typescript
// CORRECTO: 3 lecturas independientes en paralelo
read(filePath="src/auth.ts")
read(filePath="src/db.ts")
read(filePath="src/config.ts")

// INCORRECTO: Lecturas secuenciales
read(filePath="src/auth.ts")
// ... esperar ...
read(filePath="src/db.ts")
```

Aplica a: lecturas de archivos, busquedas, agentes explore/librarian, comandos bash independientes.

## Herramientas de busqueda: usar las dedicadas

| Herramienta del sistema | Reemplaza a | Proposito |
|------------------------|-------------|-----------|
| `glob` | `find`, `ls -R` | Buscar archivos por patron de nombre |
| `grep` | `grep`, `rg` | Buscar contenido en archivos |
| `read` | `cat`, `head`, `tail` | Leer archivos completos o parciales |
| `edit` | `sed`, `awk` | Editar archivos con reemplazo exacto |
| `write` | `echo >`, `cat <<EOF` | Escribir archivos nuevos |

**Regla**: SIEMPRE usa las herramientas dedicadas. NUNCA uses bash para `find`, `grep`, `cat`, `head`, `tail`, `sed`, `awk`, o `echo` cuando la herramienta dedicada existe.

Excepcion: `git` y operaciones de shell legitima (pipes complejos, comandos que no tienen herramienta dedicada).

## Agentes explore y librarian

### explore agent

Es tu **grep contextual**. Usalo para:

- Buscar definiciones de funciones/clases en el codebase
- Encontrar quien llama a una funcion (callers)
- Trazar patrones de uso de una API interna
- Explorar estructuras de directorios desconocidas

**Disparalo liberalmente.** Si necesitas saber algo del codebase que no esta en tu contexto, dispara un explore agent. Es barato. Es rapido. Es tu herramienta de descubrimiento primaria.

### librarian agent

Es tu **grep de referencia externa**. Usalo para:

- Buscar documentacion de librerias de terceros
- Encontrar ejemplos de uso en GitHub (`grep_app_searchGitHub`)
- Resolver dudas de APIs externas
- Buscar patrones de configuracion de herramientas

**No uses librarian para explorar tu propio codebase.** Para eso esta explore.

## Bash tool: reglas de seguridad

### Paths con espacios

Siempre encierra entre comillas los paths con espacios:

```bash
# CORRECTO
mkdir "/Users/juan/My Documents/project"

# INCORRECTO
mkdir /Users/juan/My Documents/project
```

### Workdir vs cd

Usa el parametro `workdir`, NUNCA `cd`:

```bash
# CORRECTO
bash(command="pytest tests", workdir="/path/to/project")

# INCORRECTO
bash(command="cd /path/to/project && pytest tests")
```

### Encadenamiento

Usa `&&` para dependencias secuenciales, `;` solo si no te importa que fallen comandos intermedios. NUNCA uses newlines para separar comandos en bash.

```bash
# CORRECTO: secuencia dependiente
bash(command="git add . && git commit -m 'fix'")

# CORRECTO: comandos independientes (el segundo corre aunque el primero falle)
bash(command="echo 'done'; echo 'cleanup'")

# INCORRECTO: newlines
bash(command="git add .
git commit -m 'fix'")
```

## Reglas de lectura de archivos

- **Paraleliza**: lee multiples archivos en una sola llamada (multiples `read`)
- **Evita slices diminutos**: si necesitas leer mas de 30 lineas contiguas, lee una ventana mas grande (100-200 lineas)
- **Usa offset**: para leer secciones posteriores de archivos largos
- **Nunca uses `cat`**: el tool `read` lo reemplaza

## Edicion de archivos

### Usa `edit`, no `sed`/`awk`

`edit` hace reemplazo exacto de strings. Es seguro y predecible. `sed`/`awk` son propensos a errores de escaping.

### Reglas de edicion

- Siempre lee el archivo antes de editarlo (el tool `edit` lo exige)
- Respeta la indentacion exacta del archivo
- Si `oldString` aparece multiples veces, agrega mas contexto para hacerlo unico
- Usa `replaceAll` para renombrar simbolos en un solo archivo

## Cambios de codigo: patrones

- **Empata el estilo existente**: tabs vs spaces, comillas simples vs dobles, punto y coma si/no
- **No introduzcas patrones nuevos** en archivos existentes sin justificacion
- **Un cambio = un proposito**: no mezcles refactor con feature, fix con limpieza

---

## Referencias cruzadas

- Para la regla anti-duplicacion con explore/librarian: [guia-delegacion.md](guia-delegacion.md)
- Para verificacion post-edicion con LSP: [phase-gates.md](phase-gates.md)
- Para cuando consultar al Oracle en vez de debuggear a ciegas: [uso-oracle.md](uso-oracle.md)
