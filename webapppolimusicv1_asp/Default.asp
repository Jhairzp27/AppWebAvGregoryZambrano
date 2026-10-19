<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' ============================================================================
'  PoliMusic · Default.asp
'  Documento predeterminado del sitio: envía al usuario al catálogo si ya
'  tiene sesión activa, o al login en caso contrario.
' ============================================================================
Response.Buffer   = True
Response.CodePage = 65001
Response.Charset  = "UTF-8"
Response.CacheControl = "no-cache"

If Trim(CStr(Session("nombreUsuario") & "")) <> "" Then
    Response.Redirect "canciones.asp"
Else
    Response.Redirect "login.asp"
End If
Response.End
%>
