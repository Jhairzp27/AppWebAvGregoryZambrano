<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' ============================================================================
'  PoliMusic · playlists.asp
'  Biblioteca de playlists: rejilla de portadas y detalle con sus canciones.
'  Stack: ASP Clásico (VBScript) + ADO + HTML5 + CSS3 + JavaScript
' ----------------------------------------------------------------------------
'  Rutas:
'    playlists.asp          -> rejilla con todas las playlists
'    playlists.asp?id=N     -> detalle de la playlist N con sus canciones
' ----------------------------------------------------------------------------
'  Heurísticas de Nielsen aplicadas:
'   1. Visibilidad del estado  -> sección activa en el menú, contador de
'      canciones por playlist y ruta de navegación en la cabecera.
'   3. Control y libertad      -> enlace "Volver" siempre disponible en el
'      detalle, y tarjetas navegables con teclado.
'   4. Consistencia            -> mismos tokens, tipografías y componentes
'      que la página de canciones.
'   6. Reconocer > recordar    -> la portada y el nombre de la playlist se
'      repiten en el detalle, sin obligar a memorizar.
'   9. Recuperación de errores -> si la playlist no existe se explica y se
'      ofrece volver al listado; si no hay portada se genera una.
'  10. Ayuda y documentación   -> modal de ayuda compartido con el catálogo.
' ============================================================================

Response.Buffer   = True
Response.CodePage = 65001
Response.Charset  = "UTF-8"
Session.CodePage  = 65001
%>
<!--#include file="assets/includes/nucleo.asp"-->
<%
' ---------------------------------------------------------------------------
' 6. CERRAR SESIÓN
' ---------------------------------------------------------------------------
If LCase(Trim(CStr(Request.QueryString("action") & ""))) = "logout" Then
    Session.Contents.RemoveAll()
    Session.Abandon
    Response.Redirect LOGIN_PAGE
    Response.End
End If

' ---------------------------------------------------------------------------
' 7. PARÁMETROS DE LA VISTA
' ---------------------------------------------------------------------------
Dim idPlaylist, vista
idPlaylist = ToLong(Request.QueryString("id"), 0)
If idPlaylist > 0 Then vista = "detalle" Else vista = "lista"

' ---------------------------------------------------------------------------
' 8. HELPERS PROPIOS DE ESTA PÁGINA
' ---------------------------------------------------------------------------
' Fecha corta en español: "12 dic 2026"
Function FechaCorta(ByVal valor)
    Dim meses, d
    meses = Array("ene", "feb", "mar", "abr", "may", "jun", _
                  "jul", "ago", "sep", "oct", "nov", "dic")
    If IsNull(valor) Then
        FechaCorta = "sin fecha"
        Exit Function
    End If
    If Not IsDate(valor) Then
        FechaCorta = "sin fecha"
        Exit Function
    End If
    d = CDate(valor)
    FechaCorta = Day(d) & " " & meses(Month(d) - 1) & " " & Year(d)
End Function

' TYPE: 0 = pública, 1 = privada (TBL_CATALOG, COD '2')
Function TipoTexto(ByVal tipo)
    If ToLong(tipo, 0) = 1 Then
        TipoTexto = "Privada"
    Else
        TipoTexto = "Pública"
    End If
End Function

' Concordancia singular / plural: "1 canción" / "4 canciones"
Function TextoCanciones(ByVal n)
    If ToLong(n, 0) = 1 Then
        TextoCanciones = "1 canción"
    Else
        TextoCanciones = NumFmt(n) & " canciones"
    End If
End Function

' ---------------------------------------------------------------------------
' 9. CARGA DE DATOS
' ---------------------------------------------------------------------------
Dim cnMain, rsPl, rsSongs, cmd
Dim dbError, sqlLista, sqlDetalle, sqlCanciones
Dim totalPlaylists, totalPublicas, totalCanciones
Dim plTitle, plPhoto, plUrl, plOk, plType, plTypeTxt, plFecha, plOwner, plCount, plLetter, plC1, plC2

