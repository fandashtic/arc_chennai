using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TaxApplicableOn
    {
        public int ApplicableOnCode { get; set; }
        public string ApplicableOnDesc { get; set; }
        public DateTime CreationDate { get; set; }
    }
}
