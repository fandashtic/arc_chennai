using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RetailApi.Models;

namespace RetailApi.Data
{
    public interface IReportReposidry
    {
        Task<List<ReportData>> GetAllReports();
        Task<List<ReportData>> GetReportsById(int reportId);
    }
}