dbError = ""
totalPlaylists = 0 : totalPublicas = 0 : totalCanciones = 0

' Paleta para portadas generadas cuando la imagen no existe
Dim palC1, palC2
palC1 = Array("#FF9A3C", "#FF7A45", "#FFB020", "#F2542D", "#E8590C", "#D9480F")
palC2 = Array("#E23E00", "#D7263D", "#F48C06", "#B23A48", "#A33B00", "#7A2E0E")

sqlLista = "SELECT p.ID_PLAYLIST, p.TITLE, p.TYPE, p.CREATION_DATE, p.PHOTO, " & _
           "  ISNULL(u.USERNAME, 'PoliMusic') AS OWNER, " & _
           "  (SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps " & _
           "   WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS TOTAL " & _
           "FROM TBL_PLAYLIST p " & _
           "LEFT JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
           "ORDER BY p.ID_PLAYLIST"

sqlDetalle = "SELECT p.ID_PLAYLIST, p.TITLE, p.TYPE, p.CREATION_DATE, p.PHOTO, " & _
             "  ISNULL(u.USERNAME, 'PoliMusic') AS OWNER, " & _
             "  (SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps " & _
             "   WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS TOTAL " & _
             "FROM TBL_PLAYLIST p " & _
             "LEFT JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
             "WHERE p.ID_PLAYLIST = ?"

sqlCanciones = "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS,0) AS PLAYS, " & _
    "  ISNULL((SELECT TOP 1 al.TITLE_ALBUM FROM TBL_TRACKLIST t " & _
    "          INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
    "          WHERE t.ID_SONG = s.ID_SONG ORDER BY al.ID_ALBUM), 'Sencillo') AS ALBUM_NAME, " & _
    "  ISNULL((SELECT TOP 1 al.ALBUM_IMAGE_PATH FROM TBL_TRACKLIST t " & _
    "   INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
    "   WHERE t.ID_SONG = s.ID_SONG ORDER BY al.ID_ALBUM), '') AS ALBUM_IMAGE, " & _
    "  ISNULL((SELECT STUFF((SELECT DISTINCT ', ' + a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME,'') " & _
    "          FROM TBL_PLAYER pl INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = pl.ID_ARTIST " & _
    "          WHERE pl.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.','varchar(max)'), 1, 2, '')), " & _
    "        'Artista desconocido') AS ARTISTS " & _
    "FROM TBL_PLAYLIST_SONG ps " & _
    "INNER JOIN TBL_SONG s ON s.ID_SONG = ps.ID_SONG " & _
    "WHERE ps.ID_PLAYLIST = ? " & _
    "ORDER BY s.SONG_NAME"

Set cnMain = GetConnection()

If cnMain Is Nothing Then
    vista = "error"
    dbError = "No pudimos conectar con la base de datos BDD_PoliMusic. " & _
              "Verifica que el servicio de SQL Server esté activo y que las credenciales sean correctas."
Else
    On Error Resume Next

    If vista = "detalle" Then
        Set cmd = NewCmd(cnMain, sqlDetalle)
        cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idPlaylist)
        Set rsPl = cmd.Execute

        If Err.Number <> 0 Then
            Err.Clear
            vista = "error"
            dbError = "Ocurrió un error al consultar la playlist."
        ElseIf rsPl.EOF Then
            rsPl.Close
            Set rsPl = Nothing
            vista = "error"
            dbError = "La playlist que buscas no existe o fue eliminada."
        End If
    Else
        Set rsPl = cnMain.Execute(sqlLista)
        If Err.Number <> 0 Then
            Err.Clear
            vista = "error"
            dbError = "Ocurrió un error al consultar las playlists."
        End If
    End If

    On Error GoTo 0
End If

