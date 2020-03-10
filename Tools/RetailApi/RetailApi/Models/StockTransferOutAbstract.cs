using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class StockTransferOutAbstract
    {
        public int DocSerial { get; set; }
        public int DocumentId { get; set; }
        public DateTime DocumentDate { get; set; }
        public string WareHouseId { get; set; }
        public decimal? NetValue { get; set; }
        public int? Status { get; set; }
        public string Address { get; set; }
        public string UserName { get; set; }
        public DateTime? CreationDate { get; set; }
        public string Reference { get; set; }
        public string DocPrefix { get; set; }
        public decimal? TaxAmount { get; set; }
        public int? OriginalStockRequest { get; set; }
        public int? StockRequestNo { get; set; }
        public int? Stoidref { get; set; }
        public string StodocIdref { get; set; }
        public string CancelRemarks { get; set; }
        public string CancelUser { get; set; }
        public int? TaxOnMrp { get; set; }
        public decimal? VatTaxAmount { get; set; }
        public string StoLrNo { get; set; }
        public string StoTranInfo { get; set; }
        public string StoNarration { get; set; }
        public DateTime? CancellationDate { get; set; }
        public int? Gstflag { get; set; }
    }
}
