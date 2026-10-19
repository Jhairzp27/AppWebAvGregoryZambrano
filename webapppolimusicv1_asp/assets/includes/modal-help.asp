<!-- ==================== MODAL: AYUDA ==================== -->
<div class="modal" id="modalHelp" role="dialog" aria-modal="true" aria-labelledby="modalHelpTitle">
  <div class="modal-backdrop" data-close></div>
  <div class="modal-card">
    <div class="modal-head">
      <span class="modal-icon"><%= Icon("help") %></span>
      <div>
        <h3 id="modalHelpTitle">Ayuda y atajos</h3>
        <p>Todo lo que necesitas para moverte por PoliMusic.</p>
      </div>
      <button class="btn-icon" type="button" data-close aria-label="Cerrar"><%= Icon("close") %></button>
    </div>

    <div class="help-list">
      <div class="help-item">
        <span class="k"><kbd>/</kbd></span>
        <span class="d">Enfoca el <b>buscador</b> desde cualquier parte de la página.</span>
      </div>
      <div class="help-item">
        <span class="k"><kbd>Espacio</kbd></span>
        <span class="d"><b>Reproduce o pausa</b> la canción actual.</span>
      </div>
      <div class="help-item">
        <span class="k"><kbd>Esc</kbd></span>
        <span class="d">Cierra la ventana o el cuadro de diálogo abierto.</span>
      </div>
      <div class="help-sep"></div>
      <div class="help-item">
        <span class="k" style="color:var(--brand-soft);font-size:11px;font-weight:700;letter-spacing:.06em">USUARIO</span>
        <span class="d">Puede <b>ver el listado</b> y <b>reproducir</b> cualquier canción.</span>
      </div>
      <div class="help-item">
        <span class="k" style="color:var(--brand-soft);font-size:11px;font-weight:700;letter-spacing:.06em">ADMIN</span>
        <span class="d">Además puede <b>crear</b>, <b>editar</b> y <b>eliminar</b> canciones del catálogo.</span>
      </div>
      <div class="help-sep"></div>
      <div class="help-item">
        <span class="k" style="color:var(--warn);font-size:11px;font-weight:700;letter-spacing:.06em">AVISO</span>
        <span class="d">Si una canción muestra <b>“Sin audio”</b>, el archivo no está en
          <b>SongFilesAndImages_resources/SongFiles</b>.</span>
      </div>
    </div>

    <div class="modal-foot">
      <button class="btn btn-primary" type="button" data-close>Entendido</button>
    </div>
  </div>
</div>
