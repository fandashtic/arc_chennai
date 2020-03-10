using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Areas
    {
        public int AreaId { get; set; }
        public string Area { get; set; }
        public int? Active { get; set; }
        public int? PreDefFlag { get; set; }
    }
}
