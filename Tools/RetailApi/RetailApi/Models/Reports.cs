using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Reports
    {
        public int ReportId { get; set; }
        public string ReportName { get; set; }
        public string CompanyId { get; set; }
        public int? ParameterId { get; set; }
        public DateTime CreationDate { get; set; }
        public int? AbstractCols { get; set; }
        public int? DetailCols { get; set; }
        public DateTime? ReportDate { get; set; }
        public int? ReportNo { get; set; }
    }
}
