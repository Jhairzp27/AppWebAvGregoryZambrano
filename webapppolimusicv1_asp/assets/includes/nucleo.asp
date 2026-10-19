<%
' ============================================================================
'  PoliMusic · assets/includes/nucleo.asp
'  Núcleo compartido por todas las páginas ASP: configuración, helpers,
'  iconos, conexión ADO, sesión y roles.
' ----------------------------------------------------------------------------
'  Se inserta con <!--#include file="assets/includes/nucleo.asp"--> y comparte
'  el ámbito de la página que lo incluye, por lo que sus funciones y
'  constantes quedan disponibles sin prefijo.
' ============================================================================
' ---------------------------------------------------------------------------
' 1. CONFIGURACIÓN
' ---------------------------------------------------------------------------
Const APP_NAME     = "PoliMusic"
Const LOGIN_PAGE   = "login.asp"

' Version de assets: cambiala (1 -> 2 -> 3...) al desplegar cambios de CSS/JS
' para que el navegador no sirva la copia cacheada.
Const ASSET_VERSION = "1"
Const ASSET_ROOT   = "SongFilesAndImages_resources"
Const AUDIO_FOLDER = "SongFilesAndImages_resources/SongFiles"
Const IMG_SONGS    = "SongFilesAndImages_resources/SongFiles"
Const IMG_USERS    = "SongFilesAndImages_resources/UserImages"
Const IMG_PLAYLIST = "SongFilesAndImages_resources/PlaylistImages"
Const IMG_ALBUM    = "SongFilesAndImages_resources/AlbumImages"
Const IMG_ARTIST   = "SongFilesAndImages_resources/ArtistImages"

' Credenciales del script BDD_PoliMusic.sql
Const DB_SERVER = "localhost"
Const DB_NAME   = "BDD_PoliMusic"
Const DB_USER   = "usr_polimusic"
Const DB_PASS   = "Politecnica1"

' ---------------------------------------------------------------------------
' 2. HELPERS GENERALES
' ---------------------------------------------------------------------------
Function H(ByVal value)          ' HTML encode
    H = Server.HTMLEncode(CStr(value & ""))
End Function

Function JsStr(ByVal value)      ' cadena segura para incrustar en JS
    Dim s
    s = CStr(value & "")
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCrLf, " ")
    s = Replace(s, vbCr, " ")
    s = Replace(s, vbLf, " ")
    s = Replace(s, "</", "<\/")
    JsStr = s
End Function

Function ToLong(ByVal value, ByVal fallback)
    If IsNumeric(value) Then
        ToLong = CLng(value)
    Else
        ToLong = fallback
    End If
End Function

Function NumFmt(ByVal n)
    Dim s, out, i, c
    s = CStr(CLng(n))
    out = ""
    c = 0
    For i = Len(s) To 1 Step -1
        out = Mid(s, i, 1) & out
        c = c + 1
        If (c Mod 3 = 0) And (i > 1) Then out = "." & out
    Next
    NumFmt = out
End Function

