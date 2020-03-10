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
    public class AdministrationReposidry : IAdministrationReposidry
    {
        ForumDbContext db;

        public AdministrationReposidry(ForumDbContext _db)
        {
            db = _db;
        }

        public async Task<List<Users>> GetUsers()
        {
            if (db != null)
            {
                return await db.Users.ToListAsync();
            }

            return null;
        }
    }
}
