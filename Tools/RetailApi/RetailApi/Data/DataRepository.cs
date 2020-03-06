using System;
using System.Data;
using System.Data.SqlClient;
using RetailApi.Models;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Configuration;

namespace RetailApi.Data
{
    public class DataRepository
    {
        SqlConnection connection = null;
        string sqlConnectionString = @"data source=.;initial catalog=Minerva_ARC001_2019;user id=sa;password=athena;";

        private string DataTableToJSON(DataTable table)
        {
            string jsonString = string.Empty;
            jsonString = JsonConvert.SerializeObject(table);
            return jsonString;
        }

        public string GetData(string procName, List<Parameters> parameters)
        {
            DataTable dt = new DataTable();
            try
            {
                if (!string.IsNullOrEmpty(procName))
                {
                    string commandStrings = procName;
                    using (connection = new SqlConnection(sqlConnectionString))
                    {
                        connection.Open();
                        SqlCommand cmd = new SqlCommand(commandStrings, connection)
                        {
                            CommandTimeout = 0,
                            CommandType = CommandType.StoredProcedure
                        };
                        if (parameters.Count > 0)
                        {
                            parameters.ForEach(parameter =>
                            {
                                cmd.Parameters.Add("@" + parameter.ParameterName, SqlDbType.VarChar).Value = parameter.ParameterValue;
                            });

                        }
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dt);
                        Int32.TryParse(dt.Rows[0].ItemArray[0].ToString(), out int count);
                        if (count > 0)
                        {

                        }
                        connection.Close();
                    }
                }
            }
            catch (Exception exSP)
            {
                connection = null;
            }
            finally
            {
                if (connection != null && connection.State == System.Data.ConnectionState.Open)
                {
                    connection.Close();
                }
            }
            return DataTableToJSON(dt);
        }

        public string GetData(string Command)
        {
            DataTable dt = new DataTable();
            try
            {
                if (!string.IsNullOrEmpty(Command))
                {
                    string commandStrings = "SET DATEFORMAT DMY; " + Command;
                    using (connection = new SqlConnection(sqlConnectionString))
                    {
                        connection.Open();
                        SqlCommand cmd = new SqlCommand(commandStrings, connection)
                        {
                            CommandTimeout = 0,
                            CommandType = CommandType.Text
                        };
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dt);
                        Int32.TryParse(dt.Rows[0].ItemArray[0].ToString(), out int count);
                        if (count > 0)
                        {

                        }
                        connection.Close();
                    }
                }
            }
            catch(Exception exCMD)
            {
                connection = null;
            }
            finally
            {
                if (connection != null && connection.State == System.Data.ConnectionState.Open)
                {
                    connection.Close();
                }
            }
            return DataTableToJSON(dt);
        }
    }
}
