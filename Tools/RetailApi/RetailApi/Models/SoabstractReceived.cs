using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class SoabstractReceived
    {
        public int Sonumber { get; set; }
        public DateTime? Sodate { get; set; }
        public DateTime? DeliveryDate { get; set; }
        public string VendorId { get; set; }
        public decimal? Value { get; set; }
        public string RefNumber { get; set; }
        public DateTime? CreationTime { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public int? Status { get; set; }
        public int? CreditTerm { get; set; }
        public string Poreference { get; set; }
        public string DocumentId { get; set; }
        public string ForumCode { get; set; }
    }
}
