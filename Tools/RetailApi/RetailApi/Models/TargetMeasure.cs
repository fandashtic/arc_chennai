using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TargetMeasure
    {
        public int MeasureId { get; set; }
        public string Description { get; set; }
        public int? Active { get; set; }
    }
}
