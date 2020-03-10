using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class ServiceTypeMaster
    {
        public int Code { get; set; }
        public string ServiceAccountCode { get; set; }
        public string ServiceName { get; set; }
        public int? MapTaxId { get; set; }
        public int? InputAccId { get; set; }
        public int? OutputAccId { get; set; }
        public int? Active { get; set; }
        public DateTime? DateOfCreation { get; set; }
    }
}
