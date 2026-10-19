<!-- ==================== MODAL: CREAR / EDITAR ==================== -->
<div class="modal" id="modalForm" role="dialog" aria-modal="true" aria-labelledby="modalFormTitle">
  <div class="modal-backdrop" data-close></div>
  <div class="modal-card">
    <div class="modal-head">
      <span class="modal-icon"><%= Icon("music") %></span>
      <div>
        <h3 id="modalFormTitle">Nueva canción</h3>
        <p id="modalFormSub">Agrega una canción al catálogo de PoliMusic.</p>
      </div>
      <button class="btn-icon" type="button" data-close aria-label="Cerrar"><%= Icon("close") %></button>
    </div>

    <% If gFormError <> "" And gFormMode <> "eliminar" Then %>
    <div class="form-alert" role="alert">
      <%= Icon("warning") %><span><%= H(gFormError) %></span>
    </div>
    <% End If %>

    <form method="post" action="canciones.asp" id="songForm" novalidate>
      <input type="hidden" name="csrf" value="<%= H(Session("pm_csrf")) %>">
      <input type="hidden" name="accion" id="formAccion" value="<% If gFormMode = "editar" Then %>actualizar<% Else %>crear<% End If %>">
      <input type="hidden" name="id" id="formId" value="<%= gFormId %>">

      <div class="field">
        <label for="inputNombre">
          <span>Nombre de la canción <span class="req">*</span></span>
          <span class="hint"><span id="nameCount">0</span>/50</span>
        </label>
        <input type="text" id="inputNombre" name="nombre" maxlength="50" required
               placeholder="Ej. Adventure" value="<%= H(gFormNombre) %>" autocomplete="off">
        <p class="field-error" id="errorNombre"></p>
      </div>

      <div class="field">
        <label for="inputRuta">
          <span>Ruta del archivo <span class="req">*</span></span>
          <span class="hint">Carpeta SongFiles</span>
        </label>
        <input type="text" id="inputRuta" name="ruta" maxlength="255" required list="listaArchivos"
               placeholder="~/songFiles/bensound-adventure.mp3" value="<%= H(gFormRuta) %>" autocomplete="off">
        <datalist id="listaArchivos"><%= archivosDisponibles %></datalist>
        <p class="field-error" id="errorRuta"></p>
      </div>

      <div class="modal-foot">
        <button class="btn btn-ghost" type="button" data-close>Cancelar</button>
        <button class="btn btn-primary" type="submit" id="btnSubmit">
          <%= Icon("check") %><span id="btnSubmitText">Guardar canción</span>
        </button>
      </div>
    </form>
  </div>
</div>
