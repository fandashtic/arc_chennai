using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class CreditNote
    {
        public int DocumentId { get; set; }
        public string CustomerId { get; set; }
        public string VendorId { get; set; }
        public decimal? NoteValue { get; set; }
        public DateTime DocumentDate { get; set; }
        public decimal? Balance { get; set; }
        public string Memo { get; set; }
        public int CreditId { get; set; }
        public int? SalesmanId { get; set; }
        public int? OriginalCreditId { get; set; }
        public int? ClientId { get; set; }
        public string DocPrefix { get; set; }
        public DateTime? CreationTime { get; set; }
        public string DocRef { get; set; }
        public int? Status { get; set; }
        public string CancelMemo { get; set; }
        public string CancelUser { get; set; }
        public DateTime? CancelledDate { get; set; }
        public int? AccountId { get; set; }
        public int? Others { get; set; }
        public string DocSerialType { get; set; }
        public string DocumentReference { get; set; }
        public int? RefDocId { get; set; }
        public int? Flag { get; set; }
        public int? AccountMode { get; set; }
        public int? PayoutId { get; set; }
        public string LoyaltyId { get; set; }
        public string GiftVoucherNo { get; set; }
        public int? ClaimRfa { get; set; }
        public DateTime? GvcollectedOn { get; set; }
        public string UserName { get; set; }
        public int? FreeSkuflag { get; set; }
        public int? Invocieid { get; set; }
    }
}
