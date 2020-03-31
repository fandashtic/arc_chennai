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
    public class ParametersReposidry : IParametersReposidry
    {
        ForumDbContext db;

        public ParametersReposidry(ForumDbContext _db)
        {
            db = _db;
        }

        public async Task<List<KeyValue>> GetBeatList(int salesmanId = 0)
        {
            if (db != null)
            {
                if (salesmanId > 0)
                {
                    //var beatIds = db.Database.ExecuteSqlCommandAsync(@"SELECT DISTINCT BeatID FROM Beat_salesman WITH (NOLOCK) WHERE SalesmanID = " + salesmanId.ToString());
                    //return await db.Beat.Where(w => !string.IsNullOrEmpty(w.Description) && w.BeatId).Select(i => i.Description).Distinct().ToListAsync();                    
                    return await db.Beat.Where(w => !string.IsNullOrEmpty(w.Description))
                    .Select(x => new KeyValue
                    {
                        Key = x.BeatId.ToString(),
                        Value = x.Description
                    })
                   .Distinct().ToListAsync();
                }
                else
                {
                    return await db.Beat.Where(w => !string.IsNullOrEmpty(w.Description))
                    .Select(x => new KeyValue
                    {
                        Key = x.BeatId.ToString(),
                        Value = x.Description
                    })
                   .Distinct().ToListAsync();
                }
            }

            return null;
        }

        public async Task<List<KeyValue>> GetSalesManList()
        {
            if (db != null)
            {              
                return await db.Salesman.Where(w => !string.IsNullOrEmpty(w.SalesmanName))
                    .Select(x => new KeyValue
                    {
                        Key = x.SalesmanId.ToString(),
                        Value = x.SalesmanName
                    })
                   .Distinct().ToListAsync();
            }

            return null;
        }

        public async Task<List<KeyValue>> GetCustomerList(int salesmanId = 0, int beatId = 0)
        {
            if (db != null)
            {
                if (salesmanId > 0 || beatId > 0)
                {
                    //var beatIds = db.Database.ExecuteSqlCommandAsync(@"SELECT DISTINCT BeatID FROM Beat_salesman WITH (NOLOCK) WHERE SalesmanID = " + salesmanId.ToString());
                    //return await db.Beat.Where(w => !string.IsNullOrEmpty(w.Description) && w.BeatId).Select(i => i.Description).Distinct().ToListAsync();
                    return await db.Customer.Where(w => !string.IsNullOrEmpty(w.CompanyName))
                    .Select(x => new KeyValue
                    {
                        Key = x.CustomerId,
                        Value = x.CompanyName
                    })
                   .Distinct().ToListAsync();
                }
                else
                {
                    return await db.Customer.Where(w => !string.IsNullOrEmpty(w.CompanyName))
                    .Select(x => new KeyValue
                    {
                        Key = x.CustomerId,
                        Value = x.CompanyName
                    })
                   .Distinct().ToListAsync();
                }                
            }

            return null;
        }

        public async Task<List<string>> GetVanList()
        {
            if (db != null)
            {
                return await db.InvoiceAbstract.Where(w => !string.IsNullOrEmpty(w.DocSerialType)).OrderBy(o => o.DocSerialType).Select(i => i.DocSerialType).Distinct().ToListAsync();
            }

            return null;
        }

        public async Task<List<string>> GetVehicleTypes()
        {
            if (db != null)
            {
                List<string> VehicleTypes = new List<string>();
                VehicleTypes.Add("SELF");
                VehicleTypes.Add("TN01AJ8915");
                VehicleTypes.Add("TN05AU2342");
                VehicleTypes.Add("TN12Q5058");
                VehicleTypes.Add("TN22DC1397");
                VehicleTypes.Add("TN58AR7296");
                VehicleTypes.Add("TN66AB9203");
                VehicleTypes.Add("TN66AB9208");
                VehicleTypes.Add("TN66AB9219");
                VehicleTypes.Add("TN66AB9220");
                VehicleTypes.Add("TN66AB9235");
                VehicleTypes.Add("TN66AB9256");
                VehicleTypes.Add("TN66AB9265");
                VehicleTypes.Add("TN66AB9277");
                VehicleTypes.Add("TN66AB9280");
                VehicleTypes.Add("TN66Y5494");
                VehicleTypes.Add("TN99J5661");
                return VehicleTypes; // db.VehicleTypes.Where(w => !string.IsNullOrEmpty(w.VehicleType)).Select(i => i.VehicleType).Distinct().ToListAsync();
            }

            return null;
        }

        public async Task<List<KeyValue>> GetItemsList()
        {
            if (db != null)
            {
                return await db.Items.Where(w => !string.IsNullOrEmpty(w.ProductName))
                     .Select(x => new KeyValue
                     {
                         Key = x.ProductCode,
                         Value = x.ProductName
                     })
                    .Distinct().ToListAsync();
            }

            return null;
        }

        public async Task<string> GetQueryParams(string querry)
        {
            if (db != null)
            {
                string cmd = string.Empty;
                if (!string.IsNullOrEmpty(querry))
                {
                    string[] querrys = querry.Split(":").ToArray();
                    if (querrys.Count() == 3)
                    {
                        cmd = "SELECT DISTINCT " + querrys[1] + "[value] FROM " + querrys[0] + " WITH (NOLOCK)" + (!string.IsNullOrEmpty(IsValidQuery(querrys[2])) ? " WHERE " + IsValidQuery(querrys[2]) : "");
                    }
                    if (querrys.Count() == 2)
                    {
                        cmd = "SELECT DISTINCT " + querrys[1] + "[value] FROM " + querrys[0] + " WITH (NOLOCK)";
                    }
                    if (!string.IsNullOrEmpty(cmd))
                    {
                        DataRepository dataRepository = new DataRepository();
                        return await dataRepository.GetData(cmd);
                    }
                }                
            }
            return null;
        }

        private string IsValidQuery(string querry)
        {
            if(querry.Contains("-1") || querry.Contains("+1"))
            {
                return "";
            }
            return querry;
        }

    }
}