' Datos de la playlist concreta
If vista = "detalle" Then
    plTitle  = CStr(rsPl("TITLE") & "")
    plPhoto  = CStr(rsPl("PHOTO") & "")
    plType   = ToLong(rsPl("TYPE"), 0)
    plTypeTxt = TipoTexto(plType)
    plFecha  = FechaCorta(rsPl("CREATION_DATE"))
    plOwner  = CStr(rsPl("OWNER") & "")
    plCount  = ToLong(rsPl("TOTAL"), 0)
    plUrl    = AssetUrl(plPhoto)
    plOk     = AssetExists(plUrl)
    plLetter = UCase(Left(plTitle, 1))
    plC1     = palC1((idPlaylist - 1) Mod 6)
    plC2     = palC2((idPlaylist - 1) Mod 6)

    On Error Resume Next
    Set cmd = NewCmd(cnMain, sqlCanciones)
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , idPlaylist)
    Set rsSongs = cmd.Execute
    If Err.Number <> 0 Then
        Err.Clear
        Set rsSongs = Nothing
    End If
    On Error GoTo 0
End If

' Totales para el resumen del listado
If vista = "lista" And Not (cnMain Is Nothing) Then
    Dim rsTot
    On Error Resume Next
    Set rsTot = cnMain.Execute("SELECT " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST) AS TOTAL, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST WHERE ISNULL(TYPE,0) = 0) AS PUBLICAS, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG) AS CANCIONES")
    If Err.Number = 0 Then
        If Not rsTot.EOF Then
            totalPlaylists = ToLong(rsTot("TOTAL"), 0)
            totalPublicas  = ToLong(rsTot("PUBLICAS"), 0)
            totalCanciones = ToLong(rsTot("CANCIONES"), 0)
        End If
        rsTot.Close
    Else
        Err.Clear
    End If
    On Error GoTo 0
    Set rsTot = Nothing
End If
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
<% If vista = "error" Then %>

      <!-- ==================== ESTADO DE ERROR ==================== -->
      <section class="hero">
        <div class="hero-copy">
          <span class="eyebrow">Playlists</span>
          <h1>No se pudo <em>abrir</em></h1>
          <p class="hero-sub"><%= H(dbError) %></p>
        </div>
      </section>
      <section class="content">
        <div class="empty">
          <span class="empty-icon"><%= Icon("album") %></span>
          <h3>Sin playlists para mostrar</h3>
          <p>Vuelve al listado general para ver las playlists disponibles.</p>
          <a class="btn btn-primary" href="playlists.asp"><%= Icon("grid") %><span>Ver todas las playlists</span></a>
        </div>
      </section>

