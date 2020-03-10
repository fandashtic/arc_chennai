using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class BankMaster
    {
        public string BankCode { get; set; }
        public string BankName { get; set; }
        public int? Active { get; set; }
    }
}
