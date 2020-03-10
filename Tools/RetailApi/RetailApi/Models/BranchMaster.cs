using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class BranchMaster
    {
        public string BranchCode { get; set; }
        public string BranchName { get; set; }
        public int? Active { get; set; }
        public string BankCode { get; set; }
    }
}
