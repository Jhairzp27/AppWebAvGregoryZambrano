    <header class="topbar">
      <div class="topbar-left">
        <button class="btn-icon menu-btn" type="button" id="btnMenu" aria-label="Abrir menú" aria-expanded="false" aria-controls="sidebar">
          <%= Icon("list") %>
        </button>
        <div class="crumbs">
          <span>Biblioteca</span><span class="sep">/</span><strong><% If archivoActual = "playlists.asp" Then %>Playlists<% Else %>Canciones<% End If %></strong>
        </div>
      </div>

      <div class="topbar-right">
        <button class="btn-icon" type="button" id="btnHelp" aria-label="Abrir ayuda" title="Ayuda y atajos">
          <%= Icon("help") %>
        </button>

        <div class="user-chip" title="<%= H(sNombre) %> · <%= H(sRol) %>">
          <span class="avatar">
            <% If sAvatar <> "" Then %>
              <img src="<%= H(sAvatar) %>" alt="">
            <% Else %>
              <%= H(sIniciales) %>
            <% End If %>
          </span>
          <span class="user-meta">
            <span class="user-name">Bienvenido, <%= H(sNombre) %></span>
            <span class="user-role"><% If boolAdmin Then %>Administrador<% Else %>Usuario<% End If %></span>
          </span>
        </div>

        <a class="btn btn-ghost" href="canciones.asp?action=logout" id="btnLogout">
          <%= Icon("logout") %><span>Cerrar sesión</span>
        </a>
      </div>
    </header>
