  <!-- ==================== SIDEBAR ==================== -->
  <aside class="sidebar" id="sidebar" aria-label="Navegación principal">
    <div class="brand">
      <span class="brand-mark"><%= Icon("music") %></span>
      <span class="brand-text">
        <span class="brand-name">PoliMusic</span>
        <span class="brand-sub">Streaming</span>
      </span>
    </div>

    <nav class="nav-group" aria-label="Secciones">
      <span class="nav-label">Explorar</span>
      <a class="nav-item is-soon" href="#" data-soon="Inicio" aria-disabled="true">
        <%= Icon("grid") %><span>Inicio</span>
      </a>
      <a class="nav-item<% If archivoActual = "canciones.asp" Then %> is-active<% End If %>"
         href="canciones.asp"<% If archivoActual = "canciones.asp" Then %> aria-current="page"<% End If %>>
        <%= Icon("list") %><span>Canciones</span>
      </a>
      <a class="nav-item<% If archivoActual = "playlists.asp" Then %> is-active<% End If %>"
         href="playlists.asp"<% If archivoActual = "playlists.asp" Then %> aria-current="page"<% End If %>>
        <%= Icon("album") %><span>Playlists</span>
      </a>
      <a class="nav-item is-soon" href="#" data-soon="Artistas" aria-disabled="true">
        <%= Icon("mic") %><span>Artistas</span><span class="nav-tag">Pronto</span>
      </a>
    </nav>

    <div class="sidebar-foot">
      <div class="side-card">
        <h4>Atajos rápidos</h4>
        <p>Encuentra una canción sin soltar el teclado.</p>
        <div class="side-hint"><kbd>/</kbd> buscar · <kbd>Espacio</kbd> reproducir</div>
      </div>
      <button class="nav-item" type="button" id="btnHelpSide" style="width:100%">
        <%= Icon("help") %><span>Ayuda y atajos</span>
      </button>
    </div>
  </aside>
  <div class="sidebar-scrim" id="scrim" hidden></div>
