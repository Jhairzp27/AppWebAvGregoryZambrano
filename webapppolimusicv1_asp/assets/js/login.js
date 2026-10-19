(function () {
  var btn = document.getElementById('btnVer');
  var clave = document.getElementById('clave');
  if (btn && clave) {
    btn.addEventListener('click', function () {
      var ver = clave.type === 'password';
      clave.type = ver ? 'text' : 'password';
      btn.setAttribute('aria-label', ver ? 'Ocultar contraseña' : 'Mostrar contraseña');
      clave.focus();
    });
  }
  document.querySelectorAll('.chip').forEach(function (chip) {
    chip.addEventListener('click', function () {
      document.getElementById('usuario').value = chip.dataset.user;
      document.getElementById('clave').value = chip.dataset.pass;
      document.getElementById('clave').focus();
    });
  });
  var u = document.getElementById('usuario');
  if (u && !u.value) u.focus();
})();
