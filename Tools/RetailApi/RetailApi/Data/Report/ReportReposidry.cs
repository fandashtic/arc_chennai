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
    public class ReportReposidry : IReportReposidry
    {
        ForumDbContext db;

        public ReportReposidry(ForumDbContext _db)
        {
            db = _db;
        }

        public async Task<List<ReportData>> GetAllReports()
        {
            if (db != null)
            {
                return await db.ReportData.ToListAsync();
            }

            return null;
        }

        public async Task<List<ReportData>> GetReportsById(int reportId)
        {
            if (db != null)
            {
                return await db.ReportData.Where(p => p.Parent == reportId).ToListAsync();
            }

            return null;
        }
    }
}

