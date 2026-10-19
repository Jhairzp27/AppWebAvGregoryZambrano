<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="dark">
<meta name="description" content="PoliMusic · biblioteca musical">
<title><% If archivoActual = "playlists.asp" Then %>Playlists<% Else %>Song List<% End If %> · <%= H(APP_NAME) %></title>
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Ccircle cx='16' cy='16' r='16' fill='%23FF6A00'/%3E%3Cpath d='M13 22V11l9-1.6V20' stroke='%23fff' stroke-width='2' fill='none' stroke-linecap='round'/%3E%3Ccircle cx='11' cy='22' r='2.4' fill='%23fff'/%3E%3Ccircle cx='20' cy='20' r='2.4' fill='%23fff'/%3E%3C/svg%3E">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">

<!-- Hojas de estilo del proyecto (el ?v= fuerza la recarga al desplegar cambios) -->
<link rel="stylesheet" href="assets/css/estilos.css?v=<%= ASSET_VERSION %>">
<link rel="stylesheet" href="assets/css/canciones.css?v=<%= ASSET_VERSION %>">
<% If archivoActual = "playlists.asp" Then %>
<link rel="stylesheet" href="assets/css/playlists.css?v=<%= ASSET_VERSION %>">
<% End If %>
<link rel="stylesheet" href="assets/css/responsive.css?v=<%= ASSET_VERSION %>">
</head>
