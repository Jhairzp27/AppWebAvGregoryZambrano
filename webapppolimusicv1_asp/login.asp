<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' ============================================================================
'  PoliMusic · login.asp
'  Autenticación contra TBL_USER y creación de las variables de sesión que
'  consume canciones.asp:
'     Session("idUsuario")     -> ID_USER
'     Session("nombreUsuario") -> USERNAME
'     Session("rolUsuario")    -> "userAdmin" (Administrador) | "epn.fis" (Normal)
'     Session("tipoUsuario")   -> USER_TYPE (1 = admin, 0 = usuario)
'     Session("fotoUsuario")   -> USER_PHOTO
' ============================================================================

Response.Buffer   = True
Response.CodePage = 65001
Response.Charset  = "UTF-8"
Response.CacheControl = "no-cache"
Session.CodePage  = 65001

Const DB_SERVER = "localhost"
Const DB_NAME   = "BDD_PoliMusic"
Const DB_USER   = "usr_polimusic"
Const DB_PASS   = "Politecnica1"

' Version de assets: cambiala (1 -> 2 -> 3...) al desplegar cambios de CSS/JS
' para que el navegador no sirva la copia cacheada.
Const ASSET_VERSION = "1"

' ---------------------------------------------------------------------------
' Helpers
' ---------------------------------------------------------------------------
Function H(ByVal value)
    H = Server.HTMLEncode(CStr(value & ""))
End Function

Function GetConnection()
    Dim cn, cn2
    Set cn = Nothing
    On Error Resume Next
    Set cn = Server.CreateObject("ADODB.Connection")
    cn.Open "Provider=MSOLEDBSQL;Server=" & DB_SERVER & ";Database=" & DB_NAME & _
            ";UID=" & DB_USER & ";PWD=" & DB_PASS & ";Encrypt=Optional;TrustServerCertificate=Yes;"
    If Err.Number <> 0 Then
        Err.Clear
        If cn.State <> 0 Then cn.Close
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

' ---------------------------------------------------------------------------
' Si ya hay sesión activa, no tiene sentido volver al login
' ---------------------------------------------------------------------------
If Trim(CStr(Session("nombreUsuario") & "")) <> "" Then
    Response.Redirect "canciones.asp"
    Response.End
End If

' ---------------------------------------------------------------------------
' Procesar credenciales
' ---------------------------------------------------------------------------
Dim txtUsuario, txtClave, errorMsg, okLogin, irA

txtUsuario = ""
txtClave   = ""
errorMsg   = ""
okLogin    = False

irA = LCase(Trim(CStr(Request.QueryString("next") & "")))
' Lista blanca: solo se permite volver a paginas conocidas del proyecto
If irA <> "canciones.asp" And irA <> "playlists.asp" Then irA = "canciones.asp"

If UCase(Trim(CStr(Request.ServerVariables("REQUEST_METHOD") & ""))) = "POST" Then
    Dim cn, cmd, rs, sql, idUser, userType, userPhoto

    txtUsuario = Trim(CStr(Request.Form("usuario") & ""))
    txtClave   = CStr(Request.Form("clave") & "")

    If Len(txtUsuario) = 0 Or Len(txtClave) = 0 Then
        errorMsg = "Escribe tu usuario y tu contraseña para continuar."
    Else
        Set cn = GetConnection()
        If cn Is Nothing Then
            errorMsg = "No pudimos conectar con la base de datos. Verifica que SQL Server esté en ejecución."
        Else
            On Error Resume Next
            ' Acepta contraseñas en texto plano y contraseñas guardadas como SHA1
            sql = "SELECT TOP 1 ID_USER, USERNAME, USER_TYPE, USER_PHOTO FROM TBL_USER " & _
                  "WHERE USERNAME = ? AND (PASSWORD = ? OR PASSWORD = UPPER(CONVERT(varchar(40), HASHBYTES('SHA1', ?), 2)))"

            Set cmd = Server.CreateObject("ADODB.Command")
            Set cmd.ActiveConnection = cn
            cmd.CommandType = 1
            cmd.CommandText = sql
            cmd.CommandTimeout = 15
            cmd.Parameters.Append cmd.CreateParameter("@usuario", 200, 1, 50, txtUsuario)
            cmd.Parameters.Append cmd.CreateParameter("@clave", 200, 1, 50, txtClave)
            cmd.Parameters.Append cmd.CreateParameter("@hash", 200, 1, 50, txtClave)

            Set rs = cmd.Execute
            If Err.Number <> 0 Then
                Err.Clear
                errorMsg = "Ocurrió un error al validar tus credenciales. Inténtalo de nuevo."
            Else
                If rs.EOF Then
                    errorMsg = "Usuario o contraseña incorrectos. Revisa los datos e inténtalo otra vez."
                Else
                    idUser    = rs("ID_USER")
                    userType  = rs("USER_TYPE")
                    userPhoto = CStr(rs("USER_PHOTO") & "")

                    Session("idUsuario")     = idUser
                    Session("nombreUsuario") = CStr(rs("USERNAME") & "")
                    Session("tipoUsuario")   = userType
                    Session("fotoUsuario")   = userPhoto
                    If CLng(userType) = 1 Then
                        Session("rolUsuario") = "userAdmin"
                    Else
                        Session("rolUsuario") = "epn.fis"
                    End If
                    okLogin = True
                End If
                rs.Close
            End If
            On Error GoTo 0
            cn.Close
        End If
    End If

    If okLogin Then
        Response.Redirect irA
        Response.End
    End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="dark">
