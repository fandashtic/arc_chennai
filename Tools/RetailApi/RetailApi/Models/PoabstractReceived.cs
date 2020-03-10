using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class PoabstractReceived
    {
        public int Ponumber { get; set; }
        public DateTime? Podate { get; set; }
        public string CustomerId { get; set; }
        public DateTime? RequiredDate { get; set; }
        public decimal? Value { get; set; }
        public DateTime? CreationTime { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public int? Status { get; set; }
        public int? Poreference { get; set; }
        public int? DocumentId { get; set; }
        public string Poprefix { get; set; }
        public string ForumCode { get; set; }
        public string BranchForumCode { get; set; }
        public string Salesmanname { get; set; }
        public int? Salesmanid { get; set; }
    }
}
