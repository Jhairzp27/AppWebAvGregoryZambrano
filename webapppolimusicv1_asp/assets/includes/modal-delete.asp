<!-- ==================== MODAL: ELIMINAR ==================== -->
<div class="modal" id="modalDelete" role="dialog" aria-modal="true" aria-labelledby="modalDeleteTitle">
  <div class="modal-backdrop" data-close></div>
  <div class="modal-card" style="max-width:440px">
    <div class="modal-head">
      <span class="modal-icon danger"><%= Icon("trash") %></span>
      <div>
        <h3 id="modalDeleteTitle">Eliminar canción</h3>
        <p>Esta acción no se puede deshacer.</p>
      </div>
      <button class="btn-icon" type="button" data-close aria-label="Cerrar"><%= Icon("close") %></button>
    </div>

    <p style="font-size:13.5px;color:var(--muted);line-height:1.6">
      Vas a eliminar <strong id="deleteName" style="color:var(--text)">esta canción</strong> del catálogo.
      También se quitará de los álbumes y playlists donde aparezca.
    </p>

    <form method="post" action="canciones.asp" id="deleteForm">
      <input type="hidden" name="csrf" value="<%= H(Session("pm_csrf")) %>">
      <input type="hidden" name="accion" value="eliminar">
      <input type="hidden" name="id" id="deleteId" value="0">
      <div class="modal-foot">
        <button class="btn btn-ghost" type="button" data-close>Cancelar</button>
        <button class="btn btn-danger" type="submit"><%= Icon("trash") %><span>Sí, eliminar</span></button>
      </div>
    </form>
  </div>
</div>
