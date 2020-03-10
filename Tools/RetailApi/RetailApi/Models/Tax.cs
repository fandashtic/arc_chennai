using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Tax
    {
        public int TaxCode { get; set; }
        public string TaxDescription { get; set; }
        public decimal? Percentage { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Active { get; set; }
        public decimal? CstPercentage { get; set; }
        public int? LstapplicableOn { get; set; }
        public decimal? LstpartOff { get; set; }
        public int? CstapplicableOn { get; set; }
        public decimal? CstpartOff { get; set; }
        public int? CsTaxCode { get; set; }
        public DateTime? EffectiveFrom { get; set; }
        public int? Gstflag { get; set; }
    }
}
