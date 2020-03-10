using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class CollectionsReceived
    {
        public int DocSerial { get; set; }
        public string FullDocId { get; set; }
        public DateTime DocumentDate { get; set; }
        public decimal? Value { get; set; }
        public decimal? Balance { get; set; }
        public int? PaymentMode { get; set; }
        public int? ChequeNumber { get; set; }
        public DateTime? ChequeDate { get; set; }
        public string ChequeDetails { get; set; }
        public string CustomerId { get; set; }
        public int? Status { get; set; }
        public string Bank { get; set; }
        public string Branch { get; set; }
        public string Beat { get; set; }
        public DateTime? CreationTime { get; set; }
        public string DocReference { get; set; }
        public string BranchForumCode { get; set; }
        public string DocumentReference { get; set; }
    }
}
