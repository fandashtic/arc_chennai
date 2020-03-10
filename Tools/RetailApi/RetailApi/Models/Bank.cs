using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Bank
    {
        public int BankId { get; set; }
        public string BankName { get; set; }
        public int? Active { get; set; }
        public string AccountName { get; set; }
        public string AccountNumber { get; set; }
        public string Branch { get; set; }
        public string BankCode { get; set; }
        public string BranchCode { get; set; }
        public int? ClientId { get; set; }
        public int? OriginalId { get; set; }
        public int? AccountId { get; set; }
        public decimal? ServiceChargePercentage { get; set; }
        public int? RealisationType { get; set; }
    }
}
