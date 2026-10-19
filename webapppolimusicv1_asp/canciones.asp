<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' ============================================================================
'  PoliMusic · canciones.asp
'  Página principal del catálogo de canciones (clon de Spotify, tema naranja)
'  Stack: ASP Clásico (VBScript) + ADO + HTML5 + CSS3 + JavaScript
' ----------------------------------------------------------------------------
'  Roles:  Session("rolUsuario")  ->  "userAdmin" (Administrador) | "epn.fis"
'          Session("nombreUsuario") -> nombre visible en la cabecera
' ----------------------------------------------------------------------------
'  Heurísticas de Nielsen aplicadas:
'   1. Visibilidad del estado  -> reproductor persistente, contadores en vivo,
'      toasts de confirmación, badges de "archivo no disponible".
'   2. Mundo real              -> lenguaje del dominio musical, iconos + texto.
'   3. Control y libertad      -> modales cancelables (ESC / clic fuera),
'      reproductor detenible, filtro reversible.
'   4. Consistencia            -> design tokens, un único sistema de botones.
'   5. Prevención de errores   -> confirmación de borrado, validación en vivo,
'      límites de longitud según el esquema de BD, acciones deshabilitadas.
'   6. Reconocer > recordar    -> buscador con placeholder, labels visibles,
'      rutas de ejemplo en el formulario.
'   7. Flexibilidad y eficiencia -> atajos de teclado (/ y Espacio), búsqueda
'      instantánea, acciones rápidas por fila.
'   8. Diseño estético mínimo  -> jerarquía tipográfica, sin ruido visual.
'   9. Recuperación de errores -> mensajes claros + estado vacío + reintento.
'  10. Ayuda y documentación   -> modal "Ayuda" con atajos y permisos.
' ============================================================================

Response.Buffer  = True
Response.CodePage = 65001
Response.Charset = "UTF-8"
Session.CodePage = 65001

%>
<!--#include file="assets/includes/nucleo.asp"-->
<%
' ---------------------------------------------------------------------------
' 6. LOGOUT
' ---------------------------------------------------------------------------
If LCase(Trim(CStr(Request.QueryString("action") & ""))) = "logout" Then
    Session.Contents.RemoveAll()
    Session.Abandon
    Response.Redirect LOGIN_PAGE
    Response.End
End If

' Token anti-CSRF
If Trim(CStr(Session("pm_csrf") & "")) = "" Then
    Randomize
    Session("pm_csrf") = Replace(Replace(CStr(Session.SessionID) & CStr(Timer) & CStr(Rnd()), ".", ""), ",", "")
End If

' ---------------------------------------------------------------------------
' 7. ESTADO DE LA PÁGINA
' ---------------------------------------------------------------------------
Dim gFormOpen, gFormMode, gFormError, gFormId, gFormNombre, gFormRuta
Dim flashType, flashMsg, strFormOpen

gFormOpen = False
gFormMode = "crear"
gFormError = ""
gFormId = 0
gFormNombre = ""
gFormRuta = ""

flashType = CStr(Session("pm_flash_type") & "")
flashMsg  = CStr(Session("pm_flash_msg") & "")
Session("pm_flash_type") = ""
Session("pm_flash_msg")  = ""

' ---------------------------------------------------------------------------
' 8. ACCIÓN ASÍNCRONA: registrar reproducción (responde JSON)
' ---------------------------------------------------------------------------
If LCase(Trim(CStr(Request.QueryString("action") & ""))) = "play" Then
    Dim idPlay, cnPlay, cmdPlay, rsPlay, playsNow
    idPlay = ToLong(Request.QueryString("id"), 0)
    Response.Clear
    Response.ContentType = "application/json"
    Response.Charset = "UTF-8"

    If idPlay <= 0 Then
        Response.Status = "400 Bad Request"
        Response.Write "{""ok"":false,""error"":""ID inválido""}"
        Response.End
    End If

    Set cnPlay = GetConnection()
    If cnPlay Is Nothing Then
        Response.Status = "500 Internal Server Error"
        Response.Write "{""ok"":false,""error"":""Sin conexión a la base de datos""}"
        Response.End
    End If

    On Error Resume Next
    Set cmdPlay = NewCmd(cnPlay, "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS,0) + 1 OUTPUT INSERTED.PLAYS WHERE ID_SONG = ?")
    cmdPlay.Parameters.Append cmdPlay.CreateParameter("@id", 3, 1, , idPlay)   ' adInteger
    Set rsPlay = cmdPlay.Execute
    playsNow = 0
    If Err.Number = 0 Then
        If Not rsPlay.EOF Then playsNow = rsPlay("PLAYS")
    End If
    If Err.Number <> 0 Then
        Err.Clear
        Response.Status = "500 Internal Server Error"
        Response.Write "{""ok"":false,""error"":""No se pudo actualizar el contador""}"
    Else
        Response.Write "{""ok"":true,""plays"":" & playsNow & "}"
    End If
    On Error GoTo 0
    cnPlay.Close
    Response.End
