using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class DispatchAbstract
    {
        public int DispatchId { get; set; }
        public string RefNumber { get; set; }
        public DateTime? DispatchDate { get; set; }
        public string CustomerId { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public DateTime? CreationTime { get; set; }
        public int? InvoiceId { get; set; }
        public int? Status { get; set; }
        public int? DocumentId { get; set; }
        public string NewRefNumber { get; set; }
        public int? NewInvoiceId { get; set; }
        public int? OriginalDispatch { get; set; }
        public int? ClientId { get; set; }
        public string Memo1 { get; set; }
        public string Memo2 { get; set; }
        public string Memo3 { get; set; }
        public string MemoLabel1 { get; set; }
        public string MemoLabel2 { get; set; }
        public string MemoLabel3 { get; set; }
        public string Remarks { get; set; }
        public int? OriginalReference { get; set; }
        public string Cancelusername { get; set; }
        public DateTime? CancelDate { get; set; }
        public string DocRef { get; set; }
        public string DocSerialType { get; set; }
        public string GroupId { get; set; }
        public int? SalesmanId { get; set; }
        public int? BeatId { get; set; }
        public string UserName { get; set; }
    }
}
