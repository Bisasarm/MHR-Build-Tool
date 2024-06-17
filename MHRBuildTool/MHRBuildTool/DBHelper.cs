using Microsoft.Data.SqlClient;
using System.Data;
using System.Data.Common;

namespace MHRBuildTool
{
    public class DBHelper
    {
        public static DataTable ExecuteDataSet(string sql, CommandType cmdType, params SqlParameter[] parameters)
        {
            using (DataSet ds = new DataSet())
            using (SqlConnection connection = new SqlConnection("testconnectionString"))
            using (SqlCommand cmd = new SqlCommand(sql, connection))
            {
                cmd.CommandType = cmdType;
                foreach(SqlParameter item in parameters)
                {
                    cmd.Parameters.Add(item);
                }
                try
                {
                    cmd.Connection.Open();
                    new SqlDataAdapter(cmd).Fill(ds);
                }
                catch(SqlException ex)
                { };
                return ds.Tables[0];
            }
        }
    }
}
