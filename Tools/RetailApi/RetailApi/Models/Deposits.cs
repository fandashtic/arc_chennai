using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Deposits
    {
        public int DepositId { get; set; }
        public int? TransactionType { get; set; }
        public DateTime? DepositDate { get; set; }
        public DateTime? CreationDate { get; set; }
        public string FullDocId { get; set; }
        public int? AccountId { get; set; }
        public int? ChequeNo { get; set; }
        public DateTime? ChequeDate { get; set; }
        public decimal? Value { get; set; }
        public string Denominations { get; set; }
        public int? StaffId { get; set; }
        public int? ChequeId { get; set; }
        public int? Status { get; set; }
        public int? WithdrawlType { get; set; }
        public int? ToAccountId { get; set; }
        public string Narration { get; set; }
    }
}
