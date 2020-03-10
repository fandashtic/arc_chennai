using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class ClaimsNote
    {
        public int ClaimId { get; set; }
        public string VendorId { get; set; }
        public DateTime? ClaimDate { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Status { get; set; }
        public int? DocumentId { get; set; }
        public int? ClaimType { get; set; }
        public int? OriginalClaim { get; set; }
        public int? ClientId { get; set; }
        public decimal? ClaimValue { get; set; }
        public int? SettlementType { get; set; }
        public DateTime? SettlementDate { get; set; }
        public decimal? SettlementValue { get; set; }
        public string DocumentReference { get; set; }
        public decimal? Balance { get; set; }
        public string Remarks { get; set; }
        public string Cancelusername { get; set; }
        public DateTime? CancelDate { get; set; }
        public string CompanyCreditNoteNo { get; set; }
        public decimal? TaxAmount { get; set; }
        public int? ClaimRfa { get; set; }
    }
}
