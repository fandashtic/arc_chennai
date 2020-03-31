using System;
using System.Data;
using System.Data.SqlClient;
using RetailApi.Models;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Configuration;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace RetailApi.Data
{
    public class DataRepository : IDataRepository
    {
        SqlConnection connection = null;
        private readonly string sqlConnectionString = @"data source=.;initial catalog=Minerva_ARC001_2019;user id=sa;password=athena;";
        ForumDbContext db;

        public DataRepository()
        {
           
        }

        public DataRepository(ForumDbContext _db)
        {
            db = _db;
        }
        

        public async Task<string> GetData(string procName, List<Parameters> parameters)
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
                            List<KeyValue> _parameterNames = GetProcedureParameters(procName);
                            //int i = 0;
                            for (int i = 0; i < parameters.Count; i++)
                            {
                                cmd.Parameters.Add(_parameterNames.Where(s => s.Key == (i+1).ToString()).Select(a => a.Value).FirstOrDefault(), SqlDbType.VarChar).Value = parameters[i].ParameterValue;                                
                            } 
                            //parameters.ForEach(parameter =>
                            //{
                            //    cmd.Parameters.Add(GetIndexedParameterName(_parameterNames, i), SqlDbType.VarChar).Value = parameter.ParameterValue;
                            //    i++;
                            //});

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
            catch (Exception ex)
            {
                var er = ex.Message;
                connection = null;
            }
            finally
            {
                if (connection != null && connection.State == System.Data.ConnectionState.Open)
                {
                    connection.Close();
                }
            }
            return DataUtility.DataTableToJSON(dt);
        }

        public async Task<string> GetData(string Command)
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
            return DataUtility.DataTableToJSON(dt);
        }

        private List<KeyValue> GetProcedureParameters(string procedure)
        {
            DataTable dt = new DataTable();
            List<KeyValue> parameters = new List<KeyValue>();
            try
            {
                if (!string.IsNullOrEmpty(procedure))
                {
                    string commandStrings = "SELECT ORDINAL_POSITION, PARAMETER_NAME FROM INFORMATION_SCHEMA.PARAMETERS WITH (NOLOCK) WHERE SPECIFIC_NAME='" + procedure + "'";
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
                        //Int32.TryParse(dt.Rows[0].ItemArray[0].ToString(), out int count);
                        //if (count > 0)
                        //{
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                            parameters.Add(
                                new KeyValue()
                                {
                                    Key = dt.Rows[i]["ORDINAL_POSITION"].ToString(),
                                    Value = dt.Rows[i]["PARAMETER_NAME"].ToString()
                                });                                
                            }
                        //}
                        connection.Close();
                    }
                }
            }
            catch (Exception exCMD)
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
            return parameters;
        }

        private string GetIndexedParameterName(List<string> names, int index)
        {
            int i = 0;
            string parameterName = string.Empty;
            names.ForEach(name => {
                if(i == index)
                {
                    parameterName = name;
                }
                i++;
            });
            return parameterName;
        }
    }
}
