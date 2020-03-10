using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class VanStatementDetail
    {
        public int Id { get; set; }
        public int DocSerial { get; set; }
        public string ProductCode { get; set; }
        public int? BatchCode { get; set; }
        public string BatchNumber { get; set; }
        public decimal? Quantity { get; set; }
        public decimal? Pending { get; set; }
        public decimal? SalePrice { get; set; }
        public decimal? Amount { get; set; }
        public decimal? PurchasePrice { get; set; }
        public decimal? Bfqty { get; set; }
        public decimal? Pts { get; set; }
        public decimal? Ptr { get; set; }
        public decimal? Ecp { get; set; }
        public decimal? SpecialPrice { get; set; }
        public int? Uom { get; set; }
        public decimal? Uomqty { get; set; }
        public decimal? Uomprice { get; set; }
        public decimal? TransferQty { get; set; }
        public int? VanTransferId { get; set; }
        public int? TransferItemSerial { get; set; }
        public string MultipleSchemeId { get; set; }
        public decimal? MrpperPack { get; set; }
    }
}
