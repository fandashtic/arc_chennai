using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class CreditTerm
    {
        public int CreditId { get; set; }
        public string Description { get; set; }
        public int? Type { get; set; }
        public int? Value { get; set; }
        public int Active { get; set; }
    }
}
