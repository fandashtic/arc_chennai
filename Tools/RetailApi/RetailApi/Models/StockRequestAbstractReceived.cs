using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class StockRequestAbstractReceived
    {
        public int StkReqNumber { get; set; }
        public DateTime? StkReqDate { get; set; }
        public string CustomerId { get; set; }
        public DateTime? RequiredDate { get; set; }
        public decimal? Value { get; set; }
        public DateTime? CreationTime { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public int? Status { get; set; }
        public int? StkReqReference { get; set; }
        public int? DocumentId { get; set; }
        public string StkReqPrefix { get; set; }
        public string ForumCode { get; set; }
    }
}
