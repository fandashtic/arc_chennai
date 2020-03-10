using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Van
    {
        public string Van1 { get; set; }
        public string VanNumber { get; set; }
        public int? Active { get; set; }
        public int? ReadyStockSalesVan { get; set; }
    }
}
