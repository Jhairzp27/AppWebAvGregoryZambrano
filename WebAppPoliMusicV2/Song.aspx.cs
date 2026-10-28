using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        /// <summary>
        /// Logical folder where the mp3 files live. It matches the SONG_PATH values
        /// stored in TBL_SONG (~/songFiles/name.mp3).
        /// </summary>
        private const string SONG_FOLDER = "~/songFiles/";

        private const string ICON_WARNING =
            "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">" +
            "<path d=\"M12 9v4\"/><path d=\"M12 17h.01\"/><path d=\"M10.3 3.9 2.4 18a2 2 0 0 0 1.7 3h15.8a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z\"/></svg>";

        private const string ICON_WARNING_SMALL =
            "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2.4\" stroke-linecap=\"round\" stroke-linejoin=\"round\">" +
            "<path d=\"M12 8v5\"/><path d=\"M12 17h.01\"/><circle cx=\"12\" cy=\"12\" r=\"9\"/></svg>";

        private const string ICON_CHECK =
            "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2.6\" stroke-linecap=\"round\" stroke-linejoin=\"round\">" +
            "<path d=\"m4 12.5 5 5L20 6.5\"/></svg>";

        private const string ICON_INFO =
            "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">" +
            "<circle cx=\"12\" cy=\"12\" r=\"9\"/><path d=\"M12 11v5\"/><path d=\"M12 8h.01\"/></svg>";

        protected void Page_Init(object sender, EventArgs e)
        {
            // The form needs multipart encoding to receive the mp3 file.
            if (form1.Attributes["enctype"] == null)
            {
                form1.Attributes["enctype"] = "multipart/form-data";
            }
            txtSongName.Attributes["placeholder"] = "Ej. Adventure";
            txtSongName.Attributes["autocomplete"] = "off";
            txtSongPath.Attributes["placeholder"] = "~/songFiles/mi-cancion.mp3";
            txtSongPath.Attributes["autocomplete"] = "off";
            txtSongPath.Attributes["list"] = "songFilesList";

            // Pressing Enter inside the form modal must save the song instead of
            // firing the first submit button of the page.
            pnlFormModal.DefaultButton = "btnSave";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!LoadUser())
            {
                return;
            }
            if (!Page.IsPostBack)
            {
                BindSongs();
            }
        }

        /* ==================================================================
           SESIÓN
           ================================================================== */

        /// <summary>
        /// Takes the authenticated user from the session (it is stored by Login.aspx)
        /// and paints the name on the top bar and on the welcome message.
        /// </summary>
        /// <returns>False when the user is not authenticated and the page is redirecting</returns>
        private bool LoadUser()
        {
            // The forms authentication ticket is the source of truth: Logout.aspx
            // signs it out but the session is not abandoned, so the session alone
            // is not enough to consider the user authenticated.
            if (!Request.IsAuthenticated)
            {
                Response.Redirect("~/Login.aspx", true);
                return false;
            }

            Entities.User user = Session[Util.Constants.USER] as Entities.User;

            if (user == null)
            {
                // The session expired but the ticket is still valid: the user name
                // is recovered from the authentication ticket.
                user = new Entities.User();
                user.UserName = Context.User.Identity.Name;
                user.UserType = Util.Constants.ID_USER_NORMAL;
                user.Photo = string.Empty;
            }

            litUserName.Text = HttpUtility.HtmlEncode(user.UserName);
            litHeroName.Text = HttpUtility.HtmlEncode(user.UserName);
            litUserRole.Text = (user.UserType == Util.Constants.ID_USER_ADMIN) ? "Administrador" : "Usuario";
            litAvatar.Text = BuildAvatar(user);
            return true;
        }

        private string BuildAvatar(Entities.User user)
        {
            if (!string.IsNullOrEmpty(user.Photo) && FileExistsOnServer(user.Photo))
            {
                return "<img src=\"" + HttpUtility.HtmlAttributeEncode(ResolveUrl(user.Photo)) + "\" alt=\"\" />";
            }
            string name = (user.UserName == null) ? string.Empty : user.UserName.Trim();
            if (name.Length == 0)
            {
                return "?";
            }
            return HttpUtility.HtmlEncode(name.Substring(0, 1).ToUpper());
        }

        /* ==================================================================
           CATÁLOGO
           ================================================================== */

        /// <summary>
        /// Reads the catalog through the BLL, binds the repeater and refreshes
        /// the counters shown on the screen.
        /// </summary>
        protected void BindSongs()
        {
            DataTable dtSongs;
            try
            {
                dtSongs = new BLL.Song(strConnString).Read();
            }
            catch (Exception)
            {
                dtSongs = new DataTable();
                ShowToast("error", "No se pudo cargar el catálogo. Verifica la conexión con SQL Server.");
            }
            if (dtSongs == null)
            {
                dtSongs = new DataTable();
            }

            rptSongs.DataSource = dtSongs;
            rptSongs.DataBind();

            int totalSongs = dtSongs.Rows.Count;
            int totalPlays = 0;
            int totalAvailable = 0;

            foreach (DataRow row in dtSongs.Rows)
            {
                totalPlays += Convert.ToInt32(row["PLAYS"]);
                if (FileExistsOnServer(Convert.ToString(row["SONG_PATH"])))
                {
                    totalAvailable++;
                }
            }

            litStatSongs.Text = totalSongs.ToString();
            litStatPlays.Text = totalPlays.ToString();
            litStatAudio.Text = totalAvailable.ToString();
            litCountChip.Text = (totalSongs == 1) ? "1 canción" : totalSongs + " canciones";
            pnlEmpty.Visible = (totalSongs == 0);
            litSongFiles.Text = BuildSongFilesOptions();
        }

        /// <summary>
        /// Builds the options of the datalist that suggests the mp3 files that
        /// already exist on the server.
        /// </summary>
        private string BuildSongFilesOptions()
        {
            System.Text.StringBuilder builder = new System.Text.StringBuilder();
            try
            {
                string strFolder = Server.MapPath(SONG_FOLDER);
                if (Directory.Exists(strFolder))
                {
                    string[] files = Directory.GetFiles(strFolder, "*.mp3");
                    Array.Sort(files);
                    foreach (string file in files)
                    {
                        builder.Append("<option value=\"");
                        builder.Append(HttpUtility.HtmlAttributeEncode(SONG_FOLDER + Path.GetFileName(file)));
                        builder.Append("\"></option>");
                    }
                }
            }
            catch (Exception)
            {
                // Suggestions are optional: if the folder cannot be read we simply show none.
            }
            return builder.ToString();
        }

        /* ==================================================================
           CRUD
           ================================================================== */

        protected void btnNew_Click(object sender, EventArgs e)
        {
            hfSongId.Value = "0";
            txtSongName.Text = string.Empty;
            txtSongPath.Text = SONG_FOLDER;
            litFormTitle.Text = "Nueva canción";
            litFormError.Text = string.Empty;
            CloseModals();
            pnlFormModal.CssClass = "modal is-open";
        }

        protected void rptSongs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idSong = ParseId(e.CommandArgument);
            if (idSong <= 0)
            {
                ShowToast("error", "No se pudo identificar la canción.");
                return;
            }

            if (e.CommandName == "edit")
            {
                DataTable dtSong;
                try
                {
                    dtSong = new BLL.Song(strConnString).ReadById(idSong);
                }
                catch (Exception)
                {
                    ShowToast("error", "No se pudo leer la canción seleccionada.");
                    return;
                }

                if (dtSong == null || dtSong.Rows.Count == 0)
                {
                    ShowToast("error", "La canción ya no existe en el catálogo.");
                    BindSongs();
                    return;
                }

                hfSongId.Value = idSong.ToString();
                txtSongName.Text = Convert.ToString(dtSong.Rows[0]["SONG_NAME"]);
                txtSongPath.Text = Convert.ToString(dtSong.Rows[0]["SONG_PATH"]);
                litFormTitle.Text = "Editar canción";
                litFormError.Text = string.Empty;
                CloseModals();
                pnlFormModal.CssClass = "modal is-open";
            }
            else if (e.CommandName == "delete")
            {
                hfDeleteId.Value = idSong.ToString();
                litDeleteName.Text = HttpUtility.HtmlEncode(GetSongName(idSong));
                CloseModals();
                pnlDeleteModal.CssClass = "modal is-open";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int idSong = ParseId(hfSongId.Value);
            string songName = (txtSongName.Text == null) ? string.Empty : txtSongName.Text.Trim();
            string songPath = NormalizeSongPath(txtSongPath.Text);

            // If a file was selected it is stored on the server and the path is
            // replaced by the location of the new file.
            if (fuSongFile.HasFile)
            {
                string fileName = BuildFileName(songName);
                string uploadError = new FileManagement().SaveSongOnServer(fuSongFile, SONG_FOLDER, fileName);
                if (!string.IsNullOrEmpty(uploadError))
                {
                    ShowFormError(uploadError);
                    return;
                }
                songPath = SONG_FOLDER + fileName + ".mp3";
            }

            Entities.Song song = new Entities.Song(idSong, songName, songPath, 0);
            BLL.Song bllSong = new BLL.Song(strConnString);

            string message = bllSong.Validate(song);
            if (string.IsNullOrEmpty(message))
            {
                message = bllSong.ValidationsDuplicated(song);
            }
            if (!string.IsNullOrEmpty(message))
            {
                ShowFormError(message);
                return;
            }

            try
            {
                if (idSong > 0)
                {
                    bllSong.Update(song);
                    ShowToast("success", "La canción se actualizó correctamente.");
                }
                else
                {
                    bllSong.Save(song);
                    ShowToast("success", "La canción se agregó al catálogo.");
                }
            }
            catch (Exception)
            {
                ShowFormError("No se pudo guardar la canción. Revisa los datos e inténtalo otra vez.");
                return;
            }

            pnlFormModal.CssClass = "modal";
            hfSongId.Value = "0";
            txtSongName.Text = string.Empty;
            txtSongPath.Text = string.Empty;
            BindSongs();
        }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            int idSong = ParseId(hfDeleteId.Value);
            CloseModals();
            hfDeleteId.Value = "0";

            if (idSong <= 0)
            {
                ShowToast("error", "No se pudo identificar la canción.");
                return;
            }

            try
            {
                int rowsAffected = new BLL.Song(strConnString).Delete(idSong);
                if (rowsAffected > 0)
                {
                    ShowToast("success", "La canción se eliminó del catálogo.");
                }
                else
                {
                    ShowToast("error", "La canción ya no existe en el catálogo.");
                }
            }
            catch (Exception)
            {
                ShowToast("error", "No se pudo eliminar la canción. Inténtalo otra vez.");
            }
            BindSongs();
        }

        /* ==================================================================
           HELPERS
           ================================================================== */

        /// <summary>
        /// Closes both modals. The client can close them with JavaScript, but the
        /// server keeps the class in the ViewState, so it is reset on every action
        /// that changes the modal being shown.
        /// </summary>
        private void CloseModals()
        {
            pnlFormModal.CssClass = "modal";
            pnlDeleteModal.CssClass = "modal";
        }

        private string GetSongName(int idSong)
        {
            try
            {
                DataTable dtSong = new BLL.Song(strConnString).ReadById(idSong);
                if (dtSong != null && dtSong.Rows.Count > 0)
                {
                    return Convert.ToString(dtSong.Rows[0]["SONG_NAME"]);
                }
            }
            catch (Exception)
            {
                // The generic name below is used when the song cannot be read.
            }
            return "esta canción";
        }

        /// <summary>
        /// Keeps the path in the logical format used by TBL_SONG (~/songFiles/file.mp3).
        /// </summary>
        private string NormalizeSongPath(string path)
        {
            if (path == null)
            {
                return string.Empty;
            }
            path = path.Trim().Replace("\\", "/");
            if (path == string.Empty)
            {
                return string.Empty;
            }
            if (path.StartsWith("~/"))
            {
                return path;
            }
            if (path.StartsWith("/"))
            {
                return "~" + path;
            }
            if (path.IndexOf("/") < 0)
            {
                return SONG_FOLDER + path;
            }
            return "~/" + path;
        }

        /// <summary>
        /// Builds a safe file name (without extension) from the song name.
        /// </summary>
        private string BuildFileName(string songName)
        {
            string name = (songName == null) ? string.Empty : songName.Trim();
            if (name == string.Empty)
            {
                name = "cancion";
            }
            char[] invalidChars = Path.GetInvalidFileNameChars();
            for (int i = 0; i < invalidChars.Length; i++)
            {
                name = name.Replace(invalidChars[i], '-');
            }
            name = name.Replace(" ", string.Empty);
            if (name.Length > 60)
            {
                name = name.Substring(0, 60);
            }
            return name;
        }

        private int ParseId(object value)
        {
            int id;
            if (value == null || !int.TryParse(value.ToString(), out id))
            {
                return 0;
            }
            return (id > 0) ? id : 0;
        }

        private bool FileExistsOnServer(string virtualPath)
        {
            if (string.IsNullOrEmpty(virtualPath))
            {
                return false;
            }
            try
            {
                string physicalPath = Server.MapPath(virtualPath);
                return (physicalPath != null) && File.Exists(physicalPath);
            }
            catch (Exception)
            {
                return false;
            }
        }

        private void ShowFormError(string message)
        {
            litFormError.Text = "<div class=\"form-alert\">" + ICON_WARNING +
                "<span>" + HttpUtility.HtmlEncode(message) + "</span></div>";
            CloseModals();
            pnlFormModal.CssClass = "modal is-open";
        }

        private void ShowToast(string type, string message)
        {
            string title;
            string icon;
            if (type == "success")
            {
                title = "Listo";
                icon = ICON_CHECK;
            }
            else if (type == "error")
            {
                title = "Ocurrió un problema";
                icon = ICON_WARNING;
            }
            else
            {
                title = "Aviso";
                icon = ICON_INFO;
            }

            litToast.Text = "<div class=\"toast " + type + "\">" +
                "<span class=\"t-icon\">" + icon + "</span>" +
                "<div class=\"t-body\"><span class=\"t-title\">" + title + "</span>" +
                "<span class=\"t-msg\">" + HttpUtility.HtmlEncode(message) + "</span></div></div>";
        }

        /* ---------- Helpers used by the data binding expressions ---------- */

        protected string AttrEncode(object value)
        {
            if (value == null)
            {
                return string.Empty;
            }
            return HttpUtility.HtmlAttributeEncode(value.ToString()).Replace("'", "&#39;");
        }

        protected string HtmlText(object value)
        {
            if (value == null)
            {
                return string.Empty;
            }
            return HttpUtility.HtmlEncode(value.ToString());
        }

        protected string SongUrl(object songPath)
        {
            string path = (songPath == null) ? string.Empty : songPath.ToString().Trim();
            if (path == string.Empty)
            {
                return string.Empty;
            }
            return ResolveUrl(path).Replace(" ", "%20");
        }

        protected string IsAvailable(object songPath)
        {
            string path = (songPath == null) ? string.Empty : songPath.ToString();
            return FileExistsOnServer(path) ? "1" : "0";
        }

        /// <summary>
        /// Shows the file name of the song as a secondary line of the list.
        /// </summary>
        protected string FileName(object songPath)
        {
            string path = (songPath == null) ? string.Empty : songPath.ToString().Trim().Replace("\\", "/");
            if (path == string.Empty)
            {
                return "Sin archivo asociado";
            }
            int index = path.LastIndexOf('/');
            string name = (index >= 0) ? path.Substring(index + 1) : path;
            if (name == string.Empty)
            {
                return "Sin archivo asociado";
            }
            return HttpUtility.HtmlEncode(name);
        }

        protected string PlayDisabled(object songPath)
        {
            string path = (songPath == null) ? string.Empty : songPath.ToString();
            return FileExistsOnServer(path) ? string.Empty : " disabled=\"disabled\"";
        }

        protected string MissingFlag(object songPath)
        {
            string path = (songPath == null) ? string.Empty : songPath.ToString();
            if (FileExistsOnServer(path))
            {
                return string.Empty;
            }
            return "<span class=\"flag\">" + ICON_WARNING_SMALL + "Sin audio</span>";
        }

        protected string SongInitial(object songName)
        {
            string name = (songName == null) ? string.Empty : songName.ToString().Trim();
            if (name.Length == 0)
            {
                return "&#9834;";
            }
            return HttpUtility.HtmlEncode(name.Substring(0, 1).ToUpper());
        }

        protected string PlaysText(object plays)
        {
            int value;
            if (plays == null || !int.TryParse(plays.ToString(), out value))
            {
                return "0";
            }
            return value.ToString();
        }

        protected string RowNumber(int index)
        {
            int number = index + 1;
            return (number < 10) ? "0" + number : number.ToString();
        }
    }

}
