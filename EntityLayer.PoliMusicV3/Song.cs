using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EntityLayer.PoliMusicV3
{
    /// <summary>
    /// Entidad que representa una fila de la tabla TBL_SONG.
    /// Columnas: ID_SONG (int identity), SONG_NAME (varchar 50),
    /// SONG_PATH (varchar 255) y PLAYS (int).
    /// </summary>
    public class Song
    {
        public Song()
        {
        }

        public Song(int id, string songName, string songPath, int plays)
        {
            ID = id;
            SongName = songName;
            SongPath = songPath;
            Plays = plays;
        }

        /// <summary>Identificador de la canción (ID_SONG).</summary>
        public int ID { get; set; }

        /// <summary>Nombre visible de la canción (SONG_NAME).</summary>
        public string SongName { get; set; }

        /// <summary>Ruta lógica del archivo de audio, por ejemplo ~/songFiles/tema.mp3 (SONG_PATH).</summary>
        public string SongPath { get; set; }

        /// <summary>Número de reproducciones acumuladas (PLAYS).</summary>
        public int Plays { get; set; }
    }

}
