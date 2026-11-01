using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.PoliMusicV3
{
    /// <summary>
    /// Capa de acceso a datos de la tabla TBL_SONG.
    /// Solo habla con SQL Server: no valida reglas de negocio ni conoce la interfaz.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Inserta una canción nueva. El contador de reproducciones arranca en 0
        /// cuando la entidad no trae un valor.
        /// </summary>
        /// <param name="song">Entidad con los datos a guardar</param>
        /// <returns>Número de filas afectadas</returns>
        public int Save(EntityLayer.PoliMusicV3.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG]([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                        "VALUES(@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Devuelve el catálogo completo ordenado por nombre.
        /// </summary>
        /// <returns>DataTable con ID_SONG, SONG_NAME, SONG_PATH y PLAYS</returns>
        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], ISNULL([PLAYS], 0) AS [PLAYS] " +
                    "FROM [TBL_SONG] ORDER BY [SONG_NAME]", con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Devuelve una canción por su identificador.
        /// </summary>
        /// <param name="idSong">Identificador de la canción</param>
        /// <returns>DataTable con cero o una fila</returns>
        public DataTable ReadById(int idSong)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], ISNULL([PLAYS], 0) AS [PLAYS] " +
                        "FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Actualiza el nombre y la ruta de una canción existente.
        /// El contador de reproducciones no se toca aquí: solo lo mueve IncrementPlays.
        /// </summary>
        /// <param name="song">Entidad con los valores nuevos</param>
        /// <returns>Número de filas afectadas</returns>
        public int Update(EntityLayer.PoliMusicV3.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                        "[SONG_NAME] = @SONG_NAME " +
                        ", [SONG_PATH] = @SONG_PATH " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Elimina una canción. Las tablas que la referencian (playlists, tracklists y
        /// reproductor) se limpian primero dentro de la misma transacción; si alguna de
        /// esas tablas no existe en la base simplemente se omite.
        /// </summary>
        /// <param name="idSong">Identificador de la canción</param>
        /// <returns>Número de filas afectadas en TBL_SONG</returns>
        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                con.Open();
                using (SqlTransaction tran = con.BeginTransaction())
                {
                    try
                    {
                        DeleteChildRows(con, tran, "TBL_PLAYLIST_SONG", idSong);
                        DeleteChildRows(con, tran, "TBL_TRACKLIST", idSong);
                        DeleteChildRows(con, tran, "TBL_PLAYER", idSong);
                        int rowsAffected = ExecuteNonQuery(con, tran,
                            "DELETE FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG", idSong);
                        tran.Commit();
                        return rowsAffected;
                    }
                    catch (Exception)
                    {
                        try
                        {
                            tran.Rollback();
                        }
                        catch (Exception)
                        {
                            // SQL Server ya revirtió la transacción (por ejemplo, por un error de conexión).
                        }
                        throw;
                    }
                }
            }
        }

        /// <summary>
        /// Borra las filas hijas de una tabla relacionada solo si la tabla existe.
        /// El nombre llega desde una lista fija, nunca desde la interfaz.
        /// </summary>
        private void DeleteChildRows(SqlConnection con, SqlTransaction tran, string tableName, int idSong)
        {
            string sentence = "IF OBJECT_ID(@TABLE_NAME, 'U') IS NOT NULL " +
                "DELETE FROM [" + tableName + "] WHERE [ID_SONG] = @ID_SONG";
            using (SqlCommand cmd = new SqlCommand(sentence, con, tran))
            {
                cmd.Parameters.AddWithValue("@TABLE_NAME", tableName);
                cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                cmd.ExecuteNonQuery();
            }
        }

        private int ExecuteNonQuery(SqlConnection con, SqlTransaction tran, string sentence, int idSong)
        {
            using (SqlCommand cmd = new SqlCommand(sentence, con, tran))
            {
                cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                return cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Suma una reproducción a la canción y devuelve el contador actualizado.
        /// </summary>
        /// <param name="idSong">Identificador de la canción</param>
        /// <returns>Valor de PLAYS después del update, o 0 si la canción no existe</returns>
        public int IncrementPlays(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [PLAYS] = ISNULL([PLAYS], 0) + 1 " +
                        "OUTPUT INSERTED.[PLAYS] " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    object returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }

        /// <summary>
        /// Comprueba si un nombre de canción ya está registrado.
        /// </summary>
        /// <param name="songName">Nombre a comprobar</param>
        /// <returns>ID_SONG encontrado o 0 si el nombre está libre</returns>
        public int CheckExistSong(string songName)
        {
            object returnValue;
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT [ID_SONG] FROM [TBL_SONG] WHERE [SONG_NAME] = @SONG_NAME";
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Connection = con;
                    con.Open();
                    returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }

        /// <summary>
        /// Comprueba si un nombre lo usa otra canción distinta (útil al editar).
        /// </summary>
        /// <param name="songName">Nombre a comprobar</param>
        /// <param name="idSong">Canción que se está editando</param>
        /// <returns>ID_SONG de la canción duplicada o 0 si el nombre está libre</returns>
        public int CheckExistSong(string songName, int idSong)
        {
            object returnValue;
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT [ID_SONG] FROM [TBL_SONG] " +
                        "WHERE [SONG_NAME] = @SONG_NAME AND [ID_SONG] <> @ID_SONG";
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }
    }

}
