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
                return await db.InvoiceAbstract.Where(w => !string.IsNullOrEmpty(w.DocSerialType)).Select(i => i.DocSerialType).Distinct().ToListAsync();
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
    }
}
