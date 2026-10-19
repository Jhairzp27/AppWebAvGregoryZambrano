/* ============================================================================
   PoliMusic · js/canciones.js — capa de interacción de la página de canciones
   Motor de animación: mismos principios que Framer Motion (springs + stagger)
   implementados sobre Web Animations API, sin dependencias externas.

   El servidor inyecta el estado inicial en window.PM (script inline previo).
   Este archivo no contiene ASP: es JS puro y cacheable por el navegador.
   ============================================================================ */
(function () {
  'use strict';

  var PM = window.PM || {};
  var $  = function (sel, ctx) { return (ctx || document).querySelector(sel); };
  var $$ = function (sel, ctx) { return Array.prototype.slice.call((ctx || document).querySelectorAll(sel)); };
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var SPRING = 'cubic-bezier(.34,1.32,.64,1)';

  /* -------------------- Motor de motion -------------------- */
  var Motion = {
    animate: function (el, frames, opts) {
      if (!el) return;
      if (reduceMotion) {
        var last = frames[frames.length - 1];
        Object.keys(last).forEach(function (k) { el.style[k] = last[k]; });
        return;
      }
      var o = Object.assign({ duration: 480, easing: SPRING, fill: 'both' }, opts || {});
      if (el.animate) { try { return el.animate(frames, o); } catch (e) { return null; } }
      return null;
    },
    stagger: function (els, frames, base) {
      els.forEach(function (el, i) {
        var o = Object.assign({}, base || {}, { delay: (base && base.delay ? base.delay : 0) + i * 45 });
        Motion.animate(el, frames, o);
      });
    }
  };

  /* -------------------- Toasts -------------------- */
  var ICONS = {
    success: "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.4' stroke-linecap='round' stroke-linejoin='round'><path d='m5 12.5 4.5 4.5L19 7'/></svg>",
    error:   "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.2' stroke-linecap='round'><path d='M12 7v7M12 17.5h.01'/></svg>",
    info:    "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round'><path d='M12 10v7M12 6.5h.01'/></svg>"
  };

  function toast(type, title, msg, ms) {
    var wrap = $('#toasts');
    if (!wrap) return;
    var el = document.createElement('div');
    el.className = 'toast ' + type;
    el.setAttribute('role', type === 'error' ? 'alert' : 'status');
    el.innerHTML =
      '<span class="t-icon">' + (ICONS[type] || ICONS.info) + '</span>' +
      '<span class="t-body"><span class="t-title"></span><span class="t-msg"></span></span>';
    el.querySelector('.t-title').textContent = title;
    if (msg) el.querySelector('.t-msg').textContent = msg;
    wrap.appendChild(el);

    Motion.animate(el, [
      { opacity: 0, transform: 'translateY(14px) scale(.96)' },
      { opacity: 1, transform: 'translateY(0) scale(1)' }
    ], { duration: 380 });

    setTimeout(function () {
      var out = Motion.animate(el, [
        { opacity: 1, transform: 'translateY(0)' },
        { opacity: 0, transform: 'translateY(-8px)' }
      ], { duration: 260 });
      if (out) { out.onfinish = function () { el.remove(); }; }
      else { el.remove(); }
    }, ms || 4200);
  }

  /* -------------------- Modales -------------------- */
  var lastFocused = null;

  function openModal(id) {
    var m = document.getElementById(id);
    if (!m) return;
    lastFocused = document.activeElement;
    m.classList.add('is-open');
    document.body.style.overflow = 'hidden';

    /* La transición de apertura la resuelve el CSS (más fluida y sin conflicto) */
    var focusable = m.querySelector('input:not([type=hidden])') || m.querySelector('button');
    setTimeout(function () { if (focusable) focusable.focus(); }, 80);
  }

  function closeModal(m) {
    if (!m || !m.classList.contains('is-open')) return;
    m.classList.remove('is-open');
    document.body.style.overflow = '';
    if (lastFocused && lastFocused.focus) lastFocused.focus();
  }

  document.addEventListener('click', function (e) {
    var closer = e.target.closest('[data-close]');
    if (closer) {
      var modal = closer.closest('.modal');
      closeModal(modal);
    }
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      var open = $('.modal.is-open');
      if (open) { closeModal(open); return; }
    }
    if (e.key === '/' && !/^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement.tagName)) {
      e.preventDefault();
      var s = $('#searchInput');
      if (s) s.focus();
    }
    if (e.code === 'Space' && !/^(INPUT|TEXTAREA|SELECT|BUTTON|A)$/.test(document.activeElement.tagName)) {
      e.preventDefault();
      togglePlay();
    }
  });

  /* -------------------- Tabla: filas y búsqueda -------------------- */
  var rows = $$('.song-row');
  var searchInput = $('#searchInput');
  var countChip = $('#countChip');
  var noResults = $('#noResults');
  var noResultsText = $('#noResultsText');
  var total = rows.length;
  var filterTimer = null;

  function applyFilter(raw) {
    var q = (raw || '').trim().toLowerCase();
    var visible = 0;

    rows.forEach(function (row) {
      var hay = ((row.dataset.name || '') + ' ' + (row.dataset.artists || '') + ' ' + (row.dataset.album || '')).toLowerCase();
      var match = q === '' || hay.indexOf(q) !== -1;
      row.classList.toggle('is-hidden', !match);
      if (match) visible++;
    });

    if (countChip) {
      countChip.textContent = q === ''
        ? total + ' en total'
        : visible + ' de ' + total;
    }

    if (noResults) {
      noResults.hidden = visible !== 0;
      if (visible === 0 && noResultsText) {
        noResultsText.textContent = 'No encontramos canciones que coincidan con “' + raw.trim() + '”.';
      }
    }

    var shown = rows.filter(function (r) { return !r.classList.contains('is-hidden'); });
    Motion.stagger(shown, [
      { opacity: 0, transform: 'translateY(8px)' },
      { opacity: 1, transform: 'translateY(0)' }
    ], { duration: 320 });
  }

  if (searchInput) {
    searchInput.addEventListener('input', function () {
      clearTimeout(filterTimer);
      var value = this.value;
      filterTimer = setTimeout(function () { applyFilter(value); }, 130);
    });
  }

  var btnClear = $('#btnClearSearch');
  if (btnClear) {
    btnClear.addEventListener('click', function () {
      if (searchInput) { searchInput.value = ''; searchInput.focus(); }
      applyFilter('');
    });
  }

  /* -------------------- Reproductor -------------------- */
  var audio = $('#pmAudio');
  var tracks = rows.map(function (row) {
    return {
      row: row,
      id: row.dataset.id,
      name: row.dataset.name,
      artists: row.dataset.artists,
      album: row.dataset.album,
      src: row.dataset.src,
      available: row.dataset.available === '1',
      plays: parseInt(row.dataset.plays, 10) || 0,
      letter: row.dataset.letter || '♪',
      c1: row.dataset.c1,
      c2: row.dataset.c2
    };
  });

  var current = -1;
  var counted = {};

  var playerCover = $('#playerCover');
  var playerTitle = $('#playerTitle');
  var playerArtist = $('#playerArtist');
  var btnPlayPause = $('#btnPlayPause');
  var seek = $('#seek');
  var volume = $('#volume');
  var timeCurrent = $('#timeCurrent');
  var timeTotal = $('#timeTotal');
  var btnMute = $('#btnMute');

  var PLAY_SVG = "<svg viewBox='0 0 24 24' aria-hidden='true'><path d='M8 5.14v13.72c0 .8.87 1.3 1.56.9l11.1-6.86a1.05 1.05 0 0 0 0-1.8L9.56 4.24A1.05 1.05 0 0 0 8 5.14Z' fill='currentColor'/></svg>";
  var PAUSE_SVG = "<svg viewBox='0 0 24 24' aria-hidden='true'><rect x='6.5' y='4.5' width='3.6' height='15' rx='1.2' fill='currentColor'/><rect x='13.9' y='4.5' width='3.6' height='15' rx='1.2' fill='currentColor'/></svg>";
  var VOL_SVG = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round'><path d='M11 5 6.5 8.8H3v6.4h3.5L11 19z'/><path d='M15.4 8.6a4.8 4.8 0 0 1 0 6.8'/><path d='M18.3 5.7a8.8 8.8 0 0 1 0 12.6'/></svg>";
  var MUTE_SVG = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round'><path d='M11 5 6.5 8.8H3v6.4h3.5L11 19z'/><path d='m16 9.5 5 5M21 9.5l-5 5'/></svg>";

  function fmtTime(s) {
    if (!isFinite(s) || s < 0) s = 0;
    var m = Math.floor(s / 60);
    var sec = Math.floor(s % 60);
    return m + ':' + (sec < 10 ? '0' : '') + sec;
  }

  function setPlayingUI(on) {
    if (btnPlayPause) {
      btnPlayPause.innerHTML = on ? PAUSE_SVG : PLAY_SVG;
      btnPlayPause.setAttribute('aria-label', on ? 'Pausar' : 'Reproducir');
    }
    tracks.forEach(function (t, i) {
      t.row.classList.toggle('is-playing', i === current);
      t.row.classList.toggle('is-paused', i === current && !on);
    });
  }

  function loadTrack(index, autoplay) {
    var t = tracks[index];
    if (!t) return;

    if (!t.available) {
      toast('error', 'Audio no disponible', 'El archivo “' + t.src + '” no está en la carpeta SongFiles.');
      return;
    }

    current = index;
    if (audio) audio.src = t.src;

    if (playerTitle) playerTitle.textContent = t.name;
    if (playerArtist) playerArtist.textContent = t.artists + (t.album ? ' · ' + t.album : '');
    if (playerCover) {
      playerCover.textContent = t.letter;
      playerCover.style.setProperty('--c1', t.c1 || '#FF9A3C');
      playerCover.style.setProperty('--c2', t.c2 || '#E23E00');
    }
    if (seek) { seek.value = 0; seek.style.setProperty('--p', 0); }
    if (timeCurrent) timeCurrent.textContent = '0:00';
    if (timeTotal) timeTotal.textContent = '0:00';

    tracks.forEach(function (x) { x.row.classList.remove('is-playing'); });
    t.row.classList.add('is-playing');

    Motion.animate(playerCover, [
      { transform: 'scale(.86)', opacity: .6 },
      { transform: 'scale(1)', opacity: 1 }
    ], { duration: 420 });

    if (autoplay) playAudio();
    if (!counted[t.id]) {
      counted[t.id] = true;
      registerPlay(t);
    }
  }

  function playAudio() {
    if (!audio || current < 0) {
      var first = tracks.findIndex(function (t) { return t.available; });
      if (first === -1) {
        toast('error', 'Sin audio disponible', 'Agrega archivos .mp3 a la carpeta SongFiles para poder reproducir.');
        return;
      }
      loadTrack(first, true);
      return;
    }
    var p = audio.play();
    if (p && p.catch) {
      p.catch(function () {
        toast('error', 'No se pudo reproducir', 'Verifica que el archivo exista y sea un MP3 válido.');
        setPlayingUI(false);
      });
    }
  }

  function togglePlay() {
    if (!audio) return;
    if (!audio.src) { playAudio(); return; }
    if (audio.paused) { playAudio(); } else { audio.pause(); }
  }

  function step(delta) {
    if (!tracks.length) return;
    var i = current;
    for (var n = 0; n < tracks.length; n++) {
      i = (i + delta + tracks.length) % tracks.length;
      if (tracks[i].available) { loadTrack(i, true); return; }
    }
  }

  function registerPlay(t) {
    fetch('canciones.asp?action=play&id=' + encodeURIComponent(t.id), {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        if (!data || !data.ok) return;
        t.plays = data.plays;
        t.row.dataset.plays = data.plays;
        var cell = t.row.querySelector('.plays-value');
        var holder = t.row.querySelector('[data-plays-cell]');
        if (cell) {
          cell.textContent = Number(data.plays).toLocaleString('es-EC');
          if (holder) {
            holder.classList.add('is-bumped');
            setTimeout(function () { holder.classList.remove('is-bumped'); }, 1400);
          }
        }
      })
      .catch(function () { /* silencioso: el contador no debe romper la reproducción */ });
  }

  if (audio) {
    audio.addEventListener('play',  function () { setPlayingUI(true); });
    audio.addEventListener('pause', function () { setPlayingUI(false); });
    audio.addEventListener('loadedmetadata', function () {
      if (timeTotal) timeTotal.textContent = fmtTime(audio.duration);
    });
    audio.addEventListener('timeupdate', function () {
      if (!audio.duration) return;
      var pct = (audio.currentTime / audio.duration) * 100;
      if (seek) { seek.value = pct; seek.style.setProperty('--p', pct); }
      if (timeCurrent) timeCurrent.textContent = fmtTime(audio.currentTime);
    });
    audio.addEventListener('ended', function () { step(1); });
    audio.addEventListener('error', function () {
      if (audio.src) toast('error', 'Error de reproducción', 'No se pudo cargar el archivo de audio.');
    });
    audio.volume = 0.8;
  }

  if (btnPlayPause) btnPlayPause.addEventListener('click', togglePlay);
  var btnPrev = $('#btnPrev'); if (btnPrev) btnPrev.addEventListener('click', function () { step(-1); });
  var btnNext = $('#btnNext'); if (btnNext) btnNext.addEventListener('click', function () { step(1); });

  if (seek) {
    seek.addEventListener('input', function () {
      seek.style.setProperty('--p', seek.value);
      if (audio && audio.duration) audio.currentTime = (seek.value / 100) * audio.duration;
    });
  }

  if (volume) {
    volume.addEventListener('input', function () {
      volume.style.setProperty('--p', volume.value * 100);
      if (audio) {
        audio.volume = parseFloat(volume.value);
        audio.muted = false;
      }
      if (btnMute) btnMute.innerHTML = parseFloat(volume.value) === 0 ? MUTE_SVG : VOL_SVG;
    });
  }

  if (btnMute) {
    btnMute.addEventListener('click', function () {
      if (!audio) return;
      audio.muted = !audio.muted;
      btnMute.innerHTML = audio.muted ? MUTE_SVG : VOL_SVG;
      btnMute.setAttribute('aria-label', audio.muted ? 'Activar sonido' : 'Silenciar');
    });
  }

  /* -------------------- Acciones de fila -------------------- */
  var tbody = $('#songsBody');
  if (tbody) {
    tbody.addEventListener('click', function (e) {
      var row = e.target.closest('.song-row');
      if (!row) return;
      var index = rows.indexOf(row);

      if (e.target.closest('[data-play]')) {
        if (current === index && audio && !audio.paused) { audio.pause(); }
        else if (current === index && audio) { playAudio(); }
        else { loadTrack(index, true); }
        return;
      }

      if (e.target.closest('[data-edit]')) {
        openEdit(row);
        return;
      }

      if (e.target.closest('[data-delete]')) {
        openDelete(row);
        return;
      }
    });
  }

  /* -------------------- Formulario -------------------- */
  var form = $('#songForm');
  var formTitle = $('#modalFormTitle');
  var formSub = $('#modalFormSub');
  var formAccion = $('#formAccion');
  var formId = $('#formId');
  var inputNombre = $('#inputNombre');
  var inputRuta = $('#inputRuta');
  var nameCount = $('#nameCount');
  var btnSubmitText = $('#btnSubmitText');

  function setFieldError(input, errorEl, msg) {
    if (!input || !errorEl) return;
    if (msg) {
      input.setAttribute('aria-invalid', 'true');
      errorEl.textContent = msg;
      errorEl.classList.add('is-visible');
    } else {
      input.removeAttribute('aria-invalid');
      errorEl.textContent = '';
      errorEl.classList.remove('is-visible');
    }
  }

  function resetForm() {
    if (!form) return;
    formId.value = '0';
    formAccion.value = 'crear';
    inputNombre.value = '';
    inputRuta.value = '';
    if (nameCount) nameCount.textContent = '0';
    setFieldError(inputNombre, $('#errorNombre'), '');
    setFieldError(inputRuta, $('#errorRuta'), '');
    if (formTitle) formTitle.textContent = 'Nueva canción';
    if (formSub) formSub.textContent = 'Agrega una canción al catálogo de PoliMusic.';
    if (btnSubmitText) btnSubmitText.textContent = 'Guardar canción';
  }

  function openNew() {
    resetForm();
    openModal('modalForm');
  }

  function openEdit(row) {
    resetForm();
    if (formTitle) formTitle.textContent = 'Editar canción';
    if (formSub) formSub.textContent = 'Actualiza el nombre o la ruta del archivo.';
    if (btnSubmitText) btnSubmitText.textContent = 'Guardar cambios';
    formAccion.value = 'actualizar';
    formId.value = row.dataset.id;
    inputNombre.value = row.dataset.name || '';
    inputRuta.value = row.dataset.path || '';
    if (nameCount) nameCount.textContent = inputNombre.value.length;
    openModal('modalForm');
  }

  var btnNew = $('#btnNew');
  if (btnNew) btnNew.addEventListener('click', openNew);
  $$('[data-open-new]').forEach(function (b) { b.addEventListener('click', openNew); });

  var deleteName = $('#deleteName');
  var deleteId = $('#deleteId');

  function openDelete(row) {
    if (deleteName) deleteName.textContent = '“' + row.dataset.name + '”';
    if (deleteId) deleteId.value = row.dataset.id;
    openModal('modalDelete');
  }

  if (inputNombre && nameCount) {
    inputNombre.addEventListener('input', function () {
      nameCount.textContent = this.value.length;
      if (this.value.trim()) setFieldError(this, $('#errorNombre'), '');
    });
  }
  if (inputRuta) {
    inputRuta.addEventListener('input', function () {
      if (this.value.trim()) setFieldError(this, $('#errorRuta'), '');
    });
  }

  if (form) {
    form.addEventListener('submit', function (e) {
      var ok = true;
      if (!inputNombre.value.trim()) {
        setFieldError(inputNombre, $('#errorNombre'), 'Escribe el nombre de la canción.');
        ok = false;
      } else if (inputNombre.value.trim().length > 50) {
        setFieldError(inputNombre, $('#errorNombre'), 'Máximo 50 caracteres.');
        ok = false;
      }
      if (!inputRuta.value.trim()) {
        setFieldError(inputRuta, $('#errorRuta'), 'Indica la ruta del archivo de audio.');
        ok = false;
      }
      if (!ok) {
        e.preventDefault();
        var card = form.closest('.modal-card');
        if (card) {
          Motion.animate(card, [
            { transform: 'translateX(0)' },
            { transform: 'translateX(-7px)' },
            { transform: 'translateX(7px)' },
            { transform: 'translateX(0)' }
          ], { duration: 320 });
        }
        return;
      }
      var btn = $('#btnSubmit');
      if (btn) { btn.disabled = true; btn.style.opacity = '.7'; }
    });
  }

  /* -------------------- Menú móvil -------------------- */
  var sidebar = $('#sidebar');
  var scrim = $('#scrim');
  var btnMenu = $('#btnMenu');

  function toggleMenu(force) {
    if (!sidebar) return;
    var open = typeof force === 'boolean' ? force : !sidebar.classList.contains('is-open');
    sidebar.classList.toggle('is-open', open);
    if (scrim) { scrim.classList.toggle('is-open', open); scrim.hidden = !open; }
    if (btnMenu) btnMenu.setAttribute('aria-expanded', String(open));
  }

  if (btnMenu) btnMenu.addEventListener('click', function () { toggleMenu(); });
  if (scrim) scrim.addEventListener('click', function () { toggleMenu(false); });

  /* -------------------- Elementos "próximamente" -------------------- */
  $$('[data-soon]').forEach(function (el) {
    el.addEventListener('click', function (e) {
      e.preventDefault();
      toast('info', 'Muy pronto', 'El módulo “' + el.dataset.soon + '” estará disponible en la siguiente entrega.');
    });
  });

  /* -------------------- Ayuda -------------------- */
  var btnHelp = $('#btnHelp');
  var btnHelpSide = $('#btnHelpSide');
  if (btnHelp) btnHelp.addEventListener('click', function () { openModal('modalHelp'); });
  if (btnHelpSide) btnHelpSide.addEventListener('click', function () { toggleMenu(false); openModal('modalHelp'); });

  /* -------------------- Mensajes del servidor -------------------- */
  if (PM.flash && PM.flash.msg) {
    toast(PM.flash.type || 'info',
          PM.flash.type === 'success' ? 'Listo' : 'Atención',
          PM.flash.msg, 5200);
  }

  /* -------------------- Animación de entrada -------------------- */
  function intro() {
    document.body.classList.add('is-ready');
    if (reduceMotion) return;

    var stats = $$('.stat');
    Motion.stagger(stats, [
      { opacity: 0, transform: 'translateY(16px)' },
      { opacity: 1, transform: 'translateY(0)' }
    ], { duration: 520, delay: 80 });

    Motion.stagger(rows, [
      { opacity: 0, transform: 'translateY(10px)' },
      { opacity: 1, transform: 'translateY(0)' }
    ], { duration: 420, delay: 140 });

    var hero = $('.hero h1');
    if (hero) {
      Motion.animate(hero, [
        { opacity: 0, transform: 'translateY(14px)' },
        { opacity: 1, transform: 'translateY(0)' }
      ], { duration: 620 });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', intro);
  } else {
    intro();
  }

  /* Reabrir el modal si el servidor devolvió un error de validación */
  if (PM.form && PM.form.open) {
    setTimeout(function () {
      if (PM.form.mode === 'editar') {
        if (formTitle) formTitle.textContent = 'Editar canción';
        if (formSub) formSub.textContent = 'Actualiza el nombre o la ruta del archivo.';
        if (btnSubmitText) btnSubmitText.textContent = 'Guardar cambios';
        formAccion.value = 'actualizar';
      }
      openModal('modalForm');
    }, 220);
  }
})();
