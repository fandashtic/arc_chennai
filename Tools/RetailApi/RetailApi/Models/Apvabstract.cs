using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Apvabstract
    {
        public int DocumentId { get; set; }
        public int? Apvid { get; set; }
        public DateTime? Apvdate { get; set; }
        public int? PartyAccountId { get; set; }
        public string BillNo { get; set; }
        public DateTime? BillDate { get; set; }
        public decimal? BillAmount { get; set; }
        public decimal? AmountApproved { get; set; }
        public int? OtherAccountId { get; set; }
        public decimal? OtherValue { get; set; }
        public int? Expensefor { get; set; }
        public int? Approvedby { get; set; }
        public string Apvremarks { get; set; }
        public int? Status { get; set; }
        public DateTime? CreationTime { get; set; }
        public decimal? Balance { get; set; }
        public int? RefDocId { get; set; }
        public string DocumentReference { get; set; }
        public string DocSerialType { get; set; }
        public string CancellationRemarks { get; set; }
    }
}