<% ElseIf vista = "detalle" Then %>

      <!-- ==================== DETALLE DE PLAYLIST ==================== -->
      <div class="pl-back">
        <a class="btn btn-ghost" href="playlists.asp">
          <%= Icon("prev") %><span>Todas las playlists</span>
        </a>
      </div>

      <section class="pl-head">
        <div class="pl-cover pl-cover-lg" style="--c1:<%= plC1 %>;--c2:<%= plC2 %>">
          <% If plOk Then %>
            <img src="<%= H(plUrl) %>" alt="Portada de <%= H(plTitle) %>">
          <% Else %>
            <%= H(plLetter) %>
          <% End If %>
        </div>

        <div class="pl-head-copy">
          <span class="eyebrow">Playlist <%= LCase(plTypeTxt) %></span>
          <h1><%= H(plTitle) %></h1>
          <p class="pl-meta">
            <span class="pl-type<% If plType = 1 Then %> is-private<% End If %>">
              <% If plType = 1 Then %><%= Icon("lock") %><% Else %><%= Icon("globe") %><% End If %><%= plTypeTxt %>
            </span>
            <span><strong><%= TextoCanciones(plCount) %></strong></span>
            <span class="dot"></span>
            <span>Creada por <strong><%= H(plOwner) %></strong></span>
            <span class="dot"></span>
            <span><%= plFecha %></span>
          </p>
        </div>
      </section>

      <section class="content">
        <div class="card">
          <div class="card-head">
            <h2 class="card-title"><%= Icon("list") %>Canciones de la playlist</h2>
            <span class="count-chip"><%= NumFmt(plCount) %> en total</span>
          </div>

          <% If rsSongs Is Nothing Then %>
            <div class="empty">
              <span class="empty-icon"><%= Icon("warning") %></span>
              <h3>No pudimos leer las canciones</h3>
              <p>Intenta recargar la página en unos segundos.</p>
            </div>
          <% ElseIf rsSongs.EOF Then %>
            <div class="empty">
              <span class="empty-icon"><%= Icon("music") %></span>
              <h3>Esta playlist está vacía</h3>
              <p>Todavía no tiene canciones asignadas.</p>
              <a class="btn btn-ghost" href="canciones.asp"><%= Icon("list") %><span>Ir al catálogo</span></a>
            </div>
          <% Else %>
            <table class="songs">
              <caption class="sr-only">Canciones de la playlist <%= H(plTitle) %></caption>
              <thead>
                <tr>
                  <th scope="col">#</th>
                  <th scope="col">Canción</th>
                  <th scope="col">Álbum</th>
                  <th scope="col">Reproducciones</th>
                  <th scope="col">Reproducir</th>
                </tr>
              </thead>
              <tbody>
              <%
                Dim idx, rowId, rowName, rowPath, rowPlays, rowAlbum, rowArtists, rowImg
                Dim rowUrl, rowOk, rowLetter, rowC1, rowC2
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
                <tr class="song-row track-row reveal"
                    data-id="<%= rowId %>"
                    data-name="<%= H(rowName) %>"
                    data-artists="<%= H(rowArtists) %>"
                    data-src="<%= H(rowUrl) %>"
                    data-available="<% If rowOk Then %>1<% Else %>0<% End If %>"
                    data-plays="<%= rowPlays %>"
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
                    <span class="plays"><%= Icon("play") %><span class="plays-value"><%= NumFmt(rowPlays) %></span></span>
                  </td>

                  <td class="col-actions">
                    <div class="row-actions">
                      <button class="icon-btn play" type="button" data-play
                              aria-label="Reproducir <%= H(rowName) %>"
                              title="<% If rowOk Then %>Reproducir<% Else %>Archivo de audio no disponible<% End If %>"
                              <% If Not rowOk Then %>disabled aria-disabled="true"<% End If %>>
                        <%= Icon("play") %>
                      </button>
                    </div>
                  </td>
                </tr>
              <%
                    rsSongs.MoveNext
                Loop
              %>
              </tbody>
            </table>
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

