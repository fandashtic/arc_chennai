using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class StockTransferInAbstract
    {
        public int DocSerial { get; set; }
        public int DocumentId { get; set; }
        public DateTime DocumentDate { get; set; }
        public string WareHouseId { get; set; }
        public decimal? NetValue { get; set; }
        public int? Status { get; set; }
        public string DocReference { get; set; }
        public string ReferenceSerial { get; set; }
        public string Address { get; set; }
        public string UserName { get; set; }
        public DateTime? CreationDate { get; set; }
        public string Reference { get; set; }
        public string DocPrefix { get; set; }
        public decimal? TaxAmount { get; set; }
        public string Remarks { get; set; }
        public string CancelUser { get; set; }
        public int? TaxOnMrp { get; set; }
        public decimal? VatTaxAmount { get; set; }
        public string StiLrNo { get; set; }
        public string StiTranInfo { get; set; }
        public string StiNarration { get; set; }
        public DateTime? StiRecDate { get; set; }
        public int? TaxType { get; set; }
        public DateTime? CancellationDate { get; set; }
        public int? Gstflag { get; set; }
        public int? StateType { get; set; }
        public int? FromStatecode { get; set; }
        public int? ToStatecode { get; set; }
        public string Gstin { get; set; }
    }
}