' Convierte una ruta de BD en una URL relativa válida dentro de la aplicación.
' Acepta las tres formas que pueden convivir en TBL_SONG:
'   ~/songFiles/x.mp3
'   SongFilesAndImages_resources/SongFiles/x.mp3
'   C:\...\SongFilesAndImages_resources\SongFiles\x.mp3   (ruta absoluta)
Function AssetUrl(ByVal dbPath)
    Dim p, low, pos, seg, rest

    p   = Replace(Trim(CStr(dbPath & "")), "\", "/")
    low = LCase(p)

    ' 1) La ruta ya contiene la carpeta raíz de recursos (absoluta o relativa):
    '    nos quedamos desde ahí para que la URL sea siempre relativa al sitio.
    pos = InStr(low, LCase(ASSET_ROOT & "/"))
    If pos > 0 Then
        AssetUrl = Replace(Mid(p, pos), " ", "%20")
        Exit Function
    End If

    ' 2) Ruta lógica ~/carpeta/archivo
    If Left(p, 2) = "~/" Then p = Mid(p, 3)
    If Left(p, 1) = "/"  Then p = Mid(p, 2)

    pos = InStr(p, "/")
    If pos > 0 Then
        seg  = LCase(Left(p, pos - 1))
        rest = Mid(p, pos + 1)
        Select Case seg
            Case "songfiles"     : p = IMG_SONGS     & "/" & rest
            Case "userimages"    : p = IMG_USERS     & "/" & rest
            Case "playlistimages": p = IMG_PLAYLIST  & "/" & rest
            Case "albumimages"   : p = IMG_ALBUM     & "/" & rest
            Case "artistimages"  : p = IMG_ARTIST    & "/" & rest
        End Select
    End If

    ' 3) Cualquier otra ruta absoluta: usar solo el nombre del archivo y
    '    ubicarlo en la carpeta de audio.
    If InStr(p, ":") > 0 Or Left(p, 1) = "/" Then
        pos = InStrRev(p, "/")
        If pos > 0 Then p = IMG_SONGS & "/" & Mid(p, pos + 1)
    End If

    AssetUrl = Replace(p, " ", "%20")
End Function

' Normaliza la ruta antes de guardarla en BD, para no almacenar rutas absolutas
' del equipo de desarrollo (que dejarían de funcionar en otro servidor).
Function NormalizeSongPath(ByVal rawPath)
    Dim p, low, pos, prefix
    p    = Replace(Trim(CStr(rawPath & "")), "\", "/")
    low  = LCase(p)
    prefix = LCase(ASSET_ROOT & "/")

    pos = InStr(low, prefix)
    If pos > 0 Then
        p = Mid(p, pos + Len(prefix))
        If LCase(Left(p, 9)) = "songfiles" Then p = "songFiles" & Mid(p, 10)
        NormalizeSongPath = "~/" & p
    ElseIf Left(p, 2) = "~/" Then
        NormalizeSongPath = p
    Else
        NormalizeSongPath = p
    End If
End Function

' Comprueba si el archivo físico existe (falla "en silencio" si FSO no está permitido).
' IMPORTANTE: MapPath se resuelve relativo a la carpeta de esta página (raíz de la
' aplicación). Con "/" delante apuntaría a la raíz del SITIO y, si el proyecto vive
' en una subcarpeta de IIS, ningún archivo se encontraría.
Function AssetExists(ByVal url)
    Dim fso, physical
    AssetExists = True
    If Trim(CStr(url & "")) = "" Then Exit Function

    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If Err.Number <> 0 Then
        Err.Clear
        On Error GoTo 0
        Exit Function
    End If

    physical = Server.MapPath(Replace(url, "%20", " "))
    If Err.Number <> 0 Then
        Err.Clear
        physical = Server.MapPath("/" & Replace(url, "%20", " "))
    End If

    If Err.Number = 0 Then
        AssetExists = fso.FileExists(physical)
    End If
    If Err.Number <> 0 Then AssetExists = True
    Err.Clear
    Set fso = Nothing
    On Error GoTo 0
End Function

Function Initials(ByVal fullName)
    Dim parts, i, out
    parts = Split(Trim(CStr(fullName & "")), " ")
    out = ""
    For i = 0 To UBound(parts)
        If Len(parts(i)) > 0 And Len(out) < 2 Then out = out & UCase(Left(parts(i), 1))
    Next
    If out = "" Then out = "?"
    Initials = out
End Function

' ---------------------------------------------------------------------------
' 3. ICONOS (SVG inline, sin dependencias externas)
' ---------------------------------------------------------------------------
Function Icon(ByVal iconName)
    Dim s
    Select Case LCase(iconName)
        Case "play"
            s = "<svg viewBox='0 0 24 24' aria-hidden='true'><path d='M8 5.14v13.72c0 .8.87 1.3 1.56.9l11.1-6.86a1.05 1.05 0 0 0 0-1.8L9.56 4.24A1.05 1.05 0 0 0 8 5.14Z' fill='currentColor'/></svg>"
        Case "pause"
            s = "<svg viewBox='0 0 24 24' aria-hidden='true'><rect x='6.5' y='4.5' width='3.6' height='15' rx='1.2' fill='currentColor'/><rect x='13.9' y='4.5' width='3.6' height='15' rx='1.2' fill='currentColor'/></svg>"
        Case "prev"
            s = "<svg viewBox='0 0 24 24' aria-hidden='true'><rect x='5' y='5' width='2.2' height='14' rx='1' fill='currentColor'/><path d='M19 5.9v12.2c0 .9-1 1.4-1.7.9l-8.4-6.1a1.1 1.1 0 0 1 0-1.8l8.4-6.1c.7-.5 1.7 0 1.7.9Z' fill='currentColor'/></svg>"
        Case "next"
            s = "<svg viewBox='0 0 24 24' aria-hidden='true'><rect x='16.8' y='5' width='2.2' height='14' rx='1' fill='currentColor'/><path d='M5 5.9v12.2c0 .9 1 1.4 1.7.9l8.4-6.1a1.1 1.1 0 0 0 0-1.8L6.7 5c-.7-.5-1.7 0-1.7.9Z' fill='currentColor'/></svg>"
        Case "search"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' aria-hidden='true'><circle cx='11' cy='11' r='7'/><path d='m20 20-3.6-3.6'/></svg>"
        Case "plus"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.1' stroke-linecap='round' aria-hidden='true'><path d='M12 5v14M5 12h14'/></svg>"
        Case "edit"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='M12 20h9'/><path d='M16.5 3.5a2.12 2.12 0 0 1 3 3L7.5 18.5 3 20l1.5-4.5Z'/></svg>"
        Case "trash"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='M3.5 6.5h17'/><path d='M9.5 6.5V4.8c0-.7.6-1.3 1.3-1.3h2.4c.7 0 1.3.6 1.3 1.3v1.7'/><path d='M6 6.5 7 20a1.5 1.5 0 0 0 1.5 1.4h7A1.5 1.5 0 0 0 17 20l1-13.5'/></svg>"
        Case "close"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' aria-hidden='true'><path d='M6 6l12 12M18 6 6 18'/></svg>"
        Case "logout"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='M9.5 21H5.5A1.5 1.5 0 0 1 4 19.5v-15A1.5 1.5 0 0 1 5.5 3h4'/><path d='M16.5 16.5 21 12l-4.5-4.5'/><path d='M21 12H9.5'/></svg>"
        Case "help"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><circle cx='12' cy='12' r='9'/><path d='M9.2 9.2a2.9 2.9 0 1 1 4.3 2.6c-.9.6-1.5 1.1-1.5 2.2'/><path d='M12 17.2h.01'/></svg>"
        Case "volume"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='M11 5 6.5 8.8H3v6.4h3.5L11 19z'/><path d='M15.4 8.6a4.8 4.8 0 0 1 0 6.8'/><path d='M18.3 5.7a8.8 8.8 0 0 1 0 12.6'/></svg>"
        Case "mute"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='M11 5 6.5 8.8H3v6.4h3.5L11 19z'/><path d='m16 9.5 5 5M21 9.5l-5 5'/></svg>"
        Case "music"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='M9 18V5.5l11-2V16'/><circle cx='6' cy='18' r='3'/><circle cx='17' cy='16' r='3'/></svg>"
        Case "grid"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><rect x='3.5' y='3.5' width='7' height='7' rx='2'/><rect x='13.5' y='3.5' width='7' height='7' rx='2'/><rect x='3.5' y='13.5' width='7' height='7' rx='2'/><rect x='13.5' y='13.5' width='7' height='7' rx='2'/></svg>"
        Case "list"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' aria-hidden='true'><path d='M8 6h13M8 12h13M8 18h13M3.5 6h.01M3.5 12h.01M3.5 18h.01'/></svg>"
        Case "album"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8' stroke-linecap='round' aria-hidden='true'><circle cx='12' cy='12' r='9'/><circle cx='12' cy='12' r='2.6'/></svg>"
        Case "mic"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8' stroke-linecap='round' aria-hidden='true'><rect x='9' y='3' width='6' height='11' rx='3'/><path d='M5.5 11.5a6.5 6.5 0 0 0 13 0'/><path d='M12 18v3'/></svg>"
        Case "warning"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='M12 3.5 21 20H3z'/><path d='M12 9.5v4.5M12 17.3h.01'/></svg>"
        Case "lock"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><rect x='4.5' y='10.5' width='15' height='10' rx='2.4'/><path d='M8 10.5V7.6a4 4 0 0 1 8 0v2.9'/></svg>"
        Case "globe"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><circle cx='12' cy='12' r='9'/><path d='M3.2 9.5h17.6M3.2 14.5h17.6'/><path d='M12 3a15 15 0 0 1 0 18a15 15 0 0 1 0-18Z'/></svg>"
        Case "check"
            s = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='m5 12.5 4.5 4.5L19 7'/></svg>"
        Case Else
            s = ""
    End Select
    Icon = s
End Function

' ---------------------------------------------------------------------------
' 4. CONEXIÓN A BASE DE DATOS (ADO)
' ---------------------------------------------------------------------------
Function GetConnection()
    Dim cn, cn2
    Set cn = Nothing

    On Error Resume Next
    Set cn = Server.CreateObject("ADODB.Connection")
    cn.Open "Provider=MSOLEDBSQL;Server=" & DB_SERVER & ";Database=" & DB_NAME & _
            ";UID=" & DB_USER & ";PWD=" & DB_PASS & _
            ";Encrypt=Optional;TrustServerCertificate=Yes;"
    If Err.Number <> 0 Then
        Err.Clear
        If cn.State <> 0 Then cn.Close
        ' Compatibilidad con instalaciones sin el driver moderno
        Set cn2 = Server.CreateObject("ADODB.Connection")
        cn2.Open "Provider=SQLOLEDB;Data Source=" & DB_SERVER & ";Initial Catalog=" & DB_NAME & _
                 ";User ID=" & DB_USER & ";Password=" & DB_PASS & ";"
        If Err.Number <> 0 Then
            Err.Clear
            Set cn2 = Nothing
        End If
        Set cn = cn2
    End If
    On Error GoTo 0

    If Not (cn Is Nothing) Then
        If cn.State = 0 Then Set cn = Nothing
    End If
    Set GetConnection = cn
End Function

Function NewCmd(ByRef cn, ByVal sql)
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = cn
    cmd.CommandType = 1            ' adCmdText
    cmd.CommandText = sql
    cmd.CommandTimeout = 15
    Set NewCmd = cmd
End Function

' ---------------------------------------------------------------------------
' 5. SESIÓN Y ROLES
' ---------------------------------------------------------------------------
Dim sNombre, sRol, boolAdmin, strAdmin, sAvatar, sIniciales
Dim archivoActual, destinoLogin

' Nombre del archivo que se esta ejecutando (canciones.asp, playlists.asp...).
' Lo usan el menu lateral y la cabecera para marcar la seccion activa.
archivoActual = LCase(CStr(Request.ServerVariables("SCRIPT_NAME") & ""))
archivoActual = Mid(archivoActual, InStrRev(archivoActual, "/") + 1)

sNombre = Trim(CStr(Session("nombreUsuario") & ""))
sRol    = Trim(CStr(Session("rolUsuario") & ""))

If sNombre = "" Then
    ' Devuelve al usuario a la pagina que intentaba abrir (lista blanca)
    destinoLogin = archivoActual
    If destinoLogin <> "canciones.asp" And destinoLogin <> "playlists.asp" Then
        destinoLogin = "canciones.asp"
    End If
    Response.Redirect LOGIN_PAGE & "?next=" & Server.URLEncode(destinoLogin)
    Response.End
End If

Function EsAdmin()
    Dim r, t
    r = LCase(Trim(CStr(Session("rolUsuario") & "")))
    t = LCase(Trim(CStr(Session("tipoUsuario") & "")))
    EsAdmin = (r = "useradmin") Or (r = "admin") Or (r = "administrador") Or _
              (r = "1") Or (t = "1") Or (t = "admin")
End Function

boolAdmin = EsAdmin()
If boolAdmin Then strAdmin = "true" Else strAdmin = "false"

' Avatar del usuario: foto de BD si existe, si no, monograma
sAvatar = ""
If Trim(CStr(Session("fotoUsuario") & "")) <> "" Then
    If AssetExists(AssetUrl(Session("fotoUsuario"))) Then
        sAvatar = AssetUrl(Session("fotoUsuario"))
    End If
End If
sIniciales = Initials(sNombre)


%>