<% Else %>

      <!-- ==================== LISTADO DE PLAYLISTS ==================== -->
      <section class="hero">
        <div class="hero-copy">
          <span class="eyebrow">Tu colección</span>
          <h1>Play<em>lists</em></h1>
          <p class="hero-sub">
            Hola <strong><%= H(sNombre) %></strong>, estas son las playlists guardadas en
            <strong>PoliMusic</strong>. Abre una para ver sus canciones.
          </p>
        </div>

        <div class="hero-badge">
          <span class="ring"><%= Icon("album") %></span>
          <span class="meta">
            <b><%= NumFmt(totalPlaylists) %> playlists</b>
            <span><%= NumFmt(totalPublicas) %> públicas</span>
          </span>
        </div>
      </section>

      <section class="stats" aria-label="Resumen de playlists">
        <article class="stat reveal">
          <div class="stat-top"><%= Icon("album") %><span>Playlists</span></div>
          <div class="stat-value"><%= NumFmt(totalPlaylists) %></div>
        </article>
        <article class="stat reveal">
          <div class="stat-top"><%= Icon("grid") %><span>Públicas</span></div>
          <div class="stat-value"><%= NumFmt(totalPublicas) %></div>
        </article>
        <article class="stat reveal">
          <div class="stat-top"><%= Icon("music") %><span>Canciones guardadas</span></div>
          <div class="stat-value"><%= NumFmt(totalCanciones) %></div>
        </article>
      </section>

      <section class="content">
        <% If rsPl Is Nothing Then %>
          <div class="empty">
            <span class="empty-icon"><%= Icon("warning") %></span>
            <h3>No pudimos cargar las playlists</h3>
            <p>Revisa la conexión con la base de datos y vuelve a intentarlo.</p>
          </div>
        <% ElseIf rsPl.EOF Then %>
          <div class="empty">
            <span class="empty-icon"><%= Icon("album") %></span>
            <h3>Todavía no hay playlists</h3>
            <p>Cuando se registren playlists aparecerán aquí con su portada.</p>
          </div>
        <% Else %>
          <div class="pl-grid">
          <%
            Dim plId, plT, plP, plTy, plF, plO, plN, plL, plU, plAvail, pc1, pc2
            Do While Not rsPl.EOF
                plId  = rsPl("ID_PLAYLIST")
                plT   = CStr(rsPl("TITLE") & "")
                plP   = CStr(rsPl("PHOTO") & "")
                plTy  = ToLong(rsPl("TYPE"), 0)
                plF   = FechaCorta(rsPl("CREATION_DATE"))
                plO   = CStr(rsPl("OWNER") & "")
                plN   = ToLong(rsPl("TOTAL"), 0)
                plL   = UCase(Left(plT, 1))
                plU   = AssetUrl(plP)
                plAvail = AssetExists(plU)
                pc1 = palC1((plId - 1) Mod 6)
                pc2 = palC2((plId - 1) Mod 6)
          %>
            <a class="pl-card reveal" href="playlists.asp?id=<%= plId %>">
              <div class="pl-cover" style="--c1:<%= pc1 %>;--c2:<%= pc2 %>">
                <% If plAvail Then %>
                  <img src="<%= H(plU) %>" alt="Portada de <%= H(plT) %>" loading="lazy">
                <% Else %>
                  <%= H(plL) %>
                <% End If %>
                <span class="pl-type<% If plTy = 1 Then %> is-private<% End If %>">
                  <% If plTy = 1 Then %><%= Icon("lock") %><% Else %><%= Icon("globe") %><% End If %><%= TipoTexto(plTy) %>
                </span>
                <span class="pl-count"><%= TextoCanciones(plN) %></span>
              </div>
              <div class="pl-body">
                <h3><%= H(plT) %></h3>
                <p><%= H(plO) %> · <%= plF %></p>
              </div>
            </a>
          <%
                rsPl.MoveNext
            Loop
          %>
          </div>
        <% End If %>

        <div class="foot">
          <span><%= H(APP_NAME) %> · <%= Year(Date()) %></span>
          <span class="dot"></span>
          <span>ASP Clásico + SQL Server</span>
          <span class="spacer"></span>
          <span><% If boolAdmin Then %>Sesión de administrador<% Else %>Sesión de usuario<% End If %></span>
        </div>
      </section>

<% End If %>
    </main>
  </div>
</div>

<!--#include file="assets/includes/player.asp"-->

<!--#include file="assets/includes/modal-help.asp"-->

<!--#include file="assets/includes/toasts.asp"-->

<script>
/* Estado inyectado por el servidor (debe existir antes del módulo principal) */
window.PM = {
  isAdmin: <%= strAdmin %>,
  vista: "<%= vista %>",
  playlist: "<%= JsStr(plTitle) %>"
};
</script>
<script src="assets/js/playlists.js"></script>
</body>
</html>
<%
' ---------------------------------------------------------------------------
' 10. LIBERACIÓN DE RECURSOS
' ---------------------------------------------------------------------------
On Error Resume Next
If Not (rsSongs Is Nothing) Then
    If rsSongs.State <> 0 Then rsSongs.Close
    Set rsSongs = Nothing
End If
If Not (rsPl Is Nothing) Then
    If rsPl.State <> 0 Then rsPl.Close
    Set rsPl = Nothing
End If
If Not (cnMain Is Nothing) Then
    If cnMain.State <> 0 Then cnMain.Close
    Set cnMain = Nothing
End If
On Error GoTo 0
%>
