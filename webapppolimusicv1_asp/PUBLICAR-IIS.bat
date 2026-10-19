@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title PoliMusic - Publicar en IIS

rem =====================================================================
rem  Publica los archivos de PoliMusic en el sitio de IIS.
rem  Doble clic y acepta el aviso de permisos de Windows (UAC).
rem  Se puede ejecutar tantas veces como sea necesario.
rem =====================================================================

net session >nul 2>&1
if not %errorlevel%==0 (
    echo Solicitando permisos de administrador...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "SRC=%~dp0"
set "DST=C:\inetpub\wwwroot\webapppolimusicv1_asp"

if not exist "%DST%" mkdir "%DST%"

echo.
echo  Copiando archivos ASP...
copy /Y "%SRC%canciones.asp" "%DST%\canciones.asp" >nul
copy /Y "%SRC%playlists.asp" "%DST%\playlists.asp" >nul
copy /Y "%SRC%login.asp"     "%DST%\login.asp"     >nul
copy /Y "%SRC%Default.asp"   "%DST%\Default.asp"   >nul

echo  Sincronizando assets (CSS, JS e includes)...
robocopy "%SRC%assets" "%DST%assets" /E /NFL /NDL /NJH /NJS /NP >nul

rem Limpieza: versiones anteriores dejaban css\, js\ e includes\ sueltos en la raiz.
rem Si quedan, la pagina puede mezclar archivos viejos con los nuevos.
for %%D in (css js includes) do (
    if exist "%DST%\%%D" (
        echo  Quitando carpeta obsoleta: %%D\
        rd /S /Q "%DST%\%%D" >nul 2>&1
    )
)

echo  Sincronizando recursos (audio e imagenes)...
robocopy "%SRC%SongFilesAndImages_resources" "%DST%SongFilesAndImages_resources" /E /NFL /NDL /NJH /NJS /NP >nul

echo  Asegurando permisos de lectura para IIS...
icacls "%DST%" /grant "IIS_IUSRS:(OI)(CI)(RX)" /T /Q >nul 2>&1

echo  Permitiendo que tu usuario publique sin pedir UAC otra vez...
icacls "%DST%" /grant "%USERNAME%:(OI)(CI)M" /T /Q >nul 2>&1

echo  Registrando Default.asp como documento predeterminado...
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site/webapppolimusicv1_asp" -section:system.webServer/defaultDocument /+"files.[value='Default.asp']" /commit:apphost >nul 2>&1

echo.
echo  Listo. Verificando archivos...
echo.
for %%F in (canciones.asp playlists.asp login.asp Default.asp) do (
    if exist "%DST%\%%F" (echo   [OK] %%F) else (echo   [FALTA] %%F)
)
for %%D in (assets) do (
    if exist "%DST%\%%D" (echo   [OK] %%D\) else (echo   [FALTA] %%D\)
)
for %%D in (assets\css assets\js assets\includes) do (
    if exist "%DST%\%%D" (echo   [OK] %%D\) else (echo   [FALTA] %%D\)
)
if exist "%DST%\SongFilesAndImages_resources\SongFiles" (
    echo   [OK] SongFilesAndImages_resources
) else (
    echo   [FALTA] SongFilesAndImages_resources
)

echo.
echo  Abre en el navegador:  http://localhost/webapppolimusicv1_asp/
echo  Usuarios:  userAdmin / 12345678   (Administrador)
echo             userNormal / 12345678  (Usuario)
echo.
pause
