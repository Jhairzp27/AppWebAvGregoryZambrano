<!-- ==================== REPRODUCTOR ==================== -->
<div class="player" id="player" role="region" aria-label="Reproductor de audio">
  <div class="player-track">
    <div class="cover" id="playerCover" style="--c1:#FF9A3C;--c2:#E23E00" aria-hidden="true">♪</div>
    <div class="player-meta">
      <span class="player-title" id="playerTitle">Ninguna canción seleccionada</span>
      <span class="player-artist" id="playerArtist">Elige una canción de la lista</span>
    </div>
  </div>

  <div class="player-center">
    <div class="player-controls">
      <button class="pc-btn" type="button" id="btnPrev" aria-label="Canción anterior" title="Anterior"><%= Icon("prev") %></button>
      <button class="pc-btn primary" type="button" id="btnPlayPause" aria-label="Reproducir" title="Reproducir / Pausar"><%= Icon("play") %></button>
      <button class="pc-btn" type="button" id="btnNext" aria-label="Siguiente canción" title="Siguiente"><%= Icon("next") %></button>
    </div>
    <div class="timeline">
      <span id="timeCurrent">0:00</span>
      <input type="range" id="seek" min="0" max="100" value="0" step="0.1" aria-label="Progreso de la canción" style="--p:0">
      <span id="timeTotal">0:00</span>
    </div>
  </div>

  <div class="player-right">
    <button class="pc-btn" type="button" id="btnMute" aria-label="Silenciar" title="Silenciar"><%= Icon("volume") %></button>
    <input type="range" id="volume" min="0" max="1" step="0.01" value="0.8" aria-label="Volumen" style="--p:80">
  </div>

  <!-- Reproductor HTML5 -->
  <audio id="pmAudio" preload="metadata"></audio>
</div>
