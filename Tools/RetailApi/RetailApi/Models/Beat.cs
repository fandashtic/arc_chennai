using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Beat
    {
        public int BeatId { get; set; }
        public string Description { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Active { get; set; }
        public int? PreDefFlag { get; set; }
    }
}
