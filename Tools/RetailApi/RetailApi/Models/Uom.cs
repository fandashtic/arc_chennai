using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Uom
    {
        public int Uom1 { get; set; }
        public string Description { get; set; }
        public DateTime? CreationDate { get; set; }
        public int Active { get; set; }
    }
}