End If

' ---------------------------------------------------------------------------
' 9. ACCIONES CRUD (POST + patrón Post/Redirect/Get)
' ---------------------------------------------------------------------------
Sub FlashAndGo(ByVal fType, ByVal fMsg)
    Session("pm_flash_type") = fType
    Session("pm_flash_msg")  = fMsg
    Response.Redirect "canciones.asp"
    Response.End
End Sub

Sub GuardarCancion(ByVal idSong)
    Dim nombre, ruta, errores, cn, cmd, rs, existe, sql

    gFormId     = idSong
    gFormNombre = Trim(CStr(Request.Form("nombre") & ""))
    gFormRuta   = Trim(CStr(Request.Form("ruta") & ""))
    gFormMode   = "crear"
    If idSong > 0 Then gFormMode = "editar"
    gFormOpen   = True
    errores     = ""

    If Len(gFormNombre) = 0 Then errores = errores & "El nombre de la canción es obligatorio. "
    If Len(gFormNombre) > 50 Then errores = errores & "El nombre no puede superar los 50 caracteres. "
    If Len(gFormRuta) = 0 Then errores = errores & "Debes indicar la ruta del archivo de audio. "
    If Len(gFormRuta) > 255 Then errores = errores & "La ruta no puede superar los 255 caracteres. "

    If errores <> "" Then
        gFormError = errores
        Exit Sub
    End If

    ' Guardamos siempre una ruta lógica (~/songFiles/archivo.mp3), aunque el
    ' usuario pegue una ruta absoluta del disco.
    ruta = NormalizeSongPath(gFormRuta)

    Set cn = GetConnection()
    If cn Is Nothing Then
        gFormError = "No fue posible conectar con la base de datos. Verifica que SQL Server esté en ejecución."
        Exit Sub
    End If

    On Error Resume Next

    ' Nombre duplicado (regla de negocio: no dos canciones con el mismo título)
    Set cmd = NewCmd(cn, "SELECT COUNT(*) AS N FROM TBL_SONG WHERE SONG_NAME = ? AND ID_SONG <> ?")
    cmd.Parameters.Append cmd.CreateParameter("@nombre", 202, 1, 50, gFormNombre)  ' adVarWChar
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idSong)
    Set rs = cmd.Execute
    existe = 0
    If Err.Number = 0 Then
        If Not rs.EOF Then existe = rs("N")
        rs.Close
    Else
        Err.Clear
    End If

    If existe > 0 Then
        gFormError = "Ya existe una canción llamada """ & gFormNombre & """. Usa otro título."
        On Error GoTo 0
        cn.Close
        Exit Sub
    End If

    If idSong > 0 Then
        sql = "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ? WHERE ID_SONG = ?"
    Else
        sql = "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, 0)"
    End If

    Set cmd = NewCmd(cn, sql)
    cmd.Parameters.Append cmd.CreateParameter("@nombre", 202, 1, 50, gFormNombre)
    cmd.Parameters.Append cmd.CreateParameter("@ruta", 202, 1, 255, ruta)
    If idSong > 0 Then cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idSong)
    cmd.Execute , , 128                                                          ' adExecuteNoRecords

    If Err.Number <> 0 Then
        gFormError = "No se pudo guardar la canción. Revisa los datos e inténtalo otra vez."
        Err.Clear
        On Error GoTo 0
        cn.Close
        Exit Sub
    End If

    On Error GoTo 0
    cn.Close

    If idSong > 0 Then
        FlashAndGo "success", "Canción actualizada correctamente."
    Else
        FlashAndGo "success", "Canción agregada al catálogo."
    End If
End Sub

Sub EliminarCancion(ByVal idSong)
    Dim cn, cmd, rs, nombre, sql
    If idSong <= 0 Then
        FlashAndGo "error", "No se pudo identificar la canción a eliminar."
        Exit Sub
    End If

    Set cn = GetConnection()
    If cn Is Nothing Then
        FlashAndGo "error", "No fue posible conectar con la base de datos."
        Exit Sub
    End If

    On Error Resume Next
    Set cmd = NewCmd(cn, "SELECT SONG_NAME FROM TBL_SONG WHERE ID_SONG = ?")
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idSong)
    Set rs = cmd.Execute
    nombre = ""
    If Err.Number = 0 Then
        If Not rs.EOF Then nombre = rs("SONG_NAME")
        rs.Close
    Else
        Err.Clear
    End If

    ' Borrado en transacción: primero las tablas dependientes (FK)
    cn.BeginTrans
    Set cmd = NewCmd(cn, "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?")
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idSong)
    cmd.Execute , , 128

    Set cmd = NewCmd(cn, "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?")
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idSong)
    cmd.Execute , , 128

    Set cmd = NewCmd(cn, "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?")
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idSong)
    cmd.Execute , , 128

    Set cmd = NewCmd(cn, "DELETE FROM TBL_SONG WHERE ID_SONG = ?")
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idSong)
    cmd.Execute , , 128

    If Err.Number <> 0 Then
        cn.RollbackTrans
        Err.Clear
        On Error GoTo 0
        cn.Close
        FlashAndGo "error", "No se pudo eliminar la canción. Inténtalo nuevamente."
    Else
        cn.CommitTrans
        On Error GoTo 0
        cn.Close
        FlashAndGo "success", "Canción """ & nombre & """ eliminada del catálogo."
    End If
End Sub

If UCase(Trim(CStr(Request.ServerVariables("REQUEST_METHOD") & ""))) = "POST" Then
    Dim accionPost
    accionPost = LCase(Trim(CStr(Request.Form("accion") & "")))

    If accionPost <> "" Then
        If Trim(CStr(Request.Form("csrf") & "")) <> CStr(Session("pm_csrf") & "") Then
            gFormOpen = True
            gFormError = "La sesión expiró por seguridad. Recarga la página e inténtalo de nuevo."
        Else
            Select Case accionPost
                Case "crear"
                    GuardarCancion 0
                Case "actualizar"
                    Call GuardarCancion(ToLong(Request.Form("id"), 0))
                Case "eliminar"
                    Call EliminarCancion(ToLong(Request.Form("id"), 0))
            End Select
        End If
    End If
End If

' Booleano seguro para incrustar en JavaScript
If gFormOpen Then strFormOpen = "true" Else strFormOpen = "false"

' ---------------------------------------------------------------------------
' 10. CARGA DE DATOS
' ---------------------------------------------------------------------------
Dim cnMain, rsSongs, rsStats, dbError
Dim totalSongs, totalPlays, totalArtists, totalAlbums
Dim archivosDisponibles

dbError = ""
totalSongs = 0 : totalPlays = 0 : totalArtists = 0 : totalAlbums = 0
archivosDisponibles = ""

Set cnMain = GetConnection()
If cnMain Is Nothing Then
    dbError = "No pudimos conectar con la base de datos BDD_PoliMusic. " & _
              "Verifica que el servicio de SQL Server esté activo y que las credenciales sean correctas."
Else
    On Error Resume Next

    Set rsStats = cnMain.Execute("SELECT " & _
        "(SELECT COUNT(*) FROM TBL_SONG) AS TOTAL_SONGS, " & _
        "(SELECT ISNULL(SUM(PLAYS),0) FROM TBL_SONG) AS TOTAL_PLAYS, " & _
        "(SELECT COUNT(*) FROM TBL_ARTIST) AS TOTAL_ARTISTS, " & _
        "(SELECT COUNT(*) FROM TBL_ALBUM) AS TOTAL_ALBUMS")

    If Err.Number = 0 Then
        If Not rsStats.EOF Then
            totalSongs   = rsStats("TOTAL_SONGS")
            totalPlays   = rsStats("TOTAL_PLAYS")
            totalArtists = rsStats("TOTAL_ARTISTS")
            totalAlbums  = rsStats("TOTAL_ALBUMS")
        End If
        rsStats.Close
    Else
        Err.Clear
    End If

    Set rsSongs = cnMain.Execute( _
        "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS,0) AS PLAYS, " & _
        "  ISNULL((SELECT TOP 1 al.TITLE_ALBUM FROM TBL_TRACKLIST t " & _
        "          INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
        "          WHERE t.ID_SONG = s.ID_SONG ORDER BY al.ID_ALBUM), 'Sencillo') AS ALBUM_NAME, " & _
        "  (SELECT TOP 1 al.ALBUM_IMAGE_PATH FROM TBL_TRACKLIST t " & _
        "   INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
        "   WHERE t.ID_SONG = s.ID_SONG ORDER BY al.ID_ALBUM) AS ALBUM_IMAGE, " & _
        "  ISNULL((SELECT STUFF((SELECT DISTINCT ', ' + a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME,'') " & _
        "          FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "          WHERE p.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.','varchar(max)'), 1, 2, '')), " & _
        "        'Artista desconocido') AS ARTISTS " & _
        "FROM TBL_SONG s ORDER BY s.SONG_NAME")

    If Err.Number <> 0 Then
        dbError = "Ocurrió un error al consultar el catálogo de canciones."
        Err.Clear
    End If
    On Error GoTo 0

    ' Archivos de audio físicamente disponibles (para el selector del formulario)
    Dim fso, folder, fileItem
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If Err.Number = 0 Then
        Set folder = fso.GetFolder(Server.MapPath(AUDIO_FOLDER))
        If Err.Number = 0 Then
            For Each fileItem In folder.Files
                If LCase(fso.GetExtensionName(fileItem.Name)) = "mp3" Then
                    archivosDisponibles = archivosDisponibles & "<option value=""~/songFiles/" & H(fileItem.Name) & """></option>"
                End If
            Next
        End If
        Err.Clear
    End If
    Err.Clear
    Set folder = Nothing
    Set fso = Nothing
    On Error GoTo 0
