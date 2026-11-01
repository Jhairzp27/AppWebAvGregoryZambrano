using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.PoliMusicV3
{
    /// <summary>
    /// Reglas de negocio de las canciones. La pantalla solo habla con esta clase:
    /// aquí se valida y se delega el acceso a datos a la capa DAL.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Read();
        }

        public DataTable ReadById(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).ReadById(idSong);
        }

        public int Update(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Update(song);
        }

        public int Delete(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Delete(idSong);
        }

        public int IncrementPlays(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).IncrementPlays(idSong);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).CheckExistSong(songName);
        }

        public int CheckExistSong(string songName, int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).CheckExistSong(songName, idSong);
        }

        /// <summary>
        /// Valida los campos obligatorios y el largo máximo que permiten las columnas
        /// de TBL_SONG (SONG_NAME varchar(50), SONG_PATH varchar(255)).
        /// </summary>
        /// <param name="song">Entidad a validar</param>
        /// <returns>Cadena vacía si es válida o el mensaje de error</returns>
        public string Validate(EntityLayer.PoliMusicV3.Song song)
        {
            if (song == null)
            {
                return "No se recibió la información de la canción.";
            }
            if (string.IsNullOrEmpty(song.SongName) || song.SongName.Trim() == string.Empty)
            {
                return "El nombre de la canción es obligatorio.";
            }
            if (song.SongName.Trim().Length > 50)
            {
                return "El nombre de la canción no puede superar los 50 caracteres.";
            }
            if (string.IsNullOrEmpty(song.SongPath) || song.SongPath.Trim() == string.Empty)
            {
                return "Debes indicar la ruta del archivo de audio.";
            }
            if (song.SongPath.Trim().Length > 255)
            {
                return "La ruta del archivo no puede superar los 255 caracteres.";
            }
            return string.Empty;
        }

        /// <summary>
        /// Comprueba que el nombre no esté registrado dos veces. Al editar se excluye
        /// la propia canción de la búsqueda.
        /// </summary>
        /// <param name="song">Entidad a validar</param>
        /// <returns>Cadena vacía si el nombre está libre o el mensaje de error</returns>
        public string ValidationsDuplicated(EntityLayer.PoliMusicV3.Song song)
        {
            if (song == null)
            {
                return string.Empty;
            }
            int returnValue = (song.ID > 0)
                ? CheckExistSong(song.SongName.Trim(), song.ID)
                : CheckExistSong(song.SongName.Trim());
            if (returnValue != 0)
            {
                return "Ya existe una canción con ese nombre!.";
            }
            return string.Empty;
        }
    }

}
