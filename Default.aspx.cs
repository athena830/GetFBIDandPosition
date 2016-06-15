using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GetFBIDandPosition
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        [ScriptMethod]
        public static string GetFBLocation()
        {
            var cmd = new SqlCommand();
            cmd.CommandText = @"
                SELECT top 1 * FROM FB_location WHERE CE_COMPLETE = 0
            ";
            DataTable dt = Persister.Execute(cmd);
            return JsonSerialize(dt);
        }

        [WebMethod]
        [ScriptMethod]
        public static void UpdFBLocation(string id)
        {
            var cmd = new SqlCommand();
            cmd.CommandText = @"
                Update FB_location set CE_COMPLETE = 1 WHERE CE_ID=@id
            ";
            cmd.Parameters.Add("@id", SqlDbType.NVarChar).Value = id;
            Persister.ExecuteNonQuery(cmd);
        }
        
        [WebMethod]
        [ScriptMethod]
        public static void DelFBPlace(Dictionary<string, object> data)
        {
            var cmd = new SqlCommand();
            cmd.CommandText = @"
                delete from FB_place where type=@type
            ";
            cmd.Parameters.Add("@type", SqlDbType.NVarChar).Value = data["type"].ToString();
            Persister.ExecuteNonQuery(cmd);
        }

        [WebMethod]
        [ScriptMethod]
        public static void AddFBPlace(Dictionary<string, object> data)
        {
            //假如沒接收過
            var id = data["id"].ToString();
            if (!isExist(id))
            {
                insertFBPlace(data);
            }
            //System.Threading.Thread.Sleep(1500);
        }

        /// <summary>
        /// 記錄 FB ID&位置
        /// </summary>
        private static bool isExist(string id)
        {
            var cmd = new SqlCommand();
            cmd.CommandText = @"
                select top 1 id from FB_place where id=@id
            ";
            cmd.Parameters.Add("@id", SqlDbType.NVarChar).Value = id;
            DataTable theTable = Persister.Execute(cmd);

            if (theTable.Rows.Count > 0)
                return true;
            else
                return false;
        }

        /// <summary>
        /// 記錄 FB ID&位置
        /// </summary>
        private static void insertFBPlace(Dictionary<string, object> data)
        {
            var cmd = new SqlCommand();
            cmd.CommandText = @"
                insert into FB_place 
                (
                    id,
                    name, type, category, checkins, likes, talking_about_count,
                    were_here_count, location, country,
                    parking, geom_location, longitude, latitude
                ) values (
                    @id,
                    @name, @type, @category, @checkins, @likes, @talking_about_count,
                    @were_here_count, @location, @country,
                    @parking, @geom_location, @longitude, @latitude
                )";

            string location = JsonConvert.SerializeObject(data["location"]);
            cmd.Parameters.Add("@id", SqlDbType.NVarChar).Value = data["id"].ToString();
            cmd.Parameters.Add("@name", SqlDbType.NVarChar).Value = data["name"].ToString();
            cmd.Parameters.Add("@type", SqlDbType.NVarChar).Value = data["type"].ToString();
            cmd.Parameters.Add("@category", SqlDbType.NVarChar).Value = data["category"].ToString();
            cmd.Parameters.Add("@checkins", SqlDbType.SmallInt).Value = Int32.Parse(data["checkins"].ToString());
            cmd.Parameters.Add("@likes", SqlDbType.SmallInt).Value = Int32.Parse(data["likes"].ToString());
            cmd.Parameters.Add("@talking_about_count", SqlDbType.SmallInt).Value = Int32.Parse(data["talking_about_count"].ToString());
            cmd.Parameters.Add("@were_here_count", SqlDbType.SmallInt).Value = Int32.Parse(data["were_here_count"].ToString());
            cmd.Parameters.Add("@country", SqlDbType.NVarChar).Value = data["country"].ToString();
            cmd.Parameters.Add("@location", SqlDbType.NVarChar).Value = location;
            cmd.Parameters.Add("@parking", SqlDbType.NVarChar).Value = data["parking"].ToString();
            cmd.Parameters.Add("@geom_location", SqlDbType.NVarChar).Value = data["geom_location"].ToString();
            cmd.Parameters.Add("@longitude", SqlDbType.NVarChar).Value = data["longitude"].ToString();
            cmd.Parameters.Add("@latitude", SqlDbType.NVarChar).Value = data["latitude"].ToString();
            Persister.ExecuteNonQuery(cmd);
        }

        private static string JsonSerialize(DataTable dt)
        {
            string json = JsonConvert.SerializeObject(dt, Formatting.Indented);
            return json;
        }
    }
}