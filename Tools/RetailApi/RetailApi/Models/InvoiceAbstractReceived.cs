using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class InvoiceAbstractReceived
    {
        public int InvoiceId { get; set; }
        public int? InvoiceType { get; set; }
        public DateTime? InvoiceDate { get; set; }
        public DateTime? InvoiceTime { get; set; }
        public string VendorId { get; set; }
        public string UserName { get; set; }
        public decimal? GrossValue { get; set; }
        public decimal? DiscountPercentage { get; set; }
        public decimal? DiscountValue { get; set; }
        public decimal? NetValue { get; set; }
        public DateTime? CreationTime { get; set; }
        public int? Status { get; set; }
        public string TaxLocation { get; set; }
        public decimal? AdditionalDiscount { get; set; }
        public decimal? Freight { get; set; }
        public int? CreditTerm { get; set; }
        public string Reference { get; set; }
        public string DocumentId { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public string ForumCode { get; set; }
        public string PoserialNumber { get; set; }
        public DateTime? Podate { get; set; }
        public decimal? NetTaxAmount { get; set; }
        public decimal? AdjustedAmount { get; set; }
        public DateTime? PaymentDate { get; set; }
        public string AdjustmentDocReference { get; set; }
        public decimal? NetAmountAfterAdjustment { get; set; }
        public decimal? AdditionalDiscountAmount { get; set; }
        public decimal? ExciseDuty { get; set; }
        public int? DiscountBeforeExcise { get; set; }
        public int? SalePriceBeforeExcise { get; set; }
        public decimal? OctroiAmount { get; set; }
        public decimal? AddlDiscountPercentage { get; set; }
        public decimal? AddlDiscountAmount { get; set; }
        public decimal? ProductDiscount { get; set; }
        public string TaxType { get; set; }
        public int? RecdXmlackDocId { get; set; }
        public int? Gstflag { get; set; }
        public int? StateType { get; set; }
        public int? FromStatecode { get; set; }
        public int? ToStatecode { get; set; }
        public string Gstin { get; set; }
        public string Odnumber { get; set; }
    }
}
