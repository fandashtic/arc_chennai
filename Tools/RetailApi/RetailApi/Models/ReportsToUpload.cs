using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class ReportsToUpload
    {
        public int ReportId { get; set; }
        public string ReportName { get; set; }
        public int? Frequency { get; set; }
        public int? ParameterId { get; set; }
        public int? CompanyId { get; set; }
        public int? ReportDataId { get; set; }
        public int? DayOfMonthWeek { get; set; }
        public string AliasActionData { get; set; }
        public int? GenOrderBy { get; set; }
        public int? SendParamValidate { get; set; }
        public int? GracePeriod { get; set; }
        public int? LatestDoc { get; set; }
        public DateTime? LastUploadDate { get; set; }
        public string AbstractData { get; set; }
        public string XmlreportCode { get; set; }
        public DateTime? Gud { get; set; }
    }
}
