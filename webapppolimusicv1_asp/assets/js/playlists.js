/* ============================================================================
   PoliMusic · assets/js/playlists.js
   Interacción de la biblioteca de playlists: menú móvil, ayuda, animación de
   entrada y reproductor de las canciones de la playlist abierta.

   El servidor inyecta el estado inicial en window.PM (script inline previo).
   Este archivo no contiene ASP: es JS puro y cacheable por el navegador.
   ============================================================================ */
(function () {
  'use strict';

  var PM = window.PM || {};
  var $ = function (sel, ctx) { return (ctx || document).querySelector(sel); };
  var $$ = function (sel, ctx) {
    return Array.prototype.slice.call((ctx || document).querySelectorAll(sel));
  };
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var SPRING = 'cubic-bezier(.34,1.32,.64,1)';

  /* -------------------- Animación (mismo criterio que canciones.js) -------------------- */
  function animate(el, frames, opts) {
    if (!el) return null;
    if (reduceMotion) {
      var last = frames[frames.length - 1];
      Object.keys(last).forEach(function (k) { el.style[k] = last[k]; });
      return null;
    }
    var o = Object.assign({ duration: 480, easing: SPRING, fill: 'both' }, opts || {});
    if (el.animate) { try { return el.animate(frames, o); } catch (e) { return null; } }
    return null;
  }

  function stagger(els, frames, base) {
    els.forEach(function (el, i) {
      var o = Object.assign({}, base || {}, {
        delay: (base && base.delay ? base.delay : 0) + i * 45
      });
      animate(el, frames, o);
    });
  }

  /* -------------------- Toasts -------------------- */
  var ICONS = {
    info: "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round'><path d='M12 10v7M12 6.5h.01'/></svg>"
  };

  function toast(title, msg, ms) {
    var wrap = $('#toasts');
    if (!wrap) return;
    var el = document.createElement('div');
    el.className = 'toast info';
    el.setAttribute('role', 'status');
    el.innerHTML = '<span class="t-icon">' + ICONS.info + '</span>' +
      '<span class="t-body"><span class="t-title"></span><span class="t-msg"></span></span>';
    el.querySelector('.t-title').textContent = title;
    if (msg) el.querySelector('.t-msg').textContent = msg;
    wrap.appendChild(el);

    animate(el, [
      { opacity: 0, transform: 'translateY(14px) scale(.96)' },
      { opacity: 1, transform: 'translateY(0) scale(1)' }
    ], { duration: 380 });

    setTimeout(function () {
      var out = animate(el, [
        { opacity: 1, transform: 'translateY(0)' },
        { opacity: 0, transform: 'translateY(-8px)' }
      ], { duration: 260 });
      if (out) { out.onfinish = function () { el.remove(); }; } else { el.remove(); }
    }, ms || 3600);
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

  /* -------------------- Modal de ayuda -------------------- */
  var modalHelp = $('#modalHelp');

  function openHelp() {
    if (!modalHelp) return;
    modalHelp.classList.add('is-open');
    document.body.style.overflow = 'hidden';
    var first = modalHelp.querySelector('button');
    setTimeout(function () { if (first) first.focus(); }, 80);
  }

  function closeHelp() {
    if (!modalHelp) return;
    modalHelp.classList.remove('is-open');
    document.body.style.overflow = '';
  }

  $$('#btnHelp, #btnHelpSide').forEach(function (b) {
    b.addEventListener('click', openHelp);
  });

  if (modalHelp) {
    $$('[data-close]', modalHelp).forEach(function (b) {
      b.addEventListener('click', closeHelp);
    });
  }

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      if (modalHelp && modalHelp.classList.contains('is-open')) closeHelp();
      else toggleMenu(false);
    }
  });

  /* -------------------- Elementos "próximamente" -------------------- */
  $$('.nav-item.is-soon').forEach(function (item) {
    item.addEventListener('click', function (e) {
      e.preventDefault();
      toast(item.dataset.soon || 'Próximamente', 'Esta sección estará disponible más adelante.');
    });
  });

  /* -------------------- Reproductor -------------------- */
  var audio = $('#pmAudio');
  var rows = $$('.track-row');

  var tracks = rows.map(function (row) {
    return {
      id: row.dataset.id,
      name: row.dataset.name || '',
      artists: row.dataset.artists || '',
      src: row.dataset.src || '',
      available: row.dataset.available === '1',
      c1: row.dataset.c1 || '#FF9A3C',
      c2: row.dataset.c2 || '#E23E00',
      row: row
    };
  });

  var playerCover = $('#playerCover');
  var playerTitle = $('#playerTitle');
  var playerArtist = $('#playerArtist');
  var btnPlayPause = $('#btnPlayPause');
  var btnPrev = $('#btnPrev');
  var btnNext = $('#btnNext');
  var seek = $('#seek');
  var volume = $('#volume');
  var timeCurrent = $('#timeCurrent');
  var timeTotal = $('#timeTotal');
  var btnMute = $('#btnMute');

  var current = -1;
  var counted = {};
  var lastVolume = 0.8;

  function fmtTime(s) {
    if (!isFinite(s) || s < 0) s = 0;
    var m = Math.floor(s / 60);
    var r = Math.floor(s % 60);
    return m + ':' + (r < 10 ? '0' : '') + r;
  }

  function setPlayingUI(on) {
    if (!btnPlayPause) return;
    btnPlayPause.innerHTML = on
      ? "<svg viewBox='0 0 24 24' aria-hidden='true'><rect x='7' y='5' width='3.6' height='14' rx='1.2' fill='currentColor'/><rect x='13.4' y='5' width='3.6' height='14' rx='1.2' fill='currentColor'/></svg>"
      : "<svg viewBox='0 0 24 24' aria-hidden='true'><path d='M8 5.14v13.72c0 .8.87 1.3 1.56.9l11.1-6.86a1.05 1.05 0 0 0 0-1.8L9.56 4.24A1.05 1.05 0 0 0 8 5.14Z' fill='currentColor'/></svg>";
    btnPlayPause.setAttribute('aria-label', on ? 'Pausar' : 'Reproducir');
    document.body.classList.toggle('is-playing', on);
  }

  function loadTrack(index, autoplay) {
    if (index < 0 || index >= tracks.length) return;
    var t = tracks[index];
    if (!t.available) {
      toast('Sin audio', 'El archivo de "' + t.name + '" no está en la carpeta SongFiles.');
      return;
    }

    rows.forEach(function (r) { r.classList.remove('is-playing', 'is-current'); });
    t.row.classList.add('is-current');

    current = index;
    audio.src = t.src;

    if (playerTitle) playerTitle.textContent = t.name;
    if (playerArtist) playerArtist.textContent = t.artists;
    if (playerCover) {
      playerCover.textContent = (t.name.charAt(0) || '♪').toUpperCase();
      playerCover.style.setProperty('--c1', t.c1);
      playerCover.style.setProperty('--c2', t.c2);
    }

    if (autoplay) playAudio();
  }

  function playAudio() {
    if (current < 0) {
      var firstOk = tracks.findIndex(function (t) { return t.available; });
      if (firstOk < 0) { toast('Sin audio', 'Esta playlist no tiene archivos disponibles.'); return; }
      loadTrack(firstOk, true);
      return;
    }
    var p = audio.play();
    if (p && p.catch) {
      p.catch(function () {
        toast('No se pudo reproducir', 'El navegador bloqueó la reproducción automática.');
      });
    }
  }

  function togglePlay() {
    if (current < 0) { playAudio(); return; }
    if (audio.paused) playAudio(); else audio.pause();
  }

  function step(delta) {
    if (!tracks.length) return;
    var i = current < 0 ? 0 : current;
    for (var n = 1; n <= tracks.length; n++) {
      var next = (i + delta * n + tracks.length * n) % tracks.length;
      if (tracks[next].available) { loadTrack(next, true); return; }
    }
    toast('Sin audio', 'No hay otra canción disponible en esta playlist.');
  }

  function registerPlay(t) {
    if (!t || counted[t.id]) return;
    counted[t.id] = true;
    fetch('canciones.asp?action=play&id=' + encodeURIComponent(t.id), {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        if (!data || !data.ok) return;
        var cell = t.row.querySelector('.plays-value');
        if (cell) cell.textContent = Number(data.plays).toLocaleString('es-EC');
      })
      .catch(function () { /* silencioso: el contador no debe romper la reproducción */ });
  }

  if (audio) {
    audio.addEventListener('play', function () {
      setPlayingUI(true);
      if (current >= 0) {
        tracks[current].row.classList.add('is-playing');
        registerPlay(tracks[current]);
      }
    });

    audio.addEventListener('pause', function () {
      setPlayingUI(false);
      if (current >= 0) tracks[current].row.classList.remove('is-playing');
    });

    audio.addEventListener('ended', function () { step(1); });

    audio.addEventListener('loadedmetadata', function () {
      if (timeTotal) timeTotal.textContent = fmtTime(audio.duration);
    });

    audio.addEventListener('timeupdate', function () {
      if (!audio.duration) return;
      var pct = (audio.currentTime / audio.duration) * 100;
      if (timeCurrent) timeCurrent.textContent = fmtTime(audio.currentTime);
      if (seek) {
        seek.value = pct;
        seek.style.setProperty('--p', pct);
      }
    });

    if (volume) {
      audio.volume = parseFloat(volume.value) || 0.8;
      lastVolume = audio.volume;
      volume.addEventListener('input', function () {
        audio.volume = parseFloat(volume.value);
        audio.muted = audio.volume === 0;
        volume.style.setProperty('--p', audio.volume * 100);
        if (audio.volume > 0) lastVolume = audio.volume;
      });
    }

    if (seek) {
      seek.addEventListener('input', function () {
        if (!audio.duration) return;
        audio.currentTime = (parseFloat(seek.value) / 100) * audio.duration;
      });
    }

    if (btnMute) {
      btnMute.addEventListener('click', function () {
        audio.muted = !audio.muted;
        btnMute.classList.toggle('is-muted', audio.muted);
        btnMute.setAttribute('aria-label', audio.muted ? 'Activar sonido' : 'Silenciar');
        if (volume) volume.style.setProperty('--p', audio.muted ? 0 : (parseFloat(volume.value) || lastVolume) * 100);
      });
    }
  }

  if (btnPlayPause) btnPlayPause.addEventListener('click', togglePlay);
  if (btnPrev) btnPrev.addEventListener('click', function () { step(-1); });
  if (btnNext) btnNext.addEventListener('click', function () { step(1); });

  /* Reproducir desde la fila */
  rows.forEach(function (row, i) {
    var btn = row.querySelector('[data-play]');
    if (btn) {
      btn.addEventListener('click', function () { loadTrack(i, true); });
    }
  });

  /* -------------------- Animación de entrada -------------------- */
  function intro() {
    document.body.classList.add('is-ready');
    if (reduceMotion) return;

    stagger($$('.stat'), [
      { opacity: 0, transform: 'translateY(16px)' },
      { opacity: 1, transform: 'translateY(0)' }
    ], { duration: 520, delay: 80 });

    stagger($$('.pl-card, .track-row'), [
      { opacity: 0, transform: 'translateY(12px)' },
      { opacity: 1, transform: 'translateY(0)' }
    ], { duration: 460, delay: 120 });

    var title = $('.hero h1, .pl-head h1');
    if (title) {
      animate(title, [
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
})();
