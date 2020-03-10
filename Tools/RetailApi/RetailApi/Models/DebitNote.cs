using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class DebitNote
    {
        public int DocumentId { get; set; }
        public string CustomerId { get; set; }
        public string VendorId { get; set; }
        public decimal? NoteValue { get; set; }
        public DateTime DocumentDate { get; set; }
        public decimal? Balance { get; set; }
        public string Memo { get; set; }
        public int DebitId { get; set; }
        public int? SalesmanId { get; set; }
        public int? OriginalDebitId { get; set; }
        public int? ClientId { get; set; }
        public int? Flag { get; set; }
        public DateTime? CreationTime { get; set; }
        public string DocRef { get; set; }
        public string Reference { get; set; }
        public int? Status { get; set; }
        public string CancelMemo { get; set; }
        public string CancelUser { get; set; }
        public DateTime? CancelledDate { get; set; }
        public int? AccountId { get; set; }
        public int? Others { get; set; }
        public string DocSerialType { get; set; }
        public string DocumentReference { get; set; }
        public int? RefDocId { get; set; }
        public int? AccountMode { get; set; }
        public string UserName { get; set; }
    }
}
