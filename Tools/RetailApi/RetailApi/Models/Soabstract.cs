using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Soabstract
    {
        public int Sonumber { get; set; }
        public DateTime? Sodate { get; set; }
        public DateTime? DeliveryDate { get; set; }
        public string CustomerId { get; set; }
        public decimal? Value { get; set; }
        public string RefNumber { get; set; }
        public DateTime? CreationTime { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public int? Status { get; set; }
        public int? CreditTerm { get; set; }
        public string Poreference { get; set; }
        public int? ClientId { get; set; }
        public int? OriginalSo { get; set; }
        public DateTime? PaymentDate { get; set; }
        public int? DocumentId { get; set; }
        public string PodocReference { get; set; }
        public string Remarks { get; set; }
        public int? SalesmanId { get; set; }
        public string Cancelusername { get; set; }
        public DateTime? CancelDate { get; set; }
        public string BranchCode { get; set; }
        public int? TaxOnMrp { get; set; }
        public string DocSerialType { get; set; }
        public string DocumentReference { get; set; }
        public int? SoRef { get; set; }
        public int? BeatId { get; set; }
        public decimal? VattaxAmount { get; set; }
        public int? SalesVisitNumber { get; set; }
        public string GroupId { get; set; }
        public int? ForumSc { get; set; }
        public int? SupervisorId { get; set; }
        public string UserName { get; set; }
        public int? FromStateCode { get; set; }
        public int? ToStateCode { get; set; }
        public string Gstin { get; set; }
        public int? Gstflag { get; set; }
        public int OrderType { get; set; }
    }
}
