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
    public class DeliveryReposidry : IDeliveryReposidry
    {
        ForumDbContext db;

        public DeliveryReposidry(ForumDbContext _db)
        {
            db = _db;
        }

        public async Task<List<string>> GetVanList()
        {
            if (db != null)
            {
                return await db.InvoiceAbstract.Where(w => !string.IsNullOrEmpty(w.DocSerialType)).Select(i => i.DocSerialType).Distinct().ToListAsync();
            }

            return null;
        }
    }
}
