# PoliMusic · WebApp (ASP Clásico + SQL Server)

Aplicación web tipo *streaming* de música inspirada en Spotify, con identidad visual naranja.
Permite autenticarse, explorar el catálogo, reproducir canciones desde el navegador y —si el
usuario es administrador— crear, editar y eliminar canciones.

---

## Características

- **Autenticación** contra `TBL_USER` con sesión de servidor y control de acceso por rol.
- **Catálogo de canciones** con artista(s), álbum, contador de reproducciones y buscador instantáneo.
- **Biblioteca de playlists** con las portadas guardadas en la base de datos, tipo (pública o
  privada), número de canciones y detalle con las canciones de cada playlist.
- **Reproductor HTML5 persistente**: play/pausa, anterior/siguiente, barra de progreso, volumen y
  contador de reproducciones que se actualiza por AJAX sin recargar la página.
- **CRUD de canciones** para el rol administrador, con modales, validación en cliente y servidor,
  confirmación de borrado y transacciones.
- **Diseño responsive**: tabla en escritorio, tarjetas en móvil, menú lateral deslizante.
- **Accesibilidad**: navegación por teclado, `aria-label`, foco visible, `prefers-reduced-motion`.
- **Manejo de errores**: si un archivo de audio no existe, la canción se marca como *“Sin audio”*
  y su botón de reproducción se deshabilita en lugar de fallar.

---

## Stack

| Capa | Tecnología |
|------|-----------|
| Servidor | IIS 10 (Windows) · ASP Clásico / VBScript |
| Acceso a datos | ADO (`ADODB.Command` con parámetros) |
| Base de datos | SQL Server · `BDD_PoliMusic` |
| Cliente | HTML5, CSS3 (custom properties), JavaScript vanilla (Web Animations API) |

---

## Estructura del proyecto

```
webapppolimusicv1_asp/
├── Default.asp                     Documento predeterminado (redirige a login o al catálogo)
├── login.asp                       Autenticación y creación de la sesión (solo lógica)
├── canciones.asp                   Catálogo: consultas, CRUD y armado del documento
├── playlists.asp                   Biblioteca de playlists: rejilla y detalle
├── PUBLICAR-IIS.bat                Publica el proyecto en C:\inetpub\wwwroot (requiere UAC)
├── BDD_PoliMusic.sql               Script de creación y poblado de la base de datos
├── README.md
│
├── assets/                         Todos los recursos de cliente en una sola carpeta
│   ├── css/
│   │   ├── estilos.css             Sistema de diseño: variables, layout, reproductor, modales
│   │   ├── canciones.css           Componentes del catálogo: hero, métricas, tabla
│   │   ├── playlists.css           Rejilla de portadas y cabecera de playlist
│   │   ├── responsive.css          Media queries (se carga al final)
│   │   └── login.css               Estilos exclusivos de la pantalla de acceso
│   ├── js/
│   │   ├── canciones.js            Buscador, reproductor, modales, CRUD y animaciones
│   │   ├── playlists.js            Reproductor y navegación de la biblioteca
│   │   └── login.js                Mostrar contraseña y chips de acceso rápido
│   └── includes/                   Fragmentos HTML con etiquetas ASP
│       ├── nucleo.asp              Núcleo compartido: config, helpers, iconos, ADO, sesión
│       ├── head.asp                <head>: metadatos, fuentes y hojas de estilo
│       ├── sidebar.asp             Navegación lateral + telón móvil
│       ├── topbar.asp              Cabecera: ruta, ayuda, usuario y cerrar sesión
│       ├── player.asp              Reproductor fijo + elemento <audio>
│       ├── modal-form.asp          Modal de creación / edición
│       ├── modal-delete.asp        Modal de confirmación de borrado
│       ├── modal-help.asp          Modal de ayuda y atajos
│       └── toasts.asp              Contenedor de notificaciones
│
└── SongFilesAndImages_resources/   Datos del proyecto (audio e imágenes)
    ├── SongFiles/                  Archivos .mp3
    ├── UserImages/                 Fotos de usuario
    └── PlaylistImages/             Portadas de playlists
```

Solo hay **dos carpetas** dentro del sitio publicado: `assets` y `SongFilesAndImages_resources`.

---

