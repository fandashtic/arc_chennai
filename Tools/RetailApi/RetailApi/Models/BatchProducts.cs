using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class BatchProducts
    {
        public int BatchCode { get; set; }
        public string BatchNumber { get; set; }
        public string ProductCode { get; set; }
        public int? GrnId { get; set; }
        public DateTime? Expiry { get; set; }
        public decimal Quantity { get; set; }
        public decimal PurchasePrice { get; set; }
        public int PurchaseTax { get; set; }
        public decimal? SalePrice { get; set; }
        public int? TaxCode { get; set; }
        public decimal? Pts { get; set; }
        public decimal? Ptr { get; set; }
        public decimal? Ecp { get; set; }
        public decimal? QuantityReceived { get; set; }
        public decimal? CompanyPrice { get; set; }
        public int? Flags { get; set; }
        public int? OriginalBatch { get; set; }
        public int? ClientId { get; set; }
        public int? Damage { get; set; }
        public int? DamagesReason { get; set; }
        public DateTime? Pkd { get; set; }
        public decimal? ClaimedAlready { get; set; }
        public int? Free { get; set; }
        public int? StockTransferId { get; set; }
        public int? BatchReference { get; set; }
        public decimal? TaxSuffered { get; set; }
        public int? Uom { get; set; }
        public decimal? Uomqty { get; set; }
        public decimal? Uomprice { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? StkAdj { get; set; }
        public int? ComboId { get; set; }
        public int? TaxOnMrp { get; set; }
        public int? Promotion { get; set; }
        public int? DocType { get; set; }
        public int? DocId { get; set; }
        public decimal? ExciseDuty { get; set; }
        public int? ExciseId { get; set; }
        public decimal? GrntaxSuffered { get; set; }
        public int? GrntaxId { get; set; }
        public int? GrnapplicableOn { get; set; }
        public decimal? GrnpartOff { get; set; }
        public int? Applicableon { get; set; }
        public decimal? Partofpercentage { get; set; }
        public int? VatLocality { get; set; }
        public int? Serial { get; set; }
        public int? ReceInvItemOrder { get; set; }
        public decimal? OrgPts { get; set; }
        public int? StockReconId { get; set; }
        public int? TaxType { get; set; }
        public decimal? Pfm { get; set; }
        public decimal? MrpforTax { get; set; }
        public DateTime? DocDate { get; set; }
        public decimal? MrpperPack { get; set; }
        public int? Toq { get; set; }
        public int? GsttaxType { get; set; }
        public int? MarginDetId { get; set; }
        public decimal? MarginPerc { get; set; }
        public decimal? MarginOn { get; set; }
        public decimal? MarginAddOn { get; set; }
    }
}
