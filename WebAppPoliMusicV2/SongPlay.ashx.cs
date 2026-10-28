using System;
using System.Configuration;
using System.Web;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Lightweight endpoint used by Song.aspx to increase the PLAYS counter of a
    /// song without reloading the page (and without interrupting the playback).
    /// </summary>
    public class SongPlay : IHttpHandler
    {
        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Charset = "utf-8";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            if (context.User == null || !context.User.Identity.IsAuthenticated)
            {
                context.Response.StatusCode = 401;
                context.Response.Write("{\"ok\":false,\"error\":\"no autorizado\"}");
                return;
            }

            int idSong;
            if (!int.TryParse(context.Request.QueryString["id"], out idSong) || idSong <= 0)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("{\"ok\":false,\"error\":\"id invalido\"}");
                return;
            }

            try
            {
                string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
                int plays = new BLL.Song(strConnString).IncrementPlays(idSong);
                context.Response.Write("{\"ok\":true,\"plays\":" + plays + "}");
            }
            catch (Exception)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("{\"ok\":false,\"error\":\"no se pudo actualizar el contador\"}");
            }
        }
    }
}