## Requisitos

1. **Windows** con IIS y la característica **ASP** habilitada
   (*Panel de control → Programas → Activar o desactivar características de Windows →
   Servicios de Internet Information Server → Servicios World Wide Web → Desarrollo de aplicaciones → ASP*).
2. **SQL Server** (Express sirve) en ejecución.
3. Navegador moderno (Chrome, Edge o Firefox).

---

## Instalación

### 1. Base de datos

Ejecuta `BDD_PoliMusic.sql` en SQL Server Management Studio. El script crea la base,
el login `usr_polimusic` y las tablas con sus datos de ejemplo.

### 2. Publicar en IIS

Ejecuta **`PUBLICAR-IIS.bat`** con doble clic y acepta el aviso de permisos de Windows.
El script:

- copia `Default.asp`, `login.asp` y `canciones.asp` a `C:\inetpub\wwwroot\webapppolimusicv1_asp\`;
- copia la carpeta `assets\` completa (CSS, JS e includes);
- elimina las carpetas sueltas `css\`, `js\` e `includes\` que hayan quedado de versiones anteriores;
- sincroniza `SongFilesAndImages_resources`;
- concede lectura a `IIS_IUSRS`;
- registra `Default.asp` como documento predeterminado.

Vuelve a ejecutarlo cada vez que modifiques los archivos `.asp`, el CSS, el JavaScript o agregues canciones.

### 3. Abrir

```
http://localhost/webapppolimusicv1_asp/
```

---

## Usuarios de prueba

| Usuario | Contraseña | Rol | Permisos |
|---------|-----------|-----|----------|
| `userAdmin` | `12345678` | Administrador | Ver, reproducir, crear, editar y eliminar |
| `userNormal` | `12345678` | Usuario | Ver y reproducir |
| `username1` | `12345678` | Usuario | Ver y reproducir (contraseña guardada como SHA1) |

El login acepta contraseñas en texto plano y contraseñas almacenadas como SHA1
(`HASHBYTES('SHA1', ...)`), por lo que ambos formatos del script funcionan.

---

## Roles y permisos

La sesión guarda:

| Variable | Contenido |
|----------|-----------|
| `Session("idUsuario")` | `ID_USER` |
| `Session("nombreUsuario")` | `USERNAME` (se muestra en la cabecera) |
| `Session("rolUsuario")` | `userAdmin` (administrador) o `epn.fis` (usuario normal) |
| `Session("tipoUsuario")` | `USER_TYPE` (1 = administrador, 0 = usuario) |
| `Session("fotoUsuario")` | `USER_PHOTO` |

La visibilidad de los botones de administración se decide **en el servidor** con `EsAdmin()`,
no con JavaScript, de modo que un usuario normal nunca recibe el HTML de esas acciones.

---

## Cómo agregar canciones

1. Copia el archivo `.mp3` en `SongFilesAndImages_resources/SongFiles/`.
2. Ejecuta `PUBLICAR-IIS.bat` para sincronizar la carpeta con IIS.
3. Entra como `userAdmin` → **Nueva canción** y escribe la ruta con el formato:

```
~/songFiles/nombre-del-archivo.mp3
```

El formulario sugiere automáticamente los archivos `.mp3` que encuentra en la carpeta.

> **Nota:** el proyecto incluye un solo audio (`bensound-adventure.mp3`). Las otras cuatro
> canciones del catálogo existen en la base de datos pero no tienen archivo, por eso aparecen
> con la etiqueta **“Sin audio”**. Al agregar los `.mp3` correspondientes, se habilitan solas.

Las portadas de álbum apuntan a `~/albumImages/*.png`, que no forman parte de los recursos.
Cuando la imagen no existe, la aplicación genera una portada con degradado y la inicial del
título, de modo que la interfaz nunca queda con imágenes rotas.

---

## Arquitectura del código

Los `.asp` contienen **solo lógica de servidor**: conexión, consultas parametrizadas, reglas de
negocio y armado de la vista. Todo lo que puede vivir en un archivo estático vive fuera:

| Responsabilidad | Dónde | Por qué |
|-----------------|-------|---------|
| Conexión, consultas, CRUD, sesión, CSRF | `*.asp` | Necesita ejecutarse en el servidor |
| Config, helpers, iconos, ADO, roles | `assets/includes/nucleo.asp` | Una sola copia para todas las páginas |
| Estilos | `assets/css/` | El navegador los cachea y se editan con recarga en caliente |
| Interacción | `assets/js/` | Sin ASP dentro: JavaScript puro, reutilizable y depurable |
| Markup repetido | `assets/includes/` | Un solo lugar para la cabecera, el reproductor y los modales |

`nucleo.asp` se incluye al principio de cada página y aporta las constantes de configuración,
`H()`, `AssetUrl()`, `AssetExists()`, `Icon()`, `GetConnection()`, `NewCmd()`, `EsAdmin()` y las
variables de sesión (`sNombre`, `boolAdmin`, `archivoActual`...). Así `canciones.asp` y
`playlists.asp` no duplican ni una línea de acceso a datos.

**Cómo funcionan los includes.** `<!--#include file="assets/includes/sidebar.asp"-->` es una
directiva de IIS: el archivo se inserta **antes** de compilar la página, así que comparte el mismo
ámbito que `canciones.asp` y puede usar sus variables (`sNombre`, `boolAdmin`, `Icon()`,
`gFormError`...). No hay llamadas, ni `Response.Write`, ni sobrecosto en tiempo de ejecución.

> Los parciales llevan extensión `.asp` (no `.html`) porque contienen etiquetas `<%= %>` que IIS
> debe ejecutar. Si se abren directamente en el navegador no muestran datos: ASP los evalúa fuera
> de contexto y devuelve un error, no información del usuario.

**Orden de las hojas de estilo.** Se cargan en este orden y el orden importa:

```
assets/css/estilos.css      →  variables, layout, componentes compartidos
assets/css/canciones.css    →  componentes del catálogo
assets/css/responsive.css   →  media queries (al final, para poder sobrescribir sin !important)
```

**Caché.** Las tres hojas y los dos scripts se enlazan con `?v=<%= ASSET_VERSION %>`. Al desplegar
cambios basta subir la constante `ASSET_VERSION` para invalidar la caché del navegador sin pedirle
al usuario que borre datos de navegación.

**Antes / después del desacople:**

| Archivo | Antes | Después |
|---------|------:|--------:|
| `canciones.asp` | 2 663 líneas | 646 líneas |
| `login.asp` | 455 líneas | 264 líneas |
| `playlists.asp` | — | 547 líneas |

---

## Playlists

`playlists.asp` es la biblioteca de playlists. Tiene dos vistas en el mismo archivo:

| Ruta | Vista |
|------|-------|
| `playlists.asp` | Rejilla con todas las playlists y su portada |
| `playlists.asp?id=N` | Detalle de la playlist N con sus canciones |

**Listado.** Cada tarjeta muestra la portada real guardada en `TBL_PLAYLIST.PHOTO`, el tipo
(pública / privada), el número de canciones, el propietario y la fecha de creación. Arriba, tres
métricas: total de playlists, cuántas son públicas y cuántas canciones hay guardadas en total.

**Detalle.** Portada grande, tipo, propietario, fecha y la tabla de canciones de la playlist con
álbum, artistas, reproducciones y botón de reproducción (el reproductor es el mismo del catálogo).

**De dónde salen las portadas.** `PHOTO` guarda una ruta lógica (`~/playlistImages/...`), no una
URL. La página la pasa por `AssetUrl()`, que la traduce a
`SongFilesAndImages_resources/PlaylistImages/...`. Si el archivo no existiera, la tarjeta genera
una portada con degradado y la inicial del título, igual que hace el catálogo con los álbumes.

| Playlist | Valor en `TBL_PLAYLIST.PHOTO` | Archivo real |
|----------|-------------------------------|--------------|
| Playlist 1 | `~/playlistImages/default.jpg` | `PlaylistImages/default.jpg` |
| Playlist 2 | `~/playlistImages/playlist1.png` | `PlaylistImages/playlist1.png` |
| Playlist 3 | `~/playlistImages/Playlist2.png` | `PlaylistImages/playlist2.png` |
| Playlist 4 | `~/playlistImages/Playlist3.png` | `PlaylistImages/playlist3.png` |
| Playlist 5 | `~/playlistImages/Playlist4.png` | `PlaylistImages/playlist4.png` |

> **Detalle técnico:** el script inserta `Playlist2.png`, `Playlist3.png` y `Playlist4.png` con
> *P* mayúscula, mientras los archivos están en minúscula. En IIS/Windows funciona porque el
> sistema de archivos no distingue mayúsculas (verificado: responde `200`), pero fallaría al
> desplegar en Linux, Docker o cualquier servidor sensible a mayúsculas. Lo recomendable es
> normalizar los `INSERT` a minúsculas.

Las playlists se leen de la base de datos; la página no crea ni edita playlists (eso queda fuera
del alcance de esta entrega).

---

## Solución de problemas

| Síntoma | Causa / solución |
|---------|------------------|
| **HTTP 403.14** al abrir la carpeta | No hay documento predeterminado. Verifica que `Default.asp` esté publicado y vuelve a ejecutar `PUBLICAR-IIS.bat`. |
| **HTTP 404** al iniciar sesión | Falta `login.asp` en la carpeta publicada. |
| **HTTP 500.100 / error de ASP** | La característica *ASP* de IIS no está instalada, o la cadena de conexión no es válida. |
| La página se ve **sin estilos ni colores** | Falta la carpeta `assets\` en la carpeta publicada. Vuelve a ejecutar `PUBLICAR-IIS.bat`. |
| **HTTP 500** y la página no abre | Falta `assets\includes\`: ASP no puede compilar `canciones.asp` porque el `#include` no encuentra el archivo. Publica de nuevo con `PUBLICAR-IIS.bat`. |
| Cambié el CSS/JS y **no se refleja** | El navegador sirve la copia cacheada. Sube el valor de `ASSET_VERSION` en `canciones.asp` y `login.asp` (de `"1"` a `"2"`, etc.). |
| Las portadas de playlist dan **404** | Estás usando la ruta `~/...` tal cual como URL. Debe pasar por `AssetUrl()`. |
| Todas las canciones muestran **“Sin audio”** | Los archivos no están en `SongFiles` **o** la aplicación vive en una subcarpeta de IIS y las rutas se resolvían contra la raíz del sitio. Corregido: `AssetExists()` usa `Server.MapPath` relativo a la aplicación. |
| Una canción no reproduce y suena un error | La ruta guardada en `TBL_SONG.SONG_PATH` no corresponde a un archivo real. Usa el formato `~/songFiles/archivo.mp3`; el formulario normaliza automáticamente las rutas absolutas (`C:\...`) al guardar. |
| Los cambios no se reflejan | IIS cachea las plantillas ASP. Recicla el grupo de aplicaciones o vuelve a ejecutar el script de publicación. |
| Acentos o `Ã±` en pantalla | Guarda los `.asp` como **UTF-8**; la directiva `CodePage=65001` ya está en cada archivo. |
| “No pudimos conectar con la base de datos” | El servicio de SQL Server está detenido o el login `usr_polimusic` no existe. Vuelve a ejecutar `BDD_PoliMusic.sql`. |

---

## Notas técnicas

- **SQL injection:** todas las consultas usan `ADODB.Command` con parámetros (`?`), nunca
  concatenación de cadenas.
- **CSRF:** los formularios de creación, edición y borrado incluyen un token de sesión que se
  valida en el servidor.
- **Borrado seguro:** al eliminar una canción se borran primero sus relaciones en
  `TBL_PLAYLIST_SONG`, `TBL_TRACKLIST` y `TBL_PLAYER` dentro de una transacción, evitando
  errores de clave foránea.
- **Patrón Post/Redirect/Get:** tras cada operación se redirige con un mensaje *flash* en sesión,
  lo que evita reenvíos duplicados al recargar.
- **Animaciones:** el motor de motion reproduce el modelo de Framer Motion (muelles y *stagger*)
  sobre la Web Animations API nativa, sin dependencias externas ni CDN, y respeta
  `prefers-reduced-motion`.
- **Seguridad en producción:** las contraseñas de ejemplo están en texto plano por tratarse de
  un proyecto académico; en un entorno real deben almacenarse con hash + salt y servirse por HTTPS.

---

## Autor

Proyecto académico — **PoliMusic** · ASP Clásico + SQL Server.
