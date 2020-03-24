using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;

namespace RetailApi
{
    public class DataUtility
    {
        public static string DataTableToJSON(DataTable table)
        {
            string jsonString = string.Empty;
            jsonString = JsonConvert.SerializeObject(table);
            return jsonString;
        }

        public static string ParamValue(string param)
        {
            if (!string.IsNullOrEmpty(param))
            {
                return param;
            }
            else
            {
                return "%";
            }
        }
    }
}
