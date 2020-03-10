using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class AdjustmentReturnAbstractReceived
    {
        public int AdjustmentId { get; set; }
        public string VendorId { get; set; }
        public int BillId { get; set; }
        public DateTime AdjustmentDate { get; set; }
        public int? DocumentId { get; set; }
        public string ForumId { get; set; }
        public decimal? Value { get; set; }
        public decimal? Balance { get; set; }
        public int? Status { get; set; }
        public DateTime? CreationTime { get; set; }
    }
}
