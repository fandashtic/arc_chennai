using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class SpecialCategory
    {
        public int SpecialCatCode { get; set; }
        public int? CategoryType { get; set; }
        public string Description { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? SchemeId { get; set; }
        public int? Active { get; set; }
    }
}
