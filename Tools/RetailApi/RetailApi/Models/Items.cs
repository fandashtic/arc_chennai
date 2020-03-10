using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Items
    {
        public string ProductCode { get; set; }
        public string ProductName { get; set; }
        public DateTime? CreationDate { get; set; }
        public string Description { get; set; }
        public int? CategoryId { get; set; }
        public int? ManufacturerId { get; set; }
        public int? BrandId { get; set; }
        public int? Uom { get; set; }
        public decimal? PurchasePrice { get; set; }
        public decimal? SalePrice { get; set; }
        public int? SaleTax { get; set; }
        public decimal? Mrp { get; set; }
        public string PreferredVendor { get; set; }
        public decimal? StockNorm { get; set; }
        public decimal? MinOrderQty { get; set; }
        public int? TrackBatches { get; set; }
        public decimal? OpeningStock { get; set; }
        public decimal? OpeningStockValue { get; set; }
        public int? SchemeId { get; set; }
        public decimal? ConversionFactor { get; set; }
        public int? ConversionUnit { get; set; }
        public int? Active { get; set; }
        public decimal? OrderQty { get; set; }
        public int? SaleId { get; set; }
        public decimal? CompanyPrice { get; set; }
        public decimal? Pts { get; set; }
        public decimal? Ptr { get; set; }
        public decimal? Ecp { get; set; }
        public int? PurchasedAt { get; set; }
        public decimal? CompanyMargin { get; set; }
        public decimal? StockistMargin { get; set; }
        public decimal? RetailerMargin { get; set; }
        public int? TaxSuffered { get; set; }
        public string SoldAs { get; set; }
        public string Alias { get; set; }
        public int? ReportingUom { get; set; }
        public decimal? ReportingUnit { get; set; }
        public int? TrackPkd { get; set; }
        public int? VirtualTrackBatches { get; set; }
        public string SupplyingBranch { get; set; }
        public decimal? PendingRequest { get; set; }
        public int? Uom1 { get; set; }
        public int? Uom2 { get; set; }
        public decimal? Uom1Conversion { get; set; }
        public decimal? Uom2Conversion { get; set; }
        public int? DefaultUom { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int? ItemCombo { get; set; }
        public int? TrackInventoryCombo { get; set; }
        public int? ComboId { get; set; }
        public int? TaxInclusive { get; set; }
        public decimal? TaxInclusiveRate { get; set; }
        public int? Flags { get; set; }
        public string Hyperlink { get; set; }
        public int? Exciseduty { get; set; }
        public decimal? Adhocamount { get; set; }
        public int? PriceatUomlevel { get; set; }
        public int? Vat { get; set; }
        public int? CollectTaxSuffered { get; set; }
        public string UserDefinedCode { get; set; }
        public int? CaseUom { get; set; }
        public decimal? CaseConversion { get; set; }
        public decimal? Pfm { get; set; }
        public string EanNumber { get; set; }
        public decimal? MrpperPack { get; set; }
        public int? Asl { get; set; }
        public int ToqPurchase { get; set; }
        public int ToqSales { get; set; }
        public int? CategorizationId { get; set; }
        public string Hsnnumber { get; set; }
        public int? FreeSkuflag { get; set; }
    }
}
