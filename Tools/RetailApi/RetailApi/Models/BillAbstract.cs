using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class BillAbstract
    {
        public int BillId { get; set; }
        public string Grnid { get; set; }
        public DateTime? BillDate { get; set; }
        public string VendorId { get; set; }
        public string Username { get; set; }
        public decimal? Value { get; set; }
        public DateTime? CreationTime { get; set; }
        public int? Status { get; set; }
        public string InvoiceReference { get; set; }
        public int? BillReference { get; set; }
        public int? DocumentId { get; set; }
        public string NewGrnid { get; set; }
        public int? DocumentReference { get; set; }
        public int? OriginalBill { get; set; }
        public int? ClientId { get; set; }
        public decimal? TaxAmount { get; set; }
        public decimal? AdjustmentAmount { get; set; }
        public decimal? Balance { get; set; }
        public decimal? Discount { get; set; }
        public int? DiscountOption { get; set; }
        public string AdjRef { get; set; }
        public decimal? AdjustedAmount { get; set; }
        public int? PaymentId { get; set; }
        public string Remarks { get; set; }
        public int? CreditTerm { get; set; }
        public DateTime? PaymentDate { get; set; }
        public int? Flags { get; set; }
        public string CancelUserName { get; set; }
        public DateTime? CancelDate { get; set; }
        public int? TaxOnMrp { get; set; }
        public string DocIdreference { get; set; }
        public string DocSerialType { get; set; }
        public decimal? AdjustmentValue { get; set; }
        public decimal? ExciseDuty { get; set; }
        public int? DiscountBeforeExcise { get; set; }
        public int? PurchasePriceBeforeExcise { get; set; }
        public int? FapaymentId { get; set; }
        public decimal? VattaxAmount { get; set; }
        public decimal? OctroiAmount { get; set; }
        public decimal? Freight { get; set; }
        public decimal? AddlDiscountPercentage { get; set; }
        public decimal? AddlDiscountAmount { get; set; }
        public decimal? ProductDiscount { get; set; }
        public decimal? Surcharge { get; set; }
        public int? TaxDiscountFlag { get; set; }
        public int? TaxType { get; set; }
        public int? Gstflag { get; set; }
        public int? StateType { get; set; }
        public int? FromStatecode { get; set; }
        public int? ToStatecode { get; set; }
        public string Gstin { get; set; }
        public int? GstenableFlag { get; set; }
        public string Odnumber { get; set; }
    }
}
