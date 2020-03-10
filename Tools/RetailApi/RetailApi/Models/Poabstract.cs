using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Poabstract
    {
        public int Ponumber { get; set; }
        public DateTime? Podate { get; set; }
        public string VendorId { get; set; }
        public DateTime? RequiredDate { get; set; }
        public decimal? Value { get; set; }
        public DateTime? CreationTime { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public int? Status { get; set; }
        public int? CreditTerm { get; set; }
        public int? Grnid { get; set; }
        public int? Poreference { get; set; }
        public int? ClientId { get; set; }
        public int? OriginalPo { get; set; }
        public int? DocumentId { get; set; }
        public int? NewGrnid { get; set; }
        public int? DocumentReference { get; set; }
        public string Remarks { get; set; }
        public string CancelUserName { get; set; }
        public DateTime? CancelDate { get; set; }
        public string Reference { get; set; }
        public string DocRef { get; set; }
        public int? BrandId { get; set; }
        public int? Poidreference { get; set; }
    }
}
