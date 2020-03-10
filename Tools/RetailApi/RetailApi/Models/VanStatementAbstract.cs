using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class VanStatementAbstract
    {
        public int DocSerial { get; set; }
        public int DocumentId { get; set; }
        public DateTime DocumentDate { get; set; }
        public int? SalesmanId { get; set; }
        public int? BeatId { get; set; }
        public decimal? DocumentValue { get; set; }
        public string VanId { get; set; }
        public int? Status { get; set; }
        public int? OriginalClientId { get; set; }
        public int? ClientDocSerial { get; set; }
        public string DocPrefix { get; set; }
        public DateTime? CreationTime { get; set; }
        public DateTime? LoadingDate { get; set; }
        public string UserName { get; set; }
    }
}