<title>Iniciar sesión · PoliMusic</title>
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Ccircle cx='16' cy='16' r='16' fill='%23FF6A00'/%3E%3Cpath d='M13 22V11l9-1.6V20' stroke='%23fff' stroke-width='2' fill='none' stroke-linecap='round'/%3E%3Ccircle cx='11' cy='22' r='2.4' fill='%23fff'/%3E%3Ccircle cx='20' cy='20' r='2.4' fill='%23fff'/%3E%3C/svg%3E">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="assets/css/login.css?v=<%= ASSET_VERSION %>">
</head>
<body>
<main class="shell">
  <section class="brand-panel">
    <div class="brand">
      <span class="brand-mark">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="M9 18V5.5l11-2V16"/><circle cx="6" cy="18" r="3"/><circle cx="17" cy="16" r="3"/>
        </svg>
      </span>
      <span>
        <span class="brand-name">PoliMusic</span>
        <span class="brand-sub">Streaming</span>
      </span>
    </div>

    <div class="pitch">
      <h1>Toda tu música,<br><em>en un solo lugar.</em></h1>
      <p>Accede a tu catálogo, reproduce tus canciones favoritas y administra la biblioteca de PoliMusic.</p>
      <ul class="bullets">
        <li>
          <span class="dot"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7"/></svg></span>
          Catálogo completo con reproductor integrado
        </li>
        <li>
          <span class="dot"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7"/></svg></span>
          Roles de administrador y usuario
        </li>
        <li>
          <span class="dot"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7"/></svg></span>
          Diseño adaptable a cualquier pantalla
        </li>
      </ul>
    </div>
  </section>

  <section class="form-panel">
    <div class="form-head">
      <h2>Iniciar sesión</h2>
      <p>Usa tus credenciales de PoliMusic para continuar.</p>
    </div>

    <% If errorMsg <> "" Then %>
    <div class="alert" role="alert">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
        <path d="M12 3.5 21 20H3z"/><path d="M12 9.5v4.5M12 17.3h.01"/>
      </svg>
      <span><%= H(errorMsg) %></span>
    </div>
    <% End If %>

    <form method="post" action="login.asp?next=<%= H(irA) %>" autocomplete="on" novalidate>
      <div class="field">
        <label for="usuario">Usuario</label>
        <div class="wrap">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <circle cx="12" cy="8" r="3.6"/><path d="M4.5 20a7.5 7.5 0 0 1 15 0"/>
          </svg>
          <input type="text" id="usuario" name="usuario" maxlength="50" required
                 placeholder="userAdmin" value="<%= H(txtUsuario) %>" autocomplete="username">
        </div>
      </div>

      <div class="field">
        <label for="clave">Contraseña</label>
        <div class="wrap">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <rect x="4.5" y="10.5" width="15" height="9.5" rx="2.4"/><path d="M8 10.5V7.8a4 4 0 0 1 8 0v2.7"/>
          </svg>
          <input type="password" id="clave" name="clave" maxlength="50" required
                 placeholder="••••••••" autocomplete="current-password">
          <button class="toggle" type="button" id="btnVer" aria-label="Mostrar contraseña" title="Mostrar contraseña">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12Z"/><circle cx="12" cy="12" r="3"/>
            </svg>
          </button>
        </div>
      </div>

      <button class="btn" type="submit">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="M9.5 21H5.5A1.5 1.5 0 0 1 4 19.5v-15A1.5 1.5 0 0 1 5.5 3h4"/><path d="M16.5 16.5 21 12l-4.5-4.5"/><path d="M21 12H9.5"/>
        </svg>
        Entrar
      </button>
    </form>

    <div class="hint">
      <p>Usuarios de prueba</p>
      <div class="chips">
        <button class="chip" type="button" data-user="userAdmin" data-pass="12345678">
          <b>userAdmin</b><span class="role">Admin</span>
        </button>
        <button class="chip" type="button" data-user="userNormal" data-pass="12345678">
          <b>userNormal</b><span class="role">Usuario</span>
        </button>
      </div>
    </div>

    <p class="foot-note">PoliMusic · ASP Clásico + SQL Server</p>
  </section>
</main>

<script src="assets/js/login.js"></script>
</body>
</html>