End If

' Paleta para las portadas generadas
Dim palC1, palC2
palC1 = Array("#FF9A3C", "#FF7A45", "#FFB020", "#F2542D", "#E8590C", "#D9480F")
palC2 = Array("#E23E00", "#D7263D", "#F48C06", "#B23A48", "#A33B00", "#7A2E0E")
%>
<!--#include file="assets/includes/head.asp"-->
<body>
<a class="skip-link" href="#contenido">Saltar al contenido principal</a>

<div class="app">
<!--#include file="assets/includes/sidebar.asp"-->

  <!-- ==================== MAIN ==================== -->
  <div class="main">
<!--#include file="assets/includes/topbar.asp"-->

    <main id="contenido">
      <!-- HERO -->
      <section class="hero">
        <div class="hero-copy">
          <span class="eyebrow">Tu biblioteca</span>
          <h1>Song <em>List</em></h1>
          <p class="hero-sub">
            Hola <strong><%= H(sNombre) %></strong>, este es el catálogo completo de <strong>PoliMusic</strong>.
            <% If boolAdmin Then %>
              Como administrador puedes reproducir, agregar, editar y eliminar canciones.
            <% Else %>
              Explora el catálogo y reproduce cualquier canción directamente desde la lista.
            <% End If %>
          </p>
        </div>

        <div class="hero-badge">
          <span class="ring"><%= Icon("music") %></span>
          <span class="meta">
            <b><%= NumFmt(totalSongs) %> canciones</b>
            <span><%= NumFmt(totalPlays) %> reproducciones</span>
          </span>
        </div>
      </section>

      <!-- STATS -->
      <section class="stats" aria-label="Resumen del catálogo">
        <article class="stat reveal">
          <div class="stat-top"><%= Icon("list") %><span>Canciones</span></div>
          <div class="stat-value"><%= NumFmt(totalSongs) %></div>
        </article>
        <article class="stat reveal">
          <div class="stat-top"><%= Icon("play") %><span>Reproducciones</span></div>
          <div class="stat-value"><%= NumFmt(totalPlays) %></div>
        </article>
        <article class="stat reveal">
          <div class="stat-top"><%= Icon("mic") %><span>Artistas</span></div>
          <div class="stat-value"><%= NumFmt(totalArtists) %></div>
        </article>
        <article class="stat reveal">
          <div class="stat-top"><%= Icon("album") %><span>Álbumes</span></div>
          <div class="stat-value"><%= NumFmt(totalAlbums) %></div>
        </article>
      </section>

      <% If dbError <> "" Then %>
      <div class="alert" role="alert">
        <%= Icon("warning") %>
        <div>
          <h4>No se pudo cargar el catálogo</h4>
          <p><%= H(dbError) %></p>
        </div>
      </div>
      <% End If %>

      <!-- TABLA -->
      <section class="content">
        <div class="card">
          <div class="card-head">
            <h2 class="card-title"><%= Icon("list") %> Canciones</h2>
            <span class="count-chip" id="countChip">
              <% If Not (rsSongs Is Nothing) Then %>
                <%= NumFmt(totalSongs) %> en total
              <% Else %>
                0 en total
              <% End If %>
            </span>

            <div class="card-tools">
              <div class="search">
                <%= Icon("search") %>
                <input type="search" id="searchInput" placeholder="Buscar por canción, artista o álbum…"
                       aria-label="Buscar canciones" autocomplete="off">
                <kbd>/</kbd>
              </div>
              <% If boolAdmin Then %>
              <button class="btn btn-primary" type="button" id="btnNew">
                <%= Icon("plus") %><span>Nueva canción</span>
              </button>
              <% End If %>
            </div>
          </div>

          <% If dbError = "" And Not (rsSongs Is Nothing) Then %>
            <% If rsSongs.EOF Then %>
              <div class="empty">
                <span class="empty-icon"><%= Icon("music") %></span>
                <h3>Tu catálogo está vacío</h3>
                <p>Todavía no hay canciones registradas en PoliMusic.
                   <% If boolAdmin Then %>Agrega la primera para empezar.<% Else %>Vuelve más tarde.<% End If %></p>
                <% If boolAdmin Then %>
                <button class="btn btn-primary" type="button" data-open-new>
                  <%= Icon("plus") %><span>Agregar canción</span>
                </button>
                <% End If %>
              </div>
            <% Else %>
            <div class="table-wrap">
              <table class="songs" id="songsTable">
                <caption class="sr-only">Listado de canciones del catálogo PoliMusic</caption>
                <thead>
                  <tr>
                    <th scope="col">#</th>
                    <th scope="col">Canción</th>
                    <th scope="col">Álbum</th>
                    <th scope="col">Reproducciones</th>
                    <th scope="col"><% If boolAdmin Then %>Acciones<% Else %>Reproducir<% End If %></th>
                  </tr>
                </thead>
                <tbody id="songsBody">
                <%
                  Dim idx, rowId, rowName, rowPath, rowPlays, rowAlbum, rowArtists, rowUrl, rowOk, rowLetter, rowC1, rowC2, rowImg
                  idx = 0
                  Do While Not rsSongs.EOF
                      idx = idx + 1
                      rowId      = rsSongs("ID_SONG")
                      rowName    = CStr(rsSongs("SONG_NAME") & "")
                      rowPath    = CStr(rsSongs("SONG_PATH") & "")
                      rowPlays   = rsSongs("PLAYS")
                      rowAlbum   = CStr(rsSongs("ALBUM_NAME") & "")
                      rowArtists = CStr(rsSongs("ARTISTS") & "")
                      rowImg     = CStr(rsSongs("ALBUM_IMAGE") & "")
                      rowUrl     = AssetUrl(rowPath)
                      rowOk      = AssetExists(rowUrl)
                      rowLetter  = UCase(Left(rowName, 1))
                      rowC1      = palC1((rowId - 1) Mod 6)
                      rowC2      = palC2((rowId - 1) Mod 6)
                %>
                  <tr class="song-row reveal"
                      data-id="<%= rowId %>"
                      data-name="<%= H(rowName) %>"
                      data-path="<%= H(rowPath) %>"
                      data-artists="<%= H(rowArtists) %>"
                      data-album="<%= H(rowAlbum) %>"
                      data-src="<%= H(rowUrl) %>"
                      data-available="<% If rowOk Then %>1<% Else %>0<% End If %>"
                      data-plays="<%= rowPlays %>"
                      data-letter="<%= H(rowLetter) %>"
                      data-c1="<%= rowC1 %>"
                      data-c2="<%= rowC2 %>">
                    <td class="col-index"><span class="row-index"><%= Right("0" & idx, 2) %></span></td>

                    <td class="cell-song">
                      <div class="song-main">
                        <div class="cover" style="--c1:<%= rowC1 %>;--c2:<%= rowC2 %>">
                          <% If rowImg <> "" And AssetExists(AssetUrl(rowImg)) Then %>
                            <img src="<%= H(AssetUrl(rowImg)) %>" alt="" loading="lazy">
                          <% Else %>
                            <%= H(rowLetter) %>
                          <% End If %>
                          <span class="eq" aria-hidden="true"><i></i><i></i><i></i></span>
                        </div>
                        <div class="song-text">
                          <span class="song-name">
                            <%= H(rowName) %>
                            <% If Not rowOk Then %>
                              <span class="flag" title="El archivo de audio no está en la carpeta SongFiles"><%= Icon("warning") %>Sin audio</span>
                            <% End If %>
                          </span>
                          <span class="song-artist"><%= H(rowArtists) %></span>
                        </div>
                      </div>
                    </td>

                    <td class="col-album"><span class="album-pill"><%= H(rowAlbum) %></span></td>

                    <td class="col-plays">
                      <span class="plays" data-plays-cell>
                        <%= Icon("play") %><span class="plays-value"><%= NumFmt(rowPlays) %></span>
                      </span>
                    </td>

                    <td class="col-actions">
                      <div class="row-actions">
                        <button class="icon-btn play" type="button" data-play
                                aria-label="Reproducir <%= H(rowName) %>"
                                title="<% If rowOk Then %>Reproducir<% Else %>Archivo de audio no disponible<% End If %>"
                                <% If Not rowOk Then %>disabled aria-disabled="true"<% End If %>>
                          <%= Icon("play") %>
                        </button>
                        <% If boolAdmin Then %>
                        <button class="icon-btn" type="button" data-edit
                                aria-label="Editar <%= H(rowName) %>" title="Editar">
                          <%= Icon("edit") %>
                        </button>
                        <button class="icon-btn danger" type="button" data-delete
                                aria-label="Eliminar <%= H(rowName) %>" title="Eliminar">
                          <%= Icon("trash") %>
                        </button>
                        <% End If %>
                      </div>
                    </td>
                  </tr>
                <%
                      rsSongs.MoveNext
                  Loop
                %>
                </tbody>
              </table>
            </div>

            <div class="empty" id="noResults" hidden>
              <span class="empty-icon"><%= Icon("search") %></span>
              <h3>Sin resultados</h3>
              <p id="noResultsText">No encontramos canciones que coincidan con tu búsqueda.</p>
              <button class="btn btn-ghost" type="button" id="btnClearSearch">Limpiar búsqueda</button>
            </div>
            <% End If %>
          <% ElseIf dbError = "" Then %>
            <div class="empty">
              <span class="empty-icon"><%= Icon("music") %></span>
              <h3>Catálogo no disponible</h3>
              <p>No se pudo recuperar el listado de canciones.</p>
            </div>
          <% End If %>
        </div>

        <div class="foot">
          <span><%= H(APP_NAME) %> · <%= Year(Date()) %></span>
          <span class="dot"></span>
          <span>ASP Clásico + SQL Server</span>
          <span class="spacer"></span>
          <span><% If boolAdmin Then %>Sesión de administrador<% Else %>Sesión de usuario<% End If %></span>
        </div>
      </section>
    </main>
  </div>
</div>

<!--#include file="assets/includes/player.asp"-->

<!--#include file="assets/includes/modal-form.asp"-->

<!--#include file="assets/includes/modal-delete.asp"-->

<!--#include file="assets/includes/modal-help.asp"-->

<!--#include file="assets/includes/toasts.asp"-->

<script>
/* Estado inyectado por el servidor (debe existir antes del módulo principal) */
window.PM = {
  isAdmin: <%= strAdmin %>,
  flash: { type: "<%= JsStr(flashType) %>", msg: "<%= JsStr(flashMsg) %>" },
  form: { open: <%= strFormOpen %>, mode: "<%= JsStr(gFormMode) %>" }
};
</script>
<script src="assets/js/canciones.js"></script>
</body>
</html>
<%
' ---------------------------------------------------------------------------
' 11. LIBERACIÓN DE RECURSOS
' ---------------------------------------------------------------------------
On Error Resume Next
If Not (rsSongs Is Nothing) Then
    If rsSongs.State <> 0 Then rsSongs.Close
    Set rsSongs = Nothing
End If
If Not (cnMain Is Nothing) Then
    If cnMain.State <> 0 Then cnMain.Close
    Set cnMain = Nothing
End If
On Error GoTo 0
%>
