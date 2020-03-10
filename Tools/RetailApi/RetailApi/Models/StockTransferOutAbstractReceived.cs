using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class StockTransferOutAbstractReceived
    {
        public int DocSerial { get; set; }
        public int DocumentId { get; set; }
        public DateTime DocumentDate { get; set; }
        public string WareHouseId { get; set; }
        public decimal? NetValue { get; set; }
        public int? Status { get; set; }
        public string ForumCode { get; set; }
        public string OriginalId { get; set; }
        public DateTime? CreationDate { get; set; }
        public decimal? TaxAmount { get; set; }
        public string Reference { get; set; }
        public int? OriginalStockRequest { get; set; }
    }
}
