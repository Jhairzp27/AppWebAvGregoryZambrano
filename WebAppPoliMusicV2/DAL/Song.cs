using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WebAppPoliMusicV2.DAL
{
    public class Song
    {
        private string strConnectionString;
        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Inserts a new song into TBL_SONG.
        /// </summary>
        /// <param name="song">Song entity with the data to store</param>
        /// <returns>Number of rows affected</returns>
        public int Save(Entities.Song song)
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
        /// Reads every song of the catalog ordered by name.
        /// </summary>
        /// <returns>DataTable with ID_SONG, SONG_NAME, SONG_PATH and PLAYS</returns>
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
        /// Reads one song by its identifier.
        /// </summary>
        /// <param name="idSong">Identifier of the song</param>
        /// <returns>DataTable with zero or one row</returns>
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
        /// Updates the name and the path of an existing song. The play counter is
        /// not modified here, it is only increased by IncrementPlays.
        /// </summary>
        /// <param name="song">Song entity with the new values</param>
        /// <returns>Number of rows affected</returns>
        public int Update(Entities.Song song)
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
        /// Deletes a song. TBL_PLAYLIST_SONG, TBL_TRACKLIST and TBL_PLAYER reference
        /// TBL_SONG, so their rows are removed first inside the same transaction.
        /// </summary>
        /// <param name="idSong">Identifier of the song</param>
        /// <returns>Number of rows affected on TBL_SONG</returns>
        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                con.Open();
                SqlTransaction tran = con.BeginTransaction();
                try
                {
                    ExecuteDelete(con, tran, "DELETE FROM [TBL_PLAYLIST_SONG] WHERE [ID_SONG] = @ID_SONG", idSong);
                    ExecuteDelete(con, tran, "DELETE FROM [TBL_TRACKLIST] WHERE [ID_SONG] = @ID_SONG", idSong);
                    ExecuteDelete(con, tran, "DELETE FROM [TBL_PLAYER] WHERE [ID_SONG] = @ID_SONG", idSong);
                    int rowsAffected = ExecuteDelete(con, tran, "DELETE FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG", idSong);
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
                        // The transaction was already rolled back by SQL Server.
                    }
                    throw;
                }
                finally
                {
                    tran.Dispose();
                }
            }
        }

        private int ExecuteDelete(SqlConnection con, SqlTransaction tran, string sentence, int idSong)
        {
            using (SqlCommand cmd = new SqlCommand(sentence, con, tran))
            {
                cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                return cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Increases the play counter of a song and returns the new value.
        /// </summary>
        /// <param name="idSong">Identifier of the song</param>
        /// <returns>The play counter after the update, or 0 if the song does not exist</returns>
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
        /// Checks if a song name is already registered.
        /// </summary>
        /// <param name="songName">Name of the song</param>
        /// <returns>The ID_SONG of the song found or 0 when the name is free</returns>
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
        /// Checks if a song name is used by another song (useful while updating).
        /// </summary>
        /// <param name="songName">Name of the song</param>
        /// <param name="idSong">Identifier of the song being updated</param>
        /// <returns>The ID_SONG of the duplicated song or 0 when the name is free</returns>
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
